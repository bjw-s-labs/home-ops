#!/bin/bash
set -e

INPUT_MARKDOWNLINT_VERSION=${INPUT_MARKDOWNLINT_VERSION:=latest}
INPUT_MARKDOWNLINT_FLAGS=${INPUT_MARKDOWNLINT_FLAGS:=.}
INPUT_FAIL_ON_ERROR=${INPUT_FAIL_ON_ERROR:=false}
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
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -log-level="debug" \
      -level="${INPUT_LEVEL}" || EXIT_CODE=$?

echo "::endgroup::"
exit ${EXIT_CODE}
