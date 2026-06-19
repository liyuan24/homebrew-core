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

run() {
  printf '\n==> %s\n' "$*"
  "$@"
}

export HOMEBREW_NO_INSTALL_FROM_API=1
export HOMEBREW_DEVELOPER=1

run ruby -c "${FORMULA_PATH}"
run brew style --fix "${FORMULA_PATH}"
run brew install --build-from-source "./${FORMULA_PATH}"
run wattle --version
run wattle --help
run brew test "${FORMULA_NAME}"
run brew audit --new --strict --online "./${FORMULA_PATH}"

if [[ "${UNINSTALL}" -eq 1 ]]; then
  run brew uninstall "${FORMULA_NAME}"
fi

printf '\nWattle formula checks completed.\n'
