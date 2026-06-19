#!/usr/bin/env bash
# Validate the local Wattle Homebrew formula on macOS.
#
# Run from a Homebrew/homebrew-core checkout that contains Formula/w/wattle.rb:
#   scripts/test-wattle-formula.sh
#
# To also uninstall Wattle after checks:
#   scripts/test-wattle-formula.sh --uninstall

set -euo pipefail

FORMULA_PATH="${FORMULA_PATH:-Formula/w/wattle.rb}"
FORMULA_NAME="${FORMULA_NAME:-wattle}"
UNINSTALL=0

for arg in "$@"; do
  case "${arg}" in
    --uninstall)
      UNINSTALL=1
      ;;
    -h|--help)
      sed -n '1,12p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: ${arg}" >&2
      exit 2
      ;;
  esac
done

if ! command -v brew >/dev/null 2>&1; then
  echo "Missing required command: brew" >&2
  exit 1
fi

if ! command -v ruby >/dev/null 2>&1; then
  echo "Missing required command: ruby" >&2
  exit 1
fi

if [[ ! -f "${FORMULA_PATH}" ]]; then
  echo "Formula not found: ${FORMULA_PATH}" >&2
  echo "Run this script from the homebrew-core checkout containing Formula/w/wattle.rb." >&2
  exit 1
fi

CORE_REPO="$(brew --repo homebrew/core)"
CURRENT_REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
if [[ "${CURRENT_REPO}" != "${CORE_REPO}" ]]; then
  echo "This script must run from Homebrew's installed homebrew/core tap checkout." >&2
  echo "Current repo: ${CURRENT_REPO}" >&2
  echo "Core tap:     ${CORE_REPO}" >&2
  echo >&2
  echo "Use:" >&2
  echo "  cd \"\$(brew --repo homebrew/core)\"" >&2
  echo "  git fetch https://github.com/liyuan24/homebrew-core.git wattle-formula" >&2
  echo "  git switch -C wattle-formula FETCH_HEAD" >&2
  echo "  scripts/test-wattle-formula.sh" >&2
  exit 1
fi

run() {
  printf '\n==> %s\n' "$*"
  "$@"
}

export HOMEBREW_NO_INSTALL_FROM_API=1
export HOMEBREW_DEVELOPER=1

run ruby -c "${FORMULA_PATH}"
run brew style --fix "${FORMULA_PATH}"
if brew list --formula "${FORMULA_NAME}" >/dev/null 2>&1; then
  run brew reinstall --build-from-source "${FORMULA_NAME}"
else
  run brew install --build-from-source "${FORMULA_NAME}"
fi
run wattle --version
run wattle --help
run brew test "${FORMULA_NAME}"
run brew audit --new --strict --online "${FORMULA_NAME}"

if [[ "${UNINSTALL}" -eq 1 ]]; then
  run brew uninstall "${FORMULA_NAME}"
fi

printf '\nWattle formula checks completed.\n'
