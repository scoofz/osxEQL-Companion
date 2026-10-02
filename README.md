# osxEQL-Companion

**EverQuest Legends on Apple Silicon Macs — with [EQ Legends Companion](https://github.com/jmoyers/everquest-companion)
running beside it: DPS meter, floating overlays, trackers and alerts, even over the fullscreen game.**

osxEQL-Companion is built on [sowoky/osxEQL](https://github.com/sowoky/osxEQL). It is the
sister app of [osxEQL-Buddy](https://github.com/scoofz/osxEQL) (same runtime, same fixes,
but for EQBuddy Evolved) — pick the companion you prefer, or install both: they share the
same game install.

| | What it is | Where it comes from |
|---|---|---|
| **osxEQL** | Runs the Windows game on macOS with open-source parts only: Wine built from CodeWeavers' published source + DXMT (DirectX 11 → Metal). No CrossOver, no proprietary D3DMetal. | [sowoky/osxEQL](https://github.com/sowoky/osxEQL) (MIT) — the base of this repo |
| **EQ Legends Companion** | Reads your EverQuest `/log` live: DPS meter with floating overlays, Plane of Sky tracker, loot & item knowledge, AA/levels, raid targets, buff timers, sound and voice alerts. Windows-only (Electron). | [jmoyers/everquest-companion](https://github.com/jmoyers/everquest-companion) (FSL-1.1-MIT — downloaded from its official release, never bundled) |
| **osxEQL-Companion** | Installs, updates and runs EQ Legends Companion *inside* osxEQL's Wine, lets its overlays float over the fullscreen game, hides/closes it with the game — and fixes osxEQL's fullscreen/mouse and Bluetooth-audio issues along the way. | This repo |

> Unofficial, fan-made compatibility tool. **Not** affiliated with or endorsed by
> Daybreak Game Company, Game Jawn, CodeWeavers, Apple, or the EQ Legends Companion
> author. The EverQuest Legends game is **not included** (you bring your own copy from the
> official installer), and neither is EQ Legends Companion (downloaded from its official
> release, on your request).

---

## Install (players)

**Requirements:** Apple Silicon Mac (M1 or newer), macOS 13+ (macOS 26 Tahoe supported);
a Daybreak / EverQuest Legends account and the official **`EQLegends_setup.exe`**;
~10 GB free disk; internet the first time for EQ Legends Companion (≈140 MB).

1. Download **`osxEQL-Companion-<version>.dmg`** from the [Releases](../../releases) page
   and drag **osxEQL-Companion** into **Applications**.
   *Coming from osxEQL or osxEQL-Buddy? Nothing to migrate: all three use the same data
   folder, `~/Library/Application Support/osxEQL`, so your prefix, 7 GB game client and
   settings are reused as is. osxEQL-Buddy can stay installed next to it.*
2. The release is **ad-hoc signed, not notarized by Apple**. Clear the quarantine flag
   once before the first launch (or right-click → **Open** the first time):
   ```bash
   xattr -dr com.apple.quarantine /Applications/osxEQL-Companion.app
   ```
3. Download **`EQLegends_setup.exe`** from the official EverQuest Legends site.
4. Launch **osxEQL-Companion**. A setup window walks the whole install: pick the installer
   when asked, then watch it run Daybreak's installer, update the launcher and download the
   game — a chime tells you when the login screen is ready. Log in, hit **Play**.
5. On the next launch the app asks **once** whether to install **EQ Legends Companion**.
   Say yes: from then on it opens with the game, stays up to date, and closes with it.

**Settings & troubleshooting, no Terminal needed:** hold **⌥ Option** while opening
osxEQL-Companion. A small list lets you switch EQ Legends Companion and each of its extras
on or off, **archive your EverQuest logs** (huge logs cause freezes — the app also warns
you at launch), and **Collect diagnostics** puts a zip on your Desktop (logs, settings, Mac
model — no passwords) to attach to a bug report.

Nothing else to install — no Homebrew, no Xcode, no Wine. The runtime (with the patched
Mac and audio drivers) and the helper ship inside the app.

## What you get

- **The game, natively on Apple Silicon**, through Wine + DXMT/Metal (from osxEQL).
- **The game window sized to your display** — in-game fullscreen works and the mouse
  reaches every pixel.
- **Sound that follows your headphones** — Bluetooth headphones die → the speakers take
  over at their own volume; connect others → the sound moves, no restart.
- **EQ Legends Companion, fully integrated**:
  - installed with one click, **SHA-512 verified**, into the game's own Wine prefix — it
    finds your logs with zero setup;
  - **kept up to date** automatically at each launch;
  - its **overlays float over the game, even fullscreen**;
  - **hides** when you switch to another app, **comes back** with the game;
  - **closes with the game**.

## How osxEQL runs the game

`eqgame.exe` is a 64-bit Direct3D 11 Windows game. Running it on macOS takes two pieces:

- **Wine** runs the Windows program. osxEQL compiles it from **CodeWeavers' official LGPL
  CrossOver source** (26.2.0), because only that lineage exports the `macdrv_functions`
  bridge the graphics layer needs to attach a Metal view to a Wine window.
- **DXMT** ([3Shain/dxmt](https://github.com/3Shain/dxmt)) translates Direct3D 11 to
  **Metal** — the open-source alternative to Apple's proprietary D3DMetal.

The runtime (Wine + DXMT + the libraries it needs) is embedded in `osxEQL-Companion.app`. The Wine
*prefix* — a little Windows `C:\` drive — and the game client live in
`~/Library/Application Support/osxEQL/`. On launch, the app starts Daybreak's
**LaunchPad** inside a Wine **virtual desktop** (a single Mac window the game draws into;
it avoids a LaunchPad splash-window deadlock), and LaunchPad starts the game. The first
run is a guided install (it also fixes a Daybreak installer path bug under Wine).
Deep technical notes: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md),
[`docs/JOURNEY.md`](docs/JOURNEY.md).

## What EQ Legends Companion does

[EQ Legends Companion](https://github.com/jmoyers/everquest-companion) (Josh Moyers) reads
the log EverQuest writes for you (`/log`) and turns it into:

- a **live DPS meter** with fight history, and **floating overlays** (damage or healing,
  per fight or per zone, click-through when locked);
- a **Plane of Sky tracker**, **loot and item knowledge** (what each item is for);
- **leveling & AA** history, **raid targets**, **buff timers**;
- **sound and voice alerts**, with ~350 installable voice packs.

It is a Windows Electron app (FSL-1.1-MIT) that already knows how to paint inside a Wine
prefix. See [its README](https://github.com/jmoyers/everquest-companion) for the full tour.

## How the two run together

```
osxEQL-Companion.app ─► Wine virtual desktop "osxEQL" ─► LaunchPad ─► eqgame.exe ─► writes /log
     │                                                                          │
     ├─► (background) update check ─► EQ Legends Companion.exe ◄── reads /log ──┘
     │                                (own Mac windows, same Wine prefix: sees it as C:\)
     │
     └─► companion-focus (small macOS helper)
            • hides the companion when another Mac app is in front, shows it with the game
            • quits it 20 s after the game closes

Runtime drivers patched (shared with osxEQL-Buddy):
  winemac.so        → topmost windows may float over a fullscreen game (opt-in knob)
  winecoreaudio.so  → the game's sound follows the macOS default output
```

Both programs share one Wine prefix, so the companion finds the game's logs at the normal
Windows location (`C:\Users\Public\Daybreak Game Company\…\EverQuest Legends`) without
configuration. It runs as its **own Mac windows** (not inside the game's virtual desktop),
which is what lets its overlays float over the game, be hidden, and sit on a second display.

## Improvements over osxEQL, in detail

### 1. Game window = your display (fullscreen and mouse fixed)
The game runs inside a Wine virtual desktop. Upstream sized it to "display minus menu/title
bar" (and the CLI to a fixed 1280×960). EverQuest's in-game fullscreen asks Wine for a
display mode of exactly `Width×Height`; a virtual desktop only offers its own size plus
smaller standard modes, so EQ fell back to **1280×960** — the picture shrank, **the mouse
stopped working outside a 1280×960 area**, and EQ rewrote `eqclient.ini`.

Now the virtual desktop is **exactly the main display** by default, and all four
`eqclient.ini` size keys are pinned to it at every launch (one-time backup:
`eqclient.ini.osxeql-bak`). Fullscreen and windowed are the same size, the mouse maps 1:1,
and your Fullscreen choice is kept. `osxeql res auto|WxH` still picks a smaller window
(fullscreen is then forced off, since that is what breaks it); `osxeql res max` returns to
the default. `osxeql play` (CLI) now follows the same rules as the app.

### 2. Sound follows your headphones
Wine's CoreAudio driver pinned the game's sound to the device that was the default when the
game started. When that device vanished mid-game — Bluetooth headphones out of battery —
the sound blasted out of the Mac speakers, ignoring their volume and mute, until a restart.
The bundled `winecoreaudio.so` now opens default-device streams on macOS's *default output*
unit, which follows the system default: headphones die → speakers, at their own volume and
mute; connect other headphones → the sound moves to them. Streams opened on a specific
device are unchanged; `OSXEQL_PIN_AUDIO_DEVICE=1` restores the old behaviour.

### 3. EQ Legends Companion, integrated

| Feature | How it works |
|---|---|
| **Install** | Reads the project's `latest.yml` from its GitHub release, downloads the installer it names, **refuses it unless it matches the published SHA-512**, and runs the one-click installer silently (`/S`) into the game's prefix. |
| **Starts with the game** | Next to LaunchPad on every Play, as its own Mac window(s). |
| **Always up to date** | `latest.yml`'s version vs. the installed one at every launch, in the background (the game never waits); a missing install is reinstalled. The app's built-in updater verifies installers through PowerShell, which Wine doesn't have — this replaces it. Offline: the installed copy starts as is. |
| **Overlays over fullscreen** | macOS keeps a fullscreen game above every normal "always on top" window. The bundled `winemac.so` carries a small opt-in patch (from EQBuddy 1.99.18, MIT) letting topmost windows sit above it; osxEQL-Companion turns it on for the companion's exe *before* it starts (the driver reads it at startup). |
| **Hides with the game** | From inside Wine the companion can't see the game in front (different Wine desktop). The `companion-focus` helper watches the frontmost Mac app instead and hides the companion while you're elsewhere. |
| **Closes with the game** | 20 s after the game closes (enough for a quick relaunch from LaunchPad), the helper sends it a normal macOS Quit, which Wine turns into a Windows shutdown — it saves and exits cleanly (forced only if it ignores that for 30 s). A companion you opened without the game is left alone. |
| **Sounds & voice** | Nothing to do: Electron plays its own audio through Wine's CoreAudio driver, and the headphone fix applies to it too. |

### 4. Tooling
- `osxeql overlay` / `osxeql audiofix` rebuild **only** the patched driver (`winemac.so` /
  `winecoreaudio.so`) from the same CrossOver source in a few minutes, with a backup and
  `--revert`; full `build-wine.sh` builds include both patches.
- `osxeql winlevels` lists every on-screen window with its macOS window level.
- The helper logs its decisions and the memory footprint of itself, the companion and the
  game (after 5 minutes, then hourly).

## Settings & command line

In the app everything above is on by default. Each part can be switched from the CLI
(`engine/osxeql` in a clone of this repo); settings are small files in
`~/Library/Application Support/osxEQL/` and take effect at the next launch.

```bash
engine/osxeql status                    # Wine, prefix, game, companion, overlay + audio patches
engine/osxeql play                      # launch the game (+ the companion)
engine/osxeql res [max|auto|WxH]        # game window size (default: max = exact display)

engine/osxeql eqlc                      # EQ Legends Companion: install state, version, latest
engine/osxeql eqlc install|update       # install / update it now (SHA-512 checked)
engine/osxeql eqlc window|off           # start it with the game, or not
engine/osxeql eqlc autoupdate on|off    # update it at every launch (default on)
engine/osxeql companion autohide on|off # hide it while another app is in front
engine/osxeql companion autoclose on|off # quit it 20 s after the game closes
engine/osxeql companion helper on|off   # diagnostic: off = no companion-focus helper at all

engine/osxeql overlay  [--status|--revert]   # winemac.so float-over-fullscreen patch
engine/osxeql audiofix [--status|--revert]   # winecoreaudio.so follow-default-output patch
                                             # (only for a self-built runtime: the release
                                             #  app has both; needs Xcode CLT + brew bison)
engine/osxeql logs [archive [MB]]            # EverQuest logs + sizes; archive big ones
engine/osxeql winlevels [filter] [--delay N] # on-screen windows + macOS window levels
```

If the CLI says `wine: not staged`, point it at the app's runtime:
```bash
ln -sfn /Applications/osxEQL-Companion.app/Contents/Resources/Wine "$HOME/Library/Application Support/osxEQL/Wine"
```

## Logs & troubleshooting

All in `~/Library/Application Support/osxEQL/logs/`:

| Log | What's in it |
|---|---|
| `app-launch.log`, `launch-*.log` | the game / LaunchPad |
| `eqlc.log` | EQ Legends Companion: update check, install, start, helper decisions (show/hide/close), memory lines |
| `overlay-*.log`, `audiofix-build.log` | driver rebuilds |

The companion's own errors: `…/osxEQL/prefix/drive_c/users/<you>/AppData/Roaming/everquest-companion/errors.log`
(included in **Collect diagnostics**).

- **Mouse offset / small picture in fullscreen** → `osxeql res max`, relaunch. Don't drag
  the window bigger mid-game (the render surface is fixed at launch).
- **Overlays behind the fullscreen game** → `osxeql overlay --status` should say *patched*.
- **No game sound after headphones changed** → `osxeql audiofix --status`; opt out with
  `OSXEQL_PIN_AUDIO_DEVICE=1`.
- **Freezes / micro-stutters that get worse over time → check your game log first.**
  With `/log` on, EverQuest appends every line of chat and combat to one file per
  character and never trims it. After weeks of play it can reach hundreds of MB, and
  EverQuest — and the companion, which reads it live — start hitching on every write.
  **The app handles it:** at launch it warns when a log is over 100 MB and offers to
  **Archive** it (moved to `Logs/archive/` with a date, never deleted); the ⌥ Option menu
  has **Archive game logs** any time. CLI: `osxeql logs`, `osxeql logs archive`. By hand:
  quit the game, open (Finder → Go → Go to Folder…)
  ```
  ~/Library/Application Support/osxEQL/prefix/drive_c/users/Public/Daybreak Game Company/Installed Games/EverQuest Legends/Logs
  ```
  and move the big `eqlog_<character>_<server>.txt` away.
- **Micro-stutters in game** (log is small) → hold ⌥ Option while opening the app and try
  one session with *EQ Legends Companion: OFF*, then one with it ON and *Companion helper:
  OFF*. CLI: `osxeql eqlc off`, then `osxeql companion helper off`.
- **Blank or black companion window** → Electron renders through DXMT's Direct3D 11 under
  Wine; send a **Collect diagnostics** zip with an issue.
- **Something broke after a driver patch** → `osxeql overlay --revert` / `osxeql audiofix --revert`.

## Known limits

- **First release, lightly tested:** the install/update/hide/close plumbing is the one
  proven with EQBuddy in osxEQL-Buddy, but EQ Legends Companion itself (Electron/Chromium
  under Wine + DXMT) has had far less play time on the Mac. Reports welcome.
- **No exclusive fullscreen:** "fullscreen" is the display-sized virtual desktop — which
  is also what keeps the mouse free across monitors.

## Build from source (developers)

```bash
# 1. Compile the Wine runtime from CodeWeavers' LGPL source (~30-60 min, x86_64).
#    Needs Xcode CLT + Intel Homebrew. Applies the winemac overlay patch and the
#    CoreAudio follow-default edit. Stages to ~/…/osxEQL/Wine.cxbuild, then verify
#    DXMT render and swap into ~/…/osxEQL/Wine.
#    (Already have osxEQL-Buddy installed? Its runtime is identical: build-app.sh reuses it.)
engine/build-wine.sh

# 2. Stage DXMT into that wine tree + create a prefix.
engine/osxeql backend dxmt

# 3. Build the app icon (needs `brew install librsvg`).
cd assets/icon && uv run python generate.py && \
  rsvg-convert -w 1024 -h 1024 icon.svg -o icon.png && bash build_icns.sh icon.png && cd ../..

# 4. Assemble the self-contained app + DMG. build-app.sh also compiles the Swift helpers
#    (setup window, companion-focus) and reports whether both driver patches are in.
packaging/build-app.sh        # -> dist/osxEQL-Companion.app  (embeds the runtime)
packaging/build-dmg.sh        # -> dist/osxEQL-Companion-<ver>.dmg

# 5. (Optional) Sign with a Developer ID for Gatekeeper-clean distribution.
export CODESIGN_IDENTITY="Developer ID Application: ..."
export NOTARIZE_KEY=~/path/to/AuthKey.p8
export NOTARIZE_KEY_ID=<key-id>
export NOTARIZE_ISSUER=<issuer-uuid>
packaging/build-app.sh
packaging/build-dmg.sh
```

### Prerequisites (building only — the release DMG needs none of this)

`packaging/build-app.sh` bundles the Homebrew dylibs Wine dlopens (freetype, gnutls,
SDL2, …) into the app, so **end users don't need Homebrew**. Building from source does:

- **x86_64 Homebrew** (`/usr/local/bin/brew`).
  > [!IMPORTANT]
  > Wine is an x86_64 application and **requires** x86_64 libraries. The standard ARM64
  > Homebrew (`/opt/homebrew/bin/brew`) installs incompatible libraries that make Wine crash.
  >
  > To install the x86_64 Homebrew on an Apple Silicon Mac:
  > ```bash
  > arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  > ```
- **Required formulas** (`arch -x86_64 /usr/local/bin/brew install <formula>`):
  `bison` `mingw-w64` `pkgconfig` `coreutils` `freetype` `gnutls` `molten-vk` `sdl2`
  `vulkan-loader` `vulkan-headers` `libpcap`
- For `osxeql overlay` / `audiofix` only: Xcode command-line tools and `brew install bison`
  (either Homebrew).

## Project layout

```
app/            launcher.sh (the app entry point + first-run wizard + ⌥ menu) + Info.plist
assets/icon/    icon source (generate.py / icon.svg) + AppIcon.icns + build_icns.sh
engine/         headless CLI (osxeql) + numbered setup scripts + build-wine.sh
  lib.sh          shared config, display sizing (resolve_size) + eqclient.ini pinning
  eqlcompanion.sh EQ Legends Companion install/update/launch (also shipped in the .app)
  companion.sh    helper settings, game-log archiving (also shipped in the .app)
  overlay.sh      rebuild winemac.so with the float-over-fullscreen patch
  audiofix.sh     rebuild winecoreaudio.so so sound follows the macOS default output
  driverlib.sh    shared build/install/revert plumbing for overlay.sh + audiofix.sh
  patches/        winemac-overlay.patch (EQBuddy 1.99.18, MIT), coreaudio-follow-default.py,
                  + upstream macdrv patch
  tools/          companion-focus.swift (autohide, autoclose), winlevels.m
packaging/      build-app.sh, build-dmg.sh, sign-and-notarize.sh, entitlements.plist,
                verify-release.sh
docs/           ARCHITECTURE / STATUS / JOURNEY / VISION (upstream osxEQL)
```

The big artifacts — the ~570 MB Wine runtime, the ~7 GB game client, the DMG — are **not**
in git; the runtime ships inside the release DMG, the game client is your own.

## License & credits

- **osxEQL** by [sowoky](https://github.com/sowoky/osxEQL), **osxEQL-Buddy** and
  osxEQL-Companion's additions: **MIT** (see [`LICENSE`](LICENSE)).
- **EQ Legends Companion** (© Josh Moyers, FSL-1.1-MIT) is **not included**:
  osxEQL-Companion only downloads the official release on your request, verifies it, and
  runs it unmodified.
- **EQBuddy 1.99.18** (MIT, © David Edwards): the winemac overlay patch and `winlevels.m`
  are reused from it.
- **Wine** (LGPL-2.1) and **DXMT** (LGPL-2.1+) — see
  [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md) for license texts and how to obtain and
  rebuild the corresponding source (including the two driver patches).
- **EverQuest Legends** © Daybreak Game Company / Game Jawn. Not included, not affiliated.
