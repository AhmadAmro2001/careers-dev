# Careers (app 116)

## Purpose

Careers is an APEX portal for job applicants and administrators. The applicant
flow includes registration, login and OTP steps, profile maintenance, vacancy
details, and job applications. The administration flow includes a dashboard,
application review, vacancy management, and reports.

## Architecture Notes

- The APEX application ID is `116`, its alias is `careers`, and its parsing
  schema is `CAREERS`.
- The application uses the `custom-login-auth` authentication scheme. Page 131
  is the configured home page and page 9999 is the login page.
- Applicant-facing pages are mainly in the 100–133 range. Administration
  pages are mainly in the 201–214 range.
- The app references database objects including `JOB_VACANCY`,
  `JOB_APPLICATION`, `JOB_APPLICATION_ATTACHMENTS`, `PERSONAL_INFO`,
  `JOB_APPLICATION_PKG`, and `PKG_ADMIN`, as well as account, education,
  language, location, and other lookup tables. These are maintained in the
  separate `database/CAREERS/` metadata mirror; the app's APEXlang directory
  does not package their DDL.
- The application uses APEX `textMessages` for translated text and the
  Universal Theme.
- The bilingual interface is English and Modern Standard Arabic. Page 9999
  offers a session-only language switch. It applies the requested value with
  `APEX_UTIL.SET_SESSION_LANG` and redirects to page 9999 with its cache
  cleared, so APEX renders the next request using the new session language.
- UI translations live in `shared-components/messages.apx`. Verified
  message-aware APEX fields use `&{KEY}.`; the custom applicant navbar
  template uses `&APP_TEXT$KEY!HTML.` so its labels resolve through APEX
  template substitutions. Static server-side feedback uses
  `APEX_LANG.GET_MESSAGE` where needed.
- Business tables and stored data are unchanged. Vacancy and lookup values
  remain as stored; only application interface text is translated.
- Arabic page direction follows the Arabic document language in
  `shared-components/static-files/careers.css`.

## Known Patterns

- Applicant pages provide registration and OTP flows, profile details, and
  vacancy application steps. The administration pages support managing
  applications and vacancies.
- The app has `user-schema`, `admin-schema`, and `it-admin-schema`
  authorization schemes. The app owner reviewed the 26 pages previously
  reported without page-level authorization and confirmed that this is
  intentional. Do not add page authorization schemes to those pages solely to
  silence the audit finding.

## Known Issues / Gotchas

- The application source contains CAPTCHA-related static substitutions,
  including a secret-like value. Do not copy their values into this file or
  other notes. Verify the intended credential handling for each deployment
  environment before publishing an export.
- `uc-apx schema` is a heuristic static scan without a database connection.
  It reports referenced objects, but dynamic SQL and table-versus-view
  distinctions may require checking the actual source or database.

## Last Updated

2026-10-05 — created from the exported app structure, dependency scan,
owner-confirmed authorization intent, and language-switch/navbar fixes.
