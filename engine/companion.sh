#!/bin/bash
# osxEQL-Companion — shared plumbing for the companion app (engine/eqlcompanion.sh)
# and the .app launcher: the macOS focus helper, its settings, and EverQuest's own
# log files. Sourced by engine/osxeql, engine/04-launch.sh and the .app
# (Contents/Resources/companion.sh). Callers set WINE, WINEPREFIX, OSXEQL_HOME.
#
# Settings are small files in $OSXEQL_HOME, named companion-* so they never collide
# with osxEQL-Buddy's (both apps may share the same prefix and game install).

# ---- the macOS helper (engine/tools/companion-focus.swift) -------------------
# Hides the companion while another Mac app is in front and quits it 20 s after the
# game closes — things the Windows app can't do itself from inside Wine.
COMPANION_AUTOHIDE_FILE="$OSXEQL_HOME/companion-autohide"    # on|off, absent = on
COMPANION_AUTOCLOSE_FILE="$OSXEQL_HOME/companion-autoclose"  # on|off, absent = on
COMPANION_HELPER_FILE="$OSXEQL_HOME/companion-helper"        # on|off, absent = on (diagnostic)

_companion_flag() {  # $1 file -> on|off (absent = on)
    [ "$( [ -f "$1" ] && tr -cd 'a-z' < "$1")" = off ] && echo off || echo on
}
companion_autohide()  { _companion_flag "$COMPANION_AUTOHIDE_FILE"; }
companion_autoclose() { _companion_flag "$COMPANION_AUTOCLOSE_FILE"; }
companion_helper()    { _companion_flag "$COMPANION_HELPER_FILE"; }

# The helper binary: $COMPANION_FOCUS_BIN if the caller ships one prebuilt (the .app),
# else built on first use from $COMPANION_FOCUS_SRC into $OSXEQL_HOME/bin (the engine).
companion_focus_bin() {
    local log="$1" bin="${COMPANION_FOCUS_BIN:-$OSXEQL_HOME/bin/companion-focus}"
    if [ -n "${COMPANION_FOCUS_SRC:-}" ] && [ -f "$COMPANION_FOCUS_SRC" ] \
       && { [ ! -x "$bin" ] || [ "$COMPANION_FOCUS_SRC" -nt "$bin" ]; }; then
        mkdir -p "$(dirname "$bin")"
        echo "companion: building focus helper" >>"$log"
        xcrun swiftc -O -o "$bin" "$COMPANION_FOCUS_SRC" -framework AppKit >>"$log" 2>&1 \
            || { echo "companion: focus helper build failed (Xcode command-line tools?)" >>"$log"; return 1; }
    fi
    [ -x "$bin" ] && printf '%s\n' "$bin"
}

# True when the patched winemac.so (engine/overlay.sh) is the one installed.
companion_overlay_patched() {
    local so
    so="$(dirname "$WINE")/../lib/wine/x86_64-unix/winemac.so"
    [ -f "$so.osxeql-overlay" ] || return 1
    [ "$(shasum -a 256 "$so" 2>/dev/null | cut -d' ' -f1)" = "$(tr -cd '0-9a-f' < "$so.osxeql-overlay")" ]
}
# ---- EverQuest's own log files ------------------------------------------------
# With /log on, EverQuest appends every chat/combat line to
# Logs/eqlog_<character>_<server>.txt forever. Past a few hundred MB, the game — and
# the companion, which tails the file live — hitch on writes: the freezes a player reported
# (2026-10). "Archiving" moves a log into Logs/archive/ with a date stamp; EverQuest
# starts a fresh file on the next /log, and the companion (which only reads Logs/eqlog_*.txt
# directly) picks the new one up. Nothing is deleted: the player decides what to do
# with the archive folder. Never done while the game is running.
GAMELOG_THRESHOLD_FILE="$OSXEQL_HOME/log-threshold-mb"   # default 100
GAMELOG_CHECK_FILE="$OSXEQL_HOME/log-check"              # on|off (startup prompt)

gamelog_dir() {
    printf '%s\n' "$WINEPREFIX/drive_c/users/Public/Daybreak Game Company/Installed Games/EverQuest Legends/Logs"
}

gamelog_threshold_mb() {
    local t
    t="$( [ -f "$GAMELOG_THRESHOLD_FILE" ] && tr -cd '0-9' < "$GAMELOG_THRESHOLD_FILE")"
    printf '%s\n' "${t:-100}"
}

# Size in MB, rounded. wc -c on a regular file is an fstat (instant), and unlike stat
# it means the same thing on macOS and Linux.
gamelog_mb() {
    local b
    b="$(wc -c < "$1" 2>/dev/null | tr -cd '0-9')"
    echo $(( ( ${b:-0} + 524288 ) / 1048576 ))
}

# The game's logs (eqlog_*.txt + dbg.txt), one per line; $1 = minimum size in MB (0 = all).
gamelog_list() {
    local min="${1:-0}" d f
    d="$(gamelog_dir)"
    [ -d "$d" ] || return 0
    for f in "$d"/eqlog_*.txt "$d/dbg.txt"; do
        [ -f "$f" ] || continue
        [ "$(gamelog_mb "$f")" -ge "$min" ] && printf '%s\n' "$f"
    done
}

# "eqlog_Bob_server.txt (412 MB)" lines for a dialog; reads paths on stdin.
gamelog_describe() {
    local f
    while IFS= read -r f; do printf '%s (%s MB)\n' "$(basename "$f")" "$(gamelog_mb "$f")"; done
}

gamelog_game_running() { pgrep -qf 'eqgame\.exe' 2>/dev/null; }

# Move the given logs (paths on stdin) into Logs/archive/<name>-<date>.txt.
# Prints the total MB moved. Refuses while the game runs.
gamelog_archive() {
    local d arch f stamp total=0
    gamelog_game_running && { echo "game running — not archiving" >&2; return 1; }
    d="$(gamelog_dir)"; arch="$d/archive"; stamp="$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$arch" || return 1
    while IFS= read -r f; do
        [ -f "$f" ] || continue
        total=$(( total + $(gamelog_mb "$f") ))
        mv -f "$f" "$arch/$(basename "${f%.txt}")-$stamp.txt" || return 1
    done
    printf '%s\n' "$total"
}
