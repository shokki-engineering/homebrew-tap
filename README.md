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

| Formula | Description | Install |
| --- | --- | --- |
| `norn` | Local temporal data engine with gRPC and optional MCP | `brew install shokki-engineering/tap/norn` |

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

### Norn 0.1.0 daemon

[Norn 0.1.0](https://github.com/shokki-engineering/norn/releases/tag/v0.1.0)
is the first release of the temporal data engine. Its complete package includes
the `norn` daemon, `nornctl`, CSV/Parquet/Arrow/MCAP interchange, a built-in MCP
server, documentation and licences. Once its release publishes the formula:

```sh
brew install shokki-engineering/tap/norn
brew services start norn
nornctl --endpoint "unix:$(brew --prefix)/var/run/norn/norn.sock" status
```

The status must contain `SERVING`. The service runs in the background and at
login on macOS through launchd, or as a systemd user service on Linux. Run it
without `sudo`. Installation alone does not start it. `brew services list`
shows the daemon; `brew services stop norn` stops it and removes its login
registration.

Configuration is `$(brew --prefix)/etc/norn/norn.toml`, preserved on upgrades;
data is in `$(brew --prefix)/var/norn`, and logs are in
`$(brew --prefix)/var/log/norn.log`. MCP is off by default. After an upgrade,
run `brew services restart norn` and check status again. Norn's public archives
need no download token.

Norn's release workflow publishes platform archives and SHA-256 checksums,
generates `Formula/norn.rb`, regenerates the README package table with
`ruby scripts/update_readme.rb`, and commits both files as **Walle**
(`walle@shokki.engineering`). It preserves this tap's other content.
Its `HOMEBREW_TAP_TOKEN` secret is a fine-grained PAT restricted to this tap
with Contents read/write access; the workflow verifies write access before
building. PAT authentication uses its owner's account; Walle is the Git
author and committer identity.

See Norn's [changelog](https://github.com/shokki-engineering/norn/blob/main/docs/project/changelog.md)
and [Homebrew guide](https://github.com/shokki-engineering/norn/blob/main/docs/guides/homebrew.md)
for release setup, configuration and health checks.

## Reporting problems

Report tap metadata or automation problems in [this repository](https://github.com/shokki-engineering/homebrew-tap/issues). Report package runtime problems to the upstream project, including your operating system, architecture, package version, and the failing command. Remove tokens and other credentials from logs before sharing them.
