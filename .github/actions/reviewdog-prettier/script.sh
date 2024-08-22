#!/bin/bash
set -e

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
  -reporter="github-pr-check" \
  -filter-mode="${INPUT_FILTER_MODE}" \
  -fail-on-error="${INPUT_FAIL_ON_ERROR}"

exit_code=$?
echo "::endgroup::"
exit $exit_code
