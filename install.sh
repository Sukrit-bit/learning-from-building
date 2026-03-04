#!/bin/bash
# install.sh — Symlinks skills from this repo to ~/.claude/skills/ for global access
#
# Usage: ./install.sh
# Run this after cloning the repo or after adding new skills.
# Existing symlinks are overwritten. Original skills in ~/.claude/skills/ are NOT affected
# unless they have the same name as a skill in this repo.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"

echo "Installing skills from: $REPO_DIR/skills/"
echo "Target directory: $SKILLS_DIR"
echo ""

installed=0
for skill_dir in "$REPO_DIR/skills"/*/; do
  # Skip if no skill directories exist
  [ -d "$skill_dir" ] || continue

  skill_name=$(basename "$skill_dir")

  # Check that SKILL.md exists in the skill directory
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "  SKIP: $skill_name (no SKILL.md found)"
    continue
  fi

  # Remove existing symlink or directory if it exists
  if [ -L "$SKILLS_DIR/$skill_name" ] || [ -d "$SKILLS_DIR/$skill_name" ]; then
    rm -rf "$SKILLS_DIR/$skill_name"
  fi

  # Create symlink
  ln -s "$skill_dir" "$SKILLS_DIR/$skill_name"
  echo "  OK: $skill_name → $SKILLS_DIR/$skill_name"
  installed=$((installed + 1))
done

echo ""
echo "Installed $installed skills."
echo ""
echo "Verify with: ls -la $SKILLS_DIR/"
