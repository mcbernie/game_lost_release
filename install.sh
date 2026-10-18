#!/bin/sh
# LOST_INSTALLER -- installs or updates "Lost" (Steam Deck / Linux x86_64) to the newest release.
#
#   curl -fsSL https://mcbernie.github.io/game_lost_release/install.sh | sh
#
# Options: see usage() (--help). The folder is always the same (default ~/Games/Lost).
#
# Needs only: sh, curl, tar, grep, sed, awk, sort and sha256sum (or shasum). No sudo, no jq.
# Writes only to <dir>, <dir>.new (staging), <dir>.previous (backup of the last version), a
# temporary folder and, with --desktop, ~/.local/share/applications/lost-update.desktop.
#
# Test overrides (environment): LOST_API (release list URL), LOST_DOWNLOAD (base URL of the
# release files, <base>/<tag>/<file>), LOST_SCRIPT_URL (where this script can be fetched again).
set -eu

REPO="mcbernie/game_lost_release"
api=${LOST_API:-"https://api.github.com/repos/$REPO/releases"}
download=${LOST_DOWNLOAD:-"https://github.com/$REPO/releases/download"}
script_url=${LOST_SCRIPT_URL:-"https://mcbernie.github.io/game_lost_release/install.sh"}
platform="linux-x86_64-steamdeck"
# Rewritten with a fixed folder in the copy that is installed as <dir>/update.sh.
default_dir="$HOME/Games/Lost"

want_version="" tmp="" staging="" dir=""
stable=0 force=0 desktop=0 desktop_only=0 pause=0

# Prints the option help.
usage() {
    cat <<'HELP'
Usage: install.sh [options]
  --dir <path>       install folder (default ~/Games/Lost)
  --version <tag>    install exactly this release instead of the newest
  --stable           ignore pre-releases (test versions)
  --force            reinstall even if the version is already installed
  --desktop          also create the menu entry "Lost aktualisieren"
  --install-desktop  only create that menu entry and exit
  --pause            wait for Enter at the end
  --help             show this text
HELP
}

# True if folder $1 looks like a Lost installation (has VERSION or lost.sh).
is_lost_dir() {
    [ -f "$1/VERSION" ] || [ -f "$1/lost.sh" ]
}

# Prints an error and exits.
die() {
    echo "Error: $*" >&2
    exit 1
}

# Removes the temporary folder and an unfinished staging folder; optionally waits for Enter.
cleanup() {
    code=$?
    [ -z "$tmp" ] || rm -rf "$tmp"
    [ -z "$staging" ] || rm -rf "$staging"
    if [ "$pause" = 1 ]; then
        echo
        printf 'Press Enter to close. '
        { read -r _ < /dev/tty; } 2> /dev/null || true
    fi
    exit "$code"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

# Downloads URL $1 into file $2.
fetch() {
    curl -fsSL --retry 2 --connect-timeout 15 -o "$2" "$1" || die "download failed: $1"
}

# Prints the SHA-256 hash of file $1.
sha256_of() {
    if command -v sha256sum > /dev/null 2>&1; then
        sha256sum "$1" | cut -d ' ' -f 1
    else
        shasum -a 256 "$1" | cut -d ' ' -f 1
    fi
}

# Reads the release list (JSON on stdin, GitHub's pretty-printed layout: release keys are indented
# by four spaces) and prints the tag of the newest published non-draft release; with stable=1
# pre-releases are skipped. Same rule as the download page.
newest_tag() {
    grep -E '^    "(tag_name|draft|prerelease|published_at)":' \
        | sed -E 's/^ +"([a-z_]+)": *"?([^",]*)"?,?[[:space:]]*$/\1 \2/' \
        | awk -v stable="$stable" '
            $1 == "tag_name"   { tag = $2 }
            $1 == "draft"      { draft = $2 }
            $1 == "prerelease" { pre = $2 }
            $1 == "published_at" && $2 != "null" && tag != "" && draft != "true" \
                && !(stable == 1 && pre == "true") { print $2, tag }' \
        | sort -r | head -n 1 | cut -d ' ' -f 2
}

# Normalizes $1 to an absolute path without trailing slash, rejects dangerous folders, sets $dir.
check_dir() {
    case "$1" in
        '') die "empty --dir" ;;
        /*) d=$1 ;;
        *) d="$PWD/$1" ;;
    esac
    while [ "${d%/}" != "$d" ]; do d=${d%/}; done
    [ -n "$d" ] || die "--dir '/' is not allowed"
    case "$d" in
        *[!A-Za-z0-9._/+@\ -]*) die "--dir may only contain letters, digits and . _ / + @ - and spaces" ;;
        *'/../'* | */.. | */. | *'/./'* | *//*) die "--dir must be a plain path (no '.', '..' or '//')" ;;
    esac
    home=${HOME%/}
    # At least two path components; neither $HOME nor one of its parents.
    case "$d" in
        /*/*) ;;
        *) die "--dir '$d' is too close to the root" ;;
    esac
    if [ "$d" = "$home" ] || [ "${home#"$d"/}" != "$home" ]; then
        die "--dir '$d' is your home folder (or above it); pick a subfolder such as $home/Games/Lost"
    fi
    dir=$d
}

# Writes the menu entry "Lost aktualisieren" that runs <dir>/update.sh in a terminal.
install_desktop_entry() {
    apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
    mkdir -p "$apps"
    exec_line="\"$dir/update.sh\" --pause"
    terminal=false
    if command -v konsole > /dev/null 2>&1; then
        exec_line="konsole -e $exec_line"
    elif command -v xterm > /dev/null 2>&1; then
        exec_line="xterm -e $exec_line"
    else
        terminal=true
    fi
    cat > "$apps/lost-update.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Lost aktualisieren
Name[en]=Update Lost
Comment=Installs the newest version of Lost
Exec=$exec_line
Path=$dir
Icon=system-software-update
Terminal=$terminal
Categories=Game;
DESKTOP
    chmod +x "$apps/lost-update.desktop"
    echo "Menu entry created: $apps/lost-update.desktop"
}

# Installs this script as file $1, with the install folder baked in as default.
install_update_script() {
    if [ -f "$0" ] && grep -q '^# LOST_INSTALLER' "$0" 2> /dev/null; then
        src=$0
    else
        src="$tmp/install.sh"
        fetch "$script_url" "$src"
    fi
    sed -e "s|^default_dir=.*|default_dir=\"$dir\"|" "$src" > "$1"
    chmod +x "$1"
}

# Aborts if the game from folder $1 is running.
check_not_running() {
    command -v pgrep > /dev/null 2>&1 || return 0
    pattern=$(printf '%s' "$1/lost" | sed 's/[][\.*^$+?(){}|]/\\&/g')
    if pgrep -f "$pattern" > /dev/null 2>&1; then
        die "Lost is running. Close the game and run this again."
    fi
}

# Replaces <dir> by the staged folder, keeping the old one as <dir>.previous.
swap_in() {
    rm -rf "$dir.previous"
    if [ -e "$dir" ]; then
        mv "$dir" "$dir.previous"
        if ! mv "$staging" "$dir"; then
            mv "$dir.previous" "$dir"
            die "could not move the new version into place; old version restored"
        fi
    else
        mv "$staging" "$dir"
    fi
    staging=""
}

# Parses the command line.
parse_args() {
    dir_arg=$default_dir
    while [ $# -gt 0 ]; do
        case "$1" in
            --dir) [ $# -ge 2 ] || die "--dir needs a path"; dir_arg=$2; shift ;;
            --version) [ $# -ge 2 ] || die "--version needs a tag"; want_version=$2; shift ;;
            --stable) stable=1 ;;
            --force) force=1 ;;
            --desktop) desktop=1 ;;
            --install-desktop) desktop_only=1 ;;
            --pause) pause=1 ;;
            -h | --help) usage; exit 0 ;;
            *) die "unknown option: $1 (see --help)" ;;
        esac
        shift
    done
    check_dir "$dir_arg"
}

# Picks the tag to install: --version, else the newest release from the API.
resolve_tag() {
    tag=$want_version
    if [ -z "$tag" ]; then
        echo "Looking for the newest version ..."
        fetch "$api" "$tmp/releases.json"
        tag=$(newest_tag < "$tmp/releases.json")
        if [ -z "$tag" ] && [ "$stable" = 1 ] && [ -n "$(stable=0; newest_tag < "$tmp/releases.json")" ]; then
            die "no stable release yet (only test versions exist); run again without --stable"
        fi
        [ -n "$tag" ] || die "no published release found"
    fi
    case "$tag" in *[!A-Za-z0-9._+-]*) die "invalid version tag: $tag" ;; esac
}

# Downloads package and checksum list for $tag into $tmp and verifies the hash.
download_verified() {
    echo "Downloading $name ..."
    fetch "$download/$tag/$name" "$tmp/$name"
    fetch "$download/$tag/SHA256SUMS.txt" "$tmp/SHA256SUMS.txt"
    expected=$(grep -F "$name" "$tmp/SHA256SUMS.txt" | head -n 1 | cut -d ' ' -f 1)
    [ -n "$expected" ] || die "no checksum for $name in SHA256SUMS.txt"
    [ "$(sha256_of "$tmp/$name")" = "$expected" ] || die "checksum mismatch for $name; nothing was changed"
    echo "Checksum ok."
}

# Unpacks the package next to <dir> as <dir>.new and completes it.
stage_package() {
    staging="$dir.new"
    rm -rf "$staging"
    mkdir -p "$staging"
    tar -xzf "$tmp/$name" -C "$staging" --strip-components=1 || die "could not unpack $name"
    [ -f "$staging/lost.sh" ] || die "package has no lost.sh; nothing was changed"
    printf '%s\n' "$tag" > "$staging/VERSION"
    install_update_script "$staging/update.sh"
}

# Prints the closing message.
report_done() {
    echo
    echo "Done: Lost $tag is installed in $dir"
    [ ! -d "$dir.previous" ] || echo "(the previous version is kept in $dir.previous)"
    if [ -z "$installed" ]; then
        echo
        echo "First time? Add the game to Steam (Desktop Mode):"
        echo "  Steam -> Games -> Add a Non-Steam Game to My Library -> Browse ->"
        echo "  file type 'All files' -> $dir/lost.sh"
        echo "Update later: run $dir/update.sh (same place, so the Steam entry stays valid)."
    else
        echo "Start: $dir/lost.sh"
    fi
}

# Main flow: find version, compare, download, verify, swap.
main() {
    parse_args "$@"
    if [ "$desktop_only" = 1 ]; then
        install_desktop_entry
        exit 0
    fi
    command -v curl > /dev/null 2>&1 || die "curl is required"
    command -v tar > /dev/null 2>&1 || die "tar is required"
    if [ "$(uname -s)" = Linux ] && [ "$(uname -m)" != x86_64 ]; then
        die "only 64-bit x86 Linux (Steam Deck) is supported"
    fi
    if [ -e "$dir" ] && ! is_lost_dir "$dir"; then
        die "'$dir' exists but does not look like a Lost installation; choose another --dir"
    fi
    # A leftover staging folder of an interrupted run is replaced; anything else is not ours.
    if [ -e "$dir.new" ] && ! is_lost_dir "$dir.new"; then
        die "'$dir.new' exists and is not a Lost staging folder; remove or rename it, then run again"
    fi
    tmp=$(mktemp -d)
    resolve_tag

    installed=""
    [ ! -f "$dir/VERSION" ] || installed=$(head -n 1 "$dir/VERSION")
    if [ "$installed" = "$tag" ] && [ "$force" = 0 ]; then
        echo "Lost $tag is already installed in $dir. Nothing to do."
        [ "$desktop" = 0 ] || install_desktop_entry
        exit 0
    fi
    if [ -n "$installed" ]; then echo "Installed: $installed -> new: $tag"; else echo "New installation: $tag"; fi
    check_not_running "$dir"

    name="Lost-$tag-$platform.tar.gz"
    download_verified
    stage_package
    swap_in
    [ "$desktop" = 0 ] || install_desktop_entry
    report_done
}

main "$@"
