Contributing
============

Thanks for your interest in contributing to video-studio-oss. To keep this project secure and maintainable, please follow these guidelines:

- Use pull requests for all changes. Do not push directly to the default branch.
- Follow the PR checklist in .github/PULL_REQUEST_TEMPLATE.md.
- Run tests and linters locally before opening a PR.
- Do not commit secrets or credentials. If you need to share sensitive info during triage, use a private security advisory or encrypted email.
- Security issues should be reported using the SECURITY template (create a private advisory) or by contacting @mupadhyaya.

Code review & ownership
- Changes to code require approval by the code owner(s). See .github/CODEOWNERS.

### Developer Setup & PR Checks
When you raise a PR, our GitHub Actions CI will automatically review your code for syntax, security, and vulnerabilities. To ensure your PR passes, please run these checks locally before pushing:

1. **Install dev dependencies:** 
   ```bash
   pip install flake8 bandit safety
   ```
2. **Run Linting (Flake8):** Checks for syntax errors and undefined names.
   ```bash
   flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
   ```
3. **Run Security Analysis (Bandit):** Checks for common security issues.
   ```bash
   bandit -r . -ll -ii
   ```
4. **Run Dependency Check (Safety):** Verifies no known vulnerabilities exist in dependencies.
   ```bash
   safety check -r requirements.txt
   ```
