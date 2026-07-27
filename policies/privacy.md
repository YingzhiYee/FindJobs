# Privacy policy for the local prototype

## Default

- Resume files, contact details, generated materials and application records stay in a user-selected local directory.
- The repository never asks for passwords, one-time codes, browser cookies, session tokens or exported browser profiles.
- Do not commit real resumes, application records, screenshots or logs; the root `.gitignore` contains conservative defaults.
- Progress output and audit records must redact email addresses, phone numbers, tokens and full document contents.

## External processing

Before sending any file or field to a site, model, MCP server or third-party skill, show the destination domain, data fields, purpose and expected retention. Processing is denied by default for unknown domains or cloud document parsers. The user may opt in for a named destination and named job only.

If a dependency sends data outside the user's region, state that explicitly and stop unless the user gives informed consent. Do not infer consent from installing the repository.

## Retention and deletion

Keep the original resume immutable and store generated versions locally with hashes. Let the user delete the profile, drafts, screenshots and ledger from the selected workspace. Do not send personal data to public issues, analytics, telemetry or shared repositories.

This prototype is not an employment service, recruiting platform or official integration with ego(lite), Boss 直聘, 猎聘, Alibaba, Tencent, ByteDance or any other site.
