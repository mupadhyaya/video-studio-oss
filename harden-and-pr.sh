#!/usr/bin/env bash
set -euo pipefail

REPO="mupadhyaya/video-studio-oss"
BRANCH="security/hardening-initial"
DEFAULT_BRANCH="main" # change if your default branch is different
PR_TITLE="chore: security hardening — add policies & CI"
PR_BODY="This PR adds initial security hardening files: SECURITY.md, CODEOWNERS, dependabot, CodeQL, secret-scan & SAST workflows, ISSUE/PR templates, and CONTRIBUTING.md.\n\nAdmin actions remaining (branch protection, vulnerability alerts, push protection, require signed commits) are listed in the PR description."

# ensure we're in a clone
if [ ! -d .git ]; then
  echo "This script must be run inside a clone of ${REPO}."
  echo "Clone with: git clone https://github.com/${REPO}.git"
  exit 1
fi

# create branch
git checkout -b "${BRANCH}"

# create directories
mkdir -p .github/workflows .github/ISSUE_TEMPLATE

# create files
cat > .github/SECURITY.md <<'EOF'
# Security Policy

Thank you for reporting security issues in video-studio-oss.

We use GitHub's private security advisories and encourage reporters to use that flow. If you cannot use GitHub's private advisory system, please contact the maintainers via GitHub user @mupadhyaya.

Reporting process
- Create a private security advisory on GitHub (recommended) or open an issue using the SECURITY issue template and mark it "private" when prompted.
- Do NOT include exploits, sensitive data, or full PoCs in public issues.
- We'll acknowledge receipt within 72 hours and provide an estimated fix/patch timeline.

PGP / encrypted disclosure
- If you need to send sensitive data privately via email, ask for the maintainer's PGP key via the GitHub profile (@mupadhyaya) and encrypt your message.

After disclosure
- We'll coordinate a fix, security patch, and a disclosure timeline. We may notify downstream users via advisory/CVE where appropriate.
EOF

cat > .github/CODEOWNERS <<'EOF'
# CODEOWNERS
# Require review by the repo owner for all changes by default
* @mupadhyaya
EOF

cat > .github/dependabot.yml <<'EOF'
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10
    rebase-strategy: "auto"
EOF

cat > .github/workflows/codeql-analysis.yml <<'EOF'
name: "CodeQL"

on:
  push:
    branches: ["**"]
  pull_request:
    branches: ["**"]
  schedule:
    - cron: '0 3 * * *'

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        language: [ 'python' ]
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}

    - name: Autobuild
      uses: github/codeql-action/autobuild@v2

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2
EOF

cat > .github/workflows/secret-scan.yml <<'EOF'
name: "Secret & SAST Scans"

on:
  pull_request:
    types: [opened, synchronize, reopened]
  push:
    branches: ["**"]

jobs:
  gitleaks:
    name: Gitleaks secret scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run gitleaks
        uses: zricethezav/gitleaks-action@v2
        with:
          args: --verbose --redact

  bandit:
    name: Bandit (Python SAST)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.x'
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install bandit
      - name: Run bandit
        run: |
          bandit -r . || true
EOF

cat > .github/ISSUE_TEMPLATE/security.md <<'EOF'
---
name: Security Report
about: Use this template to report a security vulnerability privately. Do NOT include secrets or exploit details in a public issue.
title: 'Security: '
labels: security

---
If this is a critical vulnerability, please create a private security advisory on GitHub and/or contact the maintainers (@mupadhyaya).

Please include:
- A short description of the issue
- Affected versions
- Steps to reproduce (high level — do NOT include exploit or secret data in public)
- Contact preference (GitHub user / encrypted email)
EOF

cat > .github/PULL_REQUEST_TEMPLATE.md <<'EOF'
<!-- PR template to help maintainers and contributors follow the repo security rules -->

## Description

Describe the changes in this PR.

## Checklist
- [ ] I have run the test suite locally and tests pass
- [ ] No secrets, API keys, or credentials are included in this PR
- [ ] I added or updated tests for my changes
- [ ] I updated documentation where required
- [ ] CI (CodeQL, bandit, gitleaks) runs and passes
EOF

cat > CONTRIBUTING.md <<'EOF'
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
EOF

# commit & push
git add .github CONTRIBUTING.md
git commit -m "chore: add initial security hardening files (SECURITY.md, CODEOWNERS, workflows, templates, dependabot)"
git push --set-upstream origin "${BRANCH}"

# open PR (use DEFAULT_BRANCH as base)
gh pr create --title "${PR_TITLE}" --body "${PR_BODY}" --base "${DEFAULT_BRANCH}" || true

echo "Done. PR created (or ready to be created). Review it at: https://github.com/${REPO}/pulls"