#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import zipfile


ROOT = Path(__file__).resolve().parent.parent
VERSION = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
TERRAFORM_VERSION = (ROOT / ".terraform-version").read_text(encoding="utf-8").strip()
DIST = ROOT / "dist"
ARTIFACT_NAME = f"bedrock-self-managed-kb-accelerator-{VERSION}.zip"
ARCHIVE_PATH = DIST / ARTIFACT_NAME
CHECKSUM_PATH = DIST / f"{ARTIFACT_NAME}.sha256"
PREFIX = f"bedrock-self-managed-kb-accelerator-{VERSION}"

EXCLUDED_DIRECTORIES = {
    ".git",
    ".terraform",
    ".pytest_cache",
    "__pycache__",
    "dist",
}


def included(path: Path) -> bool:
    relative = path.relative_to(ROOT)
    if any(part in EXCLUDED_DIRECTORIES for part in relative.parts):
        return False

    name = path.name
    if name == ".DS_Store" or name.startswith("crash."):
        return False
    if name.endswith(".tfvars") and not name.endswith(".tfvars.example"):
        return False
    if name.endswith(".tfbackend") and not name.endswith(".tfbackend.example"):
        return False
    if ".tfstate" in name or ".tfplan" in name or name == "tfplan":
        return False
    return path.is_file()


def digest(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def zip_info(name: str, executable: bool = False) -> zipfile.ZipInfo:
    info = zipfile.ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
    info.create_system = 3
    mode = 0o755 if executable else 0o644
    info.external_attr = mode << 16
    info.compress_type = zipfile.ZIP_STORED
    return info


def main() -> None:
    files = sorted(path for path in ROOT.rglob("*") if included(path))
    manifest_files = []

    DIST.mkdir(exist_ok=True)
    ARCHIVE_PATH.unlink(missing_ok=True)
    CHECKSUM_PATH.unlink(missing_ok=True)

    with zipfile.ZipFile(ARCHIVE_PATH, mode="w") as archive:
        for path in files:
            content = path.read_bytes()
            relative = path.relative_to(ROOT).as_posix()
            executable = path.suffix in {".py", ".sh"}
            archive.writestr(
                zip_info(f"{PREFIX}/{relative}", executable=executable),
                content,
            )
            manifest_files.append({"path": relative, "sha256": digest(content)})

        manifest = {
            "artifact": ARTIFACT_NAME,
            "artifact_version": VERSION,
            "files": manifest_files,
            "format_version": 1,
            "terraform_version": TERRAFORM_VERSION,
        }
        manifest_content = (
            json.dumps(manifest, indent=2, sort_keys=True) + "\n"
        ).encode("utf-8")
        archive.writestr(
            zip_info(f"{PREFIX}/ARTIFACT_MANIFEST.json"),
            manifest_content,
        )

    checksum = digest(ARCHIVE_PATH.read_bytes())
    CHECKSUM_PATH.write_text(
        f"{checksum}  {ARTIFACT_NAME}\n",
        encoding="utf-8",
    )
    print(ARCHIVE_PATH)
    print(CHECKSUM_PATH)


if __name__ == "__main__":
    main()
