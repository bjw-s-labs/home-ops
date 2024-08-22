#!/bin/bash
set -e

INPUT_MARKDOWNLINT_VERSION=${INPUT_MARKDOWNLINT_VERSION:=latest}
INPUT_MARKDOWNLINT_FLAGS=${INPUT_MARKDOWNLINT_FLAGS:=.}
INPUT_FAIL_LEVEL=${INPUT_FAIL_LEVEL:=warning}
INPUT_FILTER_MODE=${INPUT_FILTER_MODE:=nofilter}
INPUT_LEVEL=${INPUT_LEVEL:=error}
INPUT_REPORTER=${INPUT_REPORTER:=local}

# Install markdownlint-cli2
if [[ ! -f "$(which markdownlint-cli2)" ]]; then
  echo "::group::🔄 Running npm install to install markdownlint-cli2..."
  npm install "markdownlint-cli2@${INPUT_MARKDOWNLINT_VERSION}" --global
  echo "::endgroup::"
fi

echo "::group::📝 Running markdownlint-cli2 with reviewdog 🐶 ..."

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

markdownlint-cli2 ${INPUT_MARKDOWNLINT_FLAGS} 2>&1 \
| reviewdog \
      -efm="%f:%l:%c %m" \
      -efm="%f:%l %m" \
      -name="markdownlint" \
      -reporter="${INPUT_REPORTER}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-level="${INPUT_FAIL_LEVEL}" \
      -level="${INPUT_LEVEL}" ; exit_code=$?

echo "::endgroup::"
exit ${exit_code}
