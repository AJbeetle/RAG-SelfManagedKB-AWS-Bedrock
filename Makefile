SHELL := /usr/bin/env bash

TERRAFORM ?= terraform
TFLINT ?= tflint
PYTHON ?= python3

.PHONY: check fmt fmt-check lint validate test package

check: fmt-check lint validate test

fmt:
	$(TERRAFORM) fmt -recursive

fmt-check:
	$(TERRAFORM) fmt -check -recursive

lint:
	$(TFLINT) --recursive --format compact

validate:
	TERRAFORM=$(TERRAFORM) bash scripts/validate.sh

test:
	TERRAFORM=$(TERRAFORM) bash scripts/test.sh

package: check
	$(PYTHON) scripts/package.py
