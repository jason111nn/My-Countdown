# Security Policy

## Supported Versions

Since this project is a personal portfolio and deployed as a static site, only the latest version deployed on the `main` (or `gh-pages`) branch is currently supported.

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

I take security seriously. If you discover a vulnerability in this project (e.g., XSS, dependency issues), please follow these steps:

1.  **Do NOT open a public issue.** This prevents the vulnerability from being exploited before it can be patched.
2.  Please report the issue by sending an email to **[你的 Email 地址]**.
3.  In the email, please include:
    * A description of the vulnerability.
    * Steps to reproduce the issue.
    * Any relevant screenshots or code snippets.

I will acknowledge receipt of your vulnerability report and strive to send you regular updates about my progress.

## Security Best Practices for this Project

* **Dependencies:** This project relies on `npm` packages. I regularly update dependencies to patch known vulnerabilities.
* **Static Analysis:** I use standard linter configurations to catch potential issues during development.
* **Deployment:** The site is served via GitHub Pages over HTTPS.

Thank you for helping keep this project safe.
