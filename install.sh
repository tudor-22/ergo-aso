#!/usr/bin/env bash
# Install the Ergo ASO skill for Codex.
#   ./install.sh                 -> ~/.agents/skills/ergo-aso   (user-level, all projects)
#   ./install.sh --project       -> ./.agents/skills/ergo-aso   (current directory only)
#   ./install.sh --dest <dir>    -> <dir>/ergo-aso              (custom skills directory)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/plugins/ergo-aso/skills/ergo-aso"
SKILLS_DIR="$HOME/.agents/skills"

while [ $# -gt 0 ]; do
  case "$1" in
    --project) SKILLS_DIR="$PWD/.agents/skills" ;;
    --dest)    shift; SKILLS_DIR="${1:?--dest needs a directory}" ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

DEST="$SKILLS_DIR/ergo-aso"
[ -f "$SRC/SKILL.md" ] || { echo "can't find $SRC/SKILL.md — run this from a full clone" >&2; exit 1; }

mkdir -p "$SKILLS_DIR"
if [ -e "$DEST" ]; then
  # keep any renderer deps/fonts already fetched; replace everything else
  echo "Updating existing install at $DEST"
  find "$DEST" -mindepth 1 -maxdepth 1 ! -name renderer -exec rm -rf {} +
  mkdir -p "$DEST/renderer"
  (cd "$SRC/renderer" && find . -maxdepth 1 -type f -exec cp {} "$DEST/renderer/" \;)
  (cd "$SRC" && find . -mindepth 1 -maxdepth 1 ! -name renderer -exec cp -R {} "$DEST/" \;)
else
  cp -R "$SRC" "$DEST"
fi
chmod +x "$DEST/scripts/check_setup.sh" "$DEST/renderer/fetch_fonts.sh" 2>/dev/null || true

echo "Installed Ergo ASO -> $DEST"
echo "Restart Codex (or start a new session), then say: \"do the ASO for my app\""
echo "Check prerequisites any time: $DEST/scripts/check_setup.sh"
