# Verified ego runtime activation report — 2026-07-29

## Result

The repository now separates installation from execution identity. New users still install ego(lite) only from the official quick-start page and finish onboarding in the GUI. Browser work then runs through `scripts/run-verified-ego-browser.sh`, which verifies the official latest stable skill and signed/notarized `/Applications/AI product Builder/ego.app`, ignores every `ego-browser` command on PATH, requires exactly one trusted main process, and executes only the resolver-returned CLI.

`./tests/run-runtime-activation.sh` passed against ego `0.4.6.1`, ego-browser skill `1.2.5`. The passing release-candidate rerun created and closed task space `30`, opened no website and returned `pathShadowIgnored: true` plus `taskSpacesAvailable: true`.

## Adversarial observations

1. The user-level activation chain still pointed through `~/.local/bin/ego-browser` to an older Desktop runtime even though the signed `/Applications` app was current. Calling that bare command launched a Node environment without the expected `taskSpaces` bridge.
2. The legacy Desktop runtime also started a background `--startup-ego-browser-service`. The first verified-runner test observed both the official main process and that legacy process, refused to execute browser code, and printed both paths for user remediation.
3. After the user-authorized local activation link was backed up and repointed to the official app's `Versions/Current`, only the official main process remained. This local remediation is not performed automatically by the repository runner.
4. The passing adversarial test placed a symlink to `/usr/bin/false` named `ego-browser` at the front of PATH. The verified runner ignored it, repeated the full resolver checks, invoked the absolute CLI inside the signed app, created an isolated task space, listed zero tabs and closed the space.

## Boundary

This evidence covers runtime selection and task-space availability only. It does not enable a new job-site scope, prove Chrome import state, or change `realFillEnabled`/`realSubmitEnabled`. Chrome import, site login and duplicate-app remediation remain user-controlled GUI actions.
