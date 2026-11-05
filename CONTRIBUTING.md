# Contributing to Reckless Abandon

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## We Develop with Github

We use github to host code, to track issues and feature requests, as well as accept pull requests.

## We Use [Github Flow](https://guides.github.com/introduction/flow/index.html), So All Code Changes Happen Through Pull Requests

Pull requests are the best way to propose changes to the codebase (we use [Github Flow](https://guides.github.com/introduction/flow/index.html)). We actively welcome your pull requests:

1. Fork the repo and create your branch from `develop`.
2. Make your changes.
3. Issue that pull request back to `develop`!

## Any contributions you make will be under the Software License

In short, when you submit code changes, your submissions are understood to be under the same [License](https://github.com/MotherGinger/RecklessAbandon/blob/main/LICENSE) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using Github's [issues](https://github.com/briandk/transcriptase-atom/issues)

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/MotherGinger/RecklessAbandon/issues/new?assignees=MotherGinger&labels=&template=bug_report.md&title=%5BBug+Report%5D); it's that easy!

## Write bug reports with detail, background, and screenshots

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Run the Tests and Linter

Every push and pull request runs [luacheck](https://github.com/lunarmodules/luacheck) and the [busted](https://lunarmodules.github.io/busted/) suite in `spec/` (the **Test** workflow). To run them yourself you need Lua 5.1 and LuaRocks (on Windows, inside WSL):

```bash
luarocks install busted
luarocks install luacheck
bash scripts/test.sh
```

`scripts/test.sh` prints a summary and any failures; `busted` and `luacheck RecklessAbandon spec` run them on their own.

The specs boot the real addon files, in TOC order, inside a small stand-in for the game client (`spec/helpers/wow_stub.lua`) for each flavor: Classic, TBC, Mists, Forever and Retail. `spec/helpers/loader.lua` does the booting, and the stub has helpers to set up a quest log, open it, click buttons, run slash commands and move time forward. When the addon starts using a client API the stub doesn't have, the test fails with a message naming it; add it to the stub with the real client's behavior.

A test wrapped in `Known.Issue` (`spec/helpers/known.lua`) checks for a bug that hasn't been fixed yet. It shows as pending until the bug is fixed, then fails to remind you to remove the wrapper.

## Add a Changelog Entry

Note player-facing changes in `CHANGELOG.txt` under `- Unreleased`, grouped as `Fixed` or `Changed`. These entries become the release notes on GitHub and Wago.

## Releasing (maintainers)

The manual workflows are started from the Actions tab and default to a dry run, which builds everything and attaches the zip and release notes to the run without pushing or uploading anything.

1. **Prepare release** (manual; version, e.g. `3.2.0` or `3.2.0-beta.1`; run on `main`): moves the Unreleased entries under the new version (betas leave them in place), updates `## Version:` in every TOC, and opens a `Release v<version>` pull request from `release/v<version>`.
2. **Merge the pull request.** Publish GitHub release runs on its own: it tags the merged commit, builds the zip, publishes the GitHub release, and deletes the release branch.
3. **Publish to Wago** (manual; tag, e.g. `v3.2.0`): uploads that release to Wago for every game version in the TOC files. Needs the `WAGO_API_TOKEN` secret.
4. **Publish to CurseForge** (manual; tag): the same for CurseForge. Needs the `CF_API_TOKEN` secret and `## X-Curse-Project-ID:` in the TOC files.

Opening the pull request needs Settings → Actions → General → "Allow GitHub Actions to create and approve pull requests".

The repository rulesets are kept in `.github/rulesets/` and imported under Settings → Rules → Rulesets → New ruleset → Import a ruleset.

## Use a Consistent Coding Style

If contributing to the code, please follow a style consistent with the existing codebase.

## License

By contributing, you agree that your contributions will be licensed under our [License](https://github.com/MotherGinger/RecklessAbandon/blob/main/LICENSE).

## References

This document was adapted from the open-source contribution guidelines for [Facebook's Draft](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md)
