# Shokki Engineering Homebrew tap

[![CI](https://github.com/shokki-engineering/homebrew-tap/actions/workflows/ci.yml/badge.svg)](https://github.com/shokki-engineering/homebrew-tap/actions/workflows/ci.yml)
[![README Sync](https://github.com/shokki-engineering/homebrew-tap/actions/workflows/readme-sync.yml/badge.svg)](https://github.com/shokki-engineering/homebrew-tap/actions/workflows/readme-sync.yml)

Homebrew formulae and casks for [Shokki Engineering](https://github.com/shokki-engineering).
The package lists below are generated from `Formula/` and `Casks/` and kept up to date by the README Sync workflow.

## Install

Install [Homebrew](https://brew.sh), then use a package's fully qualified command from the tables below:

```sh
brew tap shokki-engineering/tap
brew search shokki-engineering/tap/
```

The table commands also work without a separate `brew tap` step.
Only packages listed below are available. A package becomes installable after its release workflow publishes a formula or cask here.

### Private release downloads

This tap is public. If a package downloads assets from a private GitHub repository, your account also needs read access to that repository. For formulae that support authenticated GitHub asset downloads, export a token before installation or upgrade:

```sh
export HOMEBREW_GITHUB_API_TOKEN="$(gh auth token)"
```

This command requires an authenticated [GitHub CLI](https://cli.github.com).
Keep tokens out of formulae, documentation, and commits. Follow the package's upstream instructions for any additional download configuration.

## Available formulae

<!-- BEGIN GENERATED FORMULA LIST -->

_None available yet._

<!-- END GENERATED FORMULA LIST -->

## Available casks

<!-- BEGIN GENERATED CASK LIST -->

_None available yet._

<!-- END GENERATED CASK LIST -->

## Upgrade and remove

Use the package name from the tables above with `brew upgrade` or `brew uninstall`.
Run `brew update` first to fetch the latest tap definitions. Follow upstream instructions to restart any services after an upgrade.

## Maintaining this tap

Release automation should publish formulae to `Formula/<name>.rb` and casks to `Casks/<name>.rb`. Both directories are ready for the first package. Each definition must contain a static, non-empty `desc` string; the generator reads this metadata without executing package code.

The README Sync workflow updates the generated tables after changes on `main` and can also be run manually from Actions. It commits only `README.md`, using the repository's `GITHUB_TOKEN`. Enable **Read and write permissions** for Actions if repository policy restricts that token. Branch protection must allow the bot's direct update; otherwise regenerate locally and include the README in the package PR.

To regenerate and validate locally, using Ruby and Homebrew:

```sh
ruby scripts/update_readme.rb
ruby scripts/update_readme.rb --check
ruby test/update_readme_test.rb
find scripts test Formula Casks -name '*.rb' -exec ruby -c {} \;
```

For each published package, also run Homebrew's checks, replacing `<name>`:

```sh
brew style Formula/<name>.rb
brew audit --strict shokki-engineering/tap/<name>
brew install shokki-engineering/tap/<name>
brew test shokki-engineering/tap/<name>
```

For a cask, run `brew style Casks/<name>.rb`, `brew audit --cask --strict shokki-engineering/tap/<name>`, and `brew install --cask shokki-engineering/tap/<name>`; `brew test` applies to formulae.
CI checks all Ruby files for syntax errors, tests the generator on macOS and Linux, and checks package definitions with `brew style` on macOS. README drift blocks package PRs; on `main` it produces a warning while README Sync commits the refreshed tables. Package downloads, audits, installation, and service behavior must be verified when a real release is available.

### Connecting Norn releases

[Norn](https://github.com/shokki-engineering/norn) is the planned first package. Its release workflow should:

1. Publish the platform archives and checksums, then generate `norn.rb` from those release assets.
2. Use `HOMEBREW_TAP_TOKEN` with Contents write access to `shokki-engineering/homebrew-tap` to update `Formula/norn.rb`.
3. Preserve this tap's README, scripts, and workflows. Remove the existing `cp tap-README.md tap/README.md` step from Norn's workflow.
4. Run `ruby scripts/update_readme.rb` in the tap checkout and commit `Formula/norn.rb` together with `README.md`. This also keeps the README current when publishing with a GitHub Actions token that does not trigger another workflow.

After the first formula is published, its install command will appear above. Follow Norn's [Homebrew guide](https://github.com/shokki-engineering/norn/blob/main/docs/guides/homebrew.md) for authentication, configuration, services, and health checks.

## Reporting problems

Report tap metadata or automation problems in [this repository](https://github.com/shokki-engineering/homebrew-tap/issues). Report package runtime problems to the upstream project, including your operating system, architecture, package version, and the failing command. Remove tokens and other credentials from logs before sharing them.
