# README Planning Notes — 2026-02-27

- **Planner:** Blair Fontaine
- **Plan branch:** `plan/readme-upgrade`
- **Objective:** Apply the `plan-readme` protocol to ensure the Debian base image README stays current and actionable for downstream consumers.

## Branch inventory
| Branch | Status |
| --- | --- |
| `main` | Mirrors released container definitions. |
| `dev` | Integration branch; PRs target this first. |
| `ai`, `docs/update-readme` | Historic feature branches, currently inactive. |
| `plan/readme-upgrade` | This planning branch (README + notes only). |

## Issue audit (open items)
| # | Title | Notes |
| --- | --- | --- |
| #102 | Entrypoint bug | Mirrors Alpine issue; ensure README references entrypoint behavior once fixed. |
| #95 | Issue with backup script | Needs documentation on overriding `container-backup`. |
| #77 | Setup a full machine proxy | Dependency for downstream networking guidance. |
| #43 | Add the check scripts for status | Relates to health probe narrative. |

*(Closed issues already covered by existing docs; only open ones surfaced here.)*

## README adjustments queued
- Add executive overview table (owner, registry, plan branch).
- Call out plan branch + plan-readme topic in Planning Hooks.
- Highlight open issues in README so Adam can see context while reviewing.
- Ensure build/run instructions reference `dev` baseline and `plan-readme` workflow.

## Follow-up
- After README merges, remove the `plan-readme` topic from this repo.
- Re-run the playbook when a new topic tag appears.
