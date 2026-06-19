# Wattle Formula Notes

This file is for the `liyuan24/homebrew-core` fork only. Remove it before
opening an upstream PR to `Homebrew/homebrew-core`; the upstream PR should only
add `Formula/w/wattle.rb`.

## Current State

Branch:

```bash
wattle-formula
```

Formula:

```text
Formula/w/wattle.rb
```

Local validation helper:

```text
scripts/test-wattle-formula.sh
```

The formula has been tested on Apple Silicon macOS with:

```bash
ruby -c Formula/w/wattle.rb
brew style --fix Formula/w/wattle.rb
brew reinstall --build-from-source wattle
wattle --version
wattle --help
brew test wattle
brew audit --new --strict --online wattle
```

Build, style, install, and test passed. The remaining blocker was Homebrew
notability:

```text
GitHub repository not notable enough (<30 forks, <30 watchers and <75 stars)
```

## Reproducing Validation

Run from Homebrew's installed `homebrew/core` tap checkout, not a standalone
clone:

```bash
cd "$(brew --repo homebrew/core)"
git fetch https://github.com/liyuan24/homebrew-core.git wattle-formula
git switch -C wattle-formula FETCH_HEAD
scripts/test-wattle-formula.sh
```

To uninstall after checks:

```bash
scripts/test-wattle-formula.sh --uninstall
```

If the helper script is not available in the checkout, run the checks manually:

```bash
export HOMEBREW_NO_INSTALL_FROM_API=1
export HOMEBREW_DEVELOPER=1

ruby -c Formula/w/wattle.rb
brew style --fix Formula/w/wattle.rb
brew reinstall --build-from-source wattle
wattle --version
wattle --help
brew test wattle
brew audit --new --strict --online wattle
```

## When Notability Clears

Before opening an upstream PR:

1. Rebase on current upstream `Homebrew/homebrew-core/main`.
2. Update `Formula/w/wattle.rb` to the latest Wattle release if needed.
3. Refresh Python resources if dependencies changed.
4. Rerun the validation script.
5. Remove fork-local files:

   ```bash
   git rm WATTLE_FORMULA_NOTES.md scripts/test-wattle-formula.sh
   ```

6. Ensure the branch only changes:

   ```text
   Formula/w/wattle.rb
   ```

7. Open the upstream PR with title:

   ```text
   wattle 0.7.0 (new formula)
   ```

The PR body should mention:

- Wattle is an open-source CLI coding agent.
- The formula builds from source with Homebrew Python virtualenv resources.
- `brew reinstall --build-from-source wattle` passes.
- `brew test wattle` passes.
- `brew audit --new --strict --online wattle` passes.

## Notes

- The formula path is preferred over a cask because Wattle is open-source and
  CLI-only.
- `portaudio` is included so Wattle's optional `sounddevice` voice path can
  load PortAudio.
- `rust` is a build dependency for the `uv-build` backend and `jiter`.
- `certifi` and `pydantic` are Homebrew formula dependencies and are excluded
  from vendored Python resources, matching existing Homebrew Python formula
  patterns.
