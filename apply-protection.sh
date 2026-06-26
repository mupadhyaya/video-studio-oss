#!/usr/bin/env bash
set -euo pipefail

OWNER="mupadhyaya"
REPO="video-studio-oss"
BRANCH="main" # replace with your default branch
# contexts must match the status check names as shown on PRs (update if different)
CONTEXTS=("codeql-analysis" "Secret & SAST Scans" "CI/tests")

if [ -z "${GITHUB_TOKEN:-}" ]; then
  if command -v gh >/dev/null 2>&1; then
    echo "Attempting to get GITHUB_TOKEN automatically via GitHub CLI (gh)..."
    GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")
  fi

  if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set and 'gh auth token' failed."
    echo "Please 'gh auth login' or export a repo-admin token as GITHUB_TOKEN."
    exit 1
  fi
fi

# prepare contexts JSON array
contexts_json=$(printf '"%s",' "${CONTEXTS[@]}")
contexts_json="[${contexts_json%,}]"

echo "Setting branch protection for ${OWNER}/${REPO}@${BRANCH}..."
curl -sS -X PUT \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${OWNER}/${REPO}/branches/${BRANCH}/protection" \
  -d "{
    \"required_status_checks\": {
      \"strict\": true,
      \"contexts\": ${contexts_json}
    },
    \"enforce_admins\": true,
    \"required_pull_request_reviews\": {
      \"dismiss_stale_reviews\": true,
      \"require_code_owner_reviews\": true,
      \"required_approving_review_count\": 2
    },
    \"allow_force_pushes\": false,
    \"allow_deletions\": false,
    \"required_linear_history\": true
  }"

echo "Enabling vulnerability alerts..."
curl -sS -X PUT \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${OWNER}/${REPO}/vulnerability-alerts" || true

echo "Done. Note: enabling secret scanning & push protection, and required signatures may require org-level settings or the UI."