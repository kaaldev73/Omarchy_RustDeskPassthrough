# Marketplace submission

Repository: https://github.com/kaaldev73/Omarchy_RustDeskPassthrough

Plugin ID: `io.github.kaaldev73.rustdesk-passthrough`

Category: **Desktop**. Tag: **hyprland**.

This package includes a valid service entry point, README, MIT license, and tests. No listing request is created by installing it or uploading this repository.

## Before sending

1. Complete the physical-key and shell-restart checks in TESTING.md.
2. Confirm your authorship/permission and the MIT license choice. Search the marketplace for the plugin ID to confirm it is available.
3. Ensure the repository is public and its root contains `manifest.json`, `Service.qml`, `runtime.lua`, `README.md`, and `LICENSE`.
4. An optional preview may be a root `preview.png`, `.jpg`, `.jpeg`, `.webp`, or `.avif`. Use a clean demo desktop without private data. A preview is not included in this version.
5. Review `marketplace-submission.md`. Its ownership and checklist confirmations are deliberately unchecked until you confirm them; all five must be true and checked before sending.

Open the [official submission form](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml), or, after reviewing and completing the checklist, run:

```bash
gh issue create \
  --repo omacom/omarchy-plugin-marketplace \
  --title "[Plugin]: RustDesk Fullscreen Passthrough" \
  --body-file marketplace-submission.md
```

The command sends a public issue. Uploading the plugin repository alone does not send this issue. For an AI-assisted submission, the marketplace asks the owner to confirm the checklist and approve the completed title/body before issue creation.

The marketplace validates the repository, scans the selected commit, and requires an explicit `approved-and-verified` maintainer decision for initial publication. Address feedback on the existing issue. These checks are not a general security audit or guarantee. Review their current policies at submission time.

## Sources

- [Marketplace submission guide](https://github.com/omacom/omarchy-plugin-marketplace/blob/main/SUBMISSION.md)
- [Omarchy plugin development guide](https://plugins.omarchy.org/develop.html)
- [Marketplace security policy](https://github.com/omacom/omarchy-plugin-marketplace/blob/main/SECURITY.md)

Guidance checked on 2026-09-08.
