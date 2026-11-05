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

## Add a Changelog Entry

Note player-facing changes in `CHANGELOG.txt` under `- Unreleased`, grouped as `Fixed` or `Changed`. These entries become the release notes on GitHub and Wago.

## Releasing (maintainers)

All three workflows are started by hand from the Actions tab and default to a dry run, which builds everything and attaches the zip and release notes to the run without pushing or uploading anything.

1. **Release** (version, e.g. `3.2.0` or `3.2.0-beta.1`, run on `main`): moves the Unreleased entries under the new version (betas leave them in place), updates `## Version:` in every TOC, commits `Bump to v<version>`, tags it, and publishes the GitHub release.
2. **Publish to Wago** (tag, e.g. `v3.2.0`): uploads that release to Wago for every game version in the TOC files. Needs the `WAGO_API_TOKEN` secret.
3. **Publish to CurseForge** (tag): the same for CurseForge. Needs the `CF_API_TOKEN` secret and `## X-Curse-Project-ID:` in the TOC files.

## Use a Consistent Coding Style

If contributing to the code, please follow a style consistent with the existing codebase.

## License

By contributing, you agree that your contributions will be licensed under our [License](https://github.com/MotherGinger/RecklessAbandon/blob/main/LICENSE).

## References

This document was adapted from the open-source contribution guidelines for [Facebook's Draft](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md)
