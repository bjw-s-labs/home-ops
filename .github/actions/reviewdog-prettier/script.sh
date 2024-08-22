#!/bin/bash
set -e

INPUT_PRETTIER_VERSION=${INPUT_PRETTIER_VERSION:=latest}
INPUT_PRETTIER_FLAGS=${INPUT_PRETTIER_FLAGS:=.}
INPUT_FAIL_LEVEL=${INPUT_FAIL_LEVEL:=warning}
INPUT_FILTER_MODE=${INPUT_FILTER_MODE:=nofilter}
INPUT_LEVEL=${INPUT_LEVEL:=error}
INPUT_REPORTER=${INPUT_REPORTER:=local}

# Install prettier
if [[ ! -f "$(which prettier)" ]]; then
  echo "::group::🔄 Running npm install to install prettier..."
  npm install "prettier@${INPUT_PRETTIER_VERSION}"
  echo "::endgroup::"
fi

echo "::group::📝 Running prettier with reviewdog 🐶 ..."

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

prettier --check ${INPUT_PRETTIER_FLAGS} 2>&1 | sed --regexp-extended 's/(\[warn\].*)$/\1 File is not properly formatted./' \
| reviewdog \
  -efm="%-G[warn] Code style issues found in the above file(s). Forgot to run Prettier%. File is not properly formatted." \
  -efm="[%tarn] %f %m" \
  -efm="%E[%trror] %f: %m (%l:%c)" \
  -efm="%C[error]%r" \
  -efm="%Z[error]%r" \
  -efm="%-G%r" \
  -name="prettier" \
  -reporter="${INPUT_REPORTER}" \
  -filter-mode="${INPUT_FILTER_MODE}" \
  -fail-level="${INPUT_FAIL_LEVEL}" \
  -level="${INPUT_LEVEL}" ; exit_code=$?

echo "::endgroup::"
exit "${exit_code}"
