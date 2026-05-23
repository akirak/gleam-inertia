---
name: adr-update-status
description: Update the status of an existing Architecture Decision Record (ADR) in `docs/adrs`. Use when asked to change, advance, reject, deprecate, supersede, or otherwise update an ADR status by ADR number with an optional title and optional update description.
---

# ADR Update Status

## Inputs

- ADR identifier: require a 4-digit ADR number, accepting a numeric value that can be zero-padded.
- ADR title: optional; use it only as a sanity check against the matching ADR file.
- New status: require one of `Draft`, `Proposed`, `Accepted`, `Deprecated`, `Superseded`, or `Rejected`.
- Update description: optional; when present, record it in the ADR.

## Workflow

1. Find the ADR in `docs/adrs/` by matching `NNNN-*.md`.
2. Ignore `docs/adrs/0000-template.md` unless the user explicitly asks to edit the template.
3. If no ADR matches the number, report that the ADR was not found.
4. If multiple files match the same number, stop and ask which file to update.
5. If the user supplied a title and it clearly conflicts with the matched ADR title or filename, stop and ask for confirmation.
6. Validate the requested status against the accepted statuses.
7. Update the existing `- Status: ...` metadata line, preserving the surrounding ADR content.
8. Write the status in Title Case to match the ADR template: `Draft`, `Proposed`, `Accepted`, `Deprecated`, `Superseded`, or `Rejected`.
9. If an update description was provided, add a dated entry under `## Status History`.
10. Report the updated ADR path and final status.

## Status History

When recording a description:

- Insert `## Status History` immediately after the ADR metadata block if the section does not exist.
- Add the newest entry first.
- Use the current local date in `YYYY-MM-DD` format.
- Use this format:

```markdown
## Status History

- YYYY-MM-DD: Status changed to Accepted. Description of the update.
```

If the section already exists, add the new entry directly under the heading and keep existing entries unchanged.

## Editing Notes

- Preserve the ADR filename.
- Preserve all sections unrelated to status and status history.
- Do not change the original `- Date: ...` field when only updating status.
- Do not invent a description when the user did not provide one.
