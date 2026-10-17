#!/usr/bin/env bats

setup() {
  cd "$BATS_TEST_DIRNAME/.."
  message_file="$BATS_TEST_TMPDIR/commit message"
}

check_message() {
  local expected=$1 message=$2
  printf '%s\n' "$message" > "$message_file"
  run mise run --quiet hooks:check-commit-message "$message_file"
  if [ "$status" -ne "$expected" ]; then
    printf 'Message: %s\nExpected exit %s, got %s\n%s\n' \
      "$message" "$expected" "$status" "$output" >&2
    return 1
  fi
}

@test "accepts every allowed type" {
  for type in chore feat fix revert style; do
    check_message 0 "$type: update configuration"
  done
}

@test "accepts former types and project areas as scopes" {
  for scope in build ci docs perf refactor test infra github; do
    check_message 0 "chore($scope): update configuration"
  done
}

@test "accepts sorted unique scopes" {
  check_message 0 'fix(ci,docs,infra,test): update configuration'
}

@test "accepts breaking changes with and without scopes" {
  check_message 0 'feat(api-v2)!: change interface'
  check_message 0 'fix!: change interface'
}

@test "does not mistake description parentheses for scopes" {
  check_message 0 'fix: handle input (With Spaces)'
}

@test "accepts comments and message bodies" {
  check_message 0 '# comment
fix(docs): update documentation

Body text.'
}

@test "rejects former types and unknown types" {
  for type in build ci docs perf refactor test unknown; do
    check_message 1 "$type: update configuration"
  done
}

@test "rejects unsorted and duplicate scopes" {
  for scope in 'docs,ci' 'ci,ci'; do
    check_message 1 "fix($scope): update configuration"
    [[ "$output" == *'Invalid scopes:'* ]]
  done
}

@test "rejects malformed scopes" {
  for scope in 'ci, docs' 'Docs' ',ci' 'ci,' 'ci,,docs' 'ci/docs' 'ci_docs' 'ci docs' ''; do
    check_message 1 "fix($scope): update configuration"
  done
}

@test "rejects missing descriptions and invalid headers" {
  check_message 1 'fix: '
  check_message 1 'Fix: update configuration'
  check_message 1 'not a conventional commit'
}

@test "rejects empty and comment-only messages" {
  check_message 1 '# comment only'
  check_message 1 ''
}

@test "preserves autosquash exemptions" {
  check_message 0 'fixup! docs(Invalid): original message'
  check_message 0 'squash! original message'
  check_message 0 'amend! original message'
}

@test "preserves Git-generated merge and revert exemptions" {
  for message in \
    "Merge branch 'topic(Invalid)'" \
    "Merge branches 'one' and 'two'" \
    "Merge tag 'v1'" \
    "Merge tags 'v1' and 'v2'" \
    "Merge commit 'abc'" \
    "Merge remote-tracking branch 'origin/topic'" \
    "Merge remote-tracking branches 'origin/one' and 'origin/two'" \
    'Merge pull request #1 from example/topic' \
    'Revert "original (Invalid) message"'; do
    check_message 0 "$message"
  done
}
