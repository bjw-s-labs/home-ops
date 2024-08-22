#!/bin/bash
set -e

INPUT_MARKDOWNLINT_FLAGS=${INPUT_MARKDOWNLINT_FLAGS:=.}

echo "::group::📝 Running markdownlint-cli2 ..."

markdownlint-cli2 ${INPUT_MARKDOWNLINT_FLAGS} ; exit_code=$?

echo "::endgroup::"
exit ${exit_code}
