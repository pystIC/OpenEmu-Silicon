# Migrating from OpenEmu to OpenEmu-Silicon

If you've been using the original OpenEmu on an Intel Mac or via Rosetta 2 and are switching to OpenEmu-Silicon, here's what to expect.

---

## The short version

Your game library, ROM files, save states, screenshots, and settings carry over automatically. You do not need to import, copy, or reconfigure anything. The one exception is save states for a small number of older cores — see the [Save States](#save-states) section below.

---

## How data is preserved

OpenEmu-Silicon uses the exact same bundle identifier (`org.openemu.OpenEmu`) and the same data directory as the original OpenEmu:

```
~/Library/Application Support/OpenEmu/
```

When you launch OpenEmu-Silicon for the first time, it opens the existing library database, reads the existing save states folder, and loads whatever settings were already in place. Nothing is moved, renamed, or reset.

---

## What happens on first launch

### Cores are upgraded to ARM64

The original OpenEmu used Intel (x86_64) cores. OpenEmu-Silicon requires ARM64 cores. On first launch, the app automatically:

1. Scans your installed cores for Intel-only binaries
2. Moves them to `~/Library/Application Support/OpenEmu/Cores/Legacy/` (not deleted)
3. Downloads ARM64 replacements from the update server
4. Shows you an alert listing which cores were moved

This happens in the background during startup and requires an internet connection to fetch the ARM64 replacements. If you're offline on first launch, the cores will still be moved to Legacy — they'll be replaced the next time you launch with a connection.

### Save states are validated

A small number of save state formats are incompatible between older core versions and the current ones. Loading an incompatible save state causes a crash, so the app removes them automatically on first launch.

> **Back up your save states before switching if you care about any of the following systems:**

| Core | What gets removed |
|------|------------------|
| CrabEmu | All saves (core fully replaced by Genesis Plus GX for SMS/GameGear) |
| desmume 0.9.10–0.9.11 | Saves from those specific versions (0.9.12 saves are kept) |
| GenesisPlus 1.7.4.x | Saves from those specific versions |
| Mupen64Plus 2.0–2.5.3 | Saves from those specific versions |
| NeoPop | All saves (core removed) |
| VisualBoyAdvance | All saves (core replaced by mGBA) |
| Dolphin (old) | All saves from the pre-integration Dolphin_Core |

**In-game saves (battery saves / SRAM) are not affected.** This only applies to save states — the snapshot-style saves you create with Cmd+S or from the HUD. Your in-game progress saved through the game's own save system lives in the ROM folder and is untouched.

> **Note:** As of April 2026, the app removes incompatible saves silently without a warning dialog. This is a known issue tracked in [#126](https://github.com/nickybmon/OpenEmu-Silicon/issues/126). A warning before deletion is planned.

---

## How to back up your saves before switching

```bash
cp -R ~/Library/Application\ Support/OpenEmu/Save\ States/ ~/Desktop/OpenEmu-Save-States-Backup/
```

This copies your entire save state library to your Desktop. Takes a few seconds. Do it before your first OpenEmu-Silicon launch.

---

## Filters and shaders

Video filters and shader settings are stored in UserDefaults and carry over automatically. Any custom shaders you've added to the Shaders folder will also still be there.

---

## Game library and cover art

Your full game library — ROM paths, metadata, cover art, play counts, last-played dates — is stored in the Core Data database at:

```
~/Library/Application Support/OpenEmu/Game Library/Library.storedata
```

This opens without modification. If your library database was created with an older version of OpenEmu, the app runs a schema migration automatically on first launch (handled by `LibraryMigrator`). This is transparent and does not change or remove your data.

---

## Controller mappings

Controller profiles and button mappings are stored in UserDefaults and carry over automatically.

---

## Preferences

All preferences (default cores, video settings, audio settings, library paths) carry over automatically via UserDefaults.

---

## Google Drive sync

If you had Google Drive sync configured, you will need to re-authenticate in Preferences → Cloud Saves. The OAuth token from the original app is not reused.

---

## Running both apps side by side

Because both apps use the same data directory and bundle identifier, **you cannot safely run both at the same time.** They will both try to write to the same library database and can corrupt it. If you want to keep the original OpenEmu around as a fallback:

1. Quit one before launching the other
2. Better: once you've confirmed everything works in OpenEmu-Silicon, move the original app to Trash (don't empty it yet — keep it as a fallback for a week or two)

---

## Reverting to the original OpenEmu

If something goes wrong and you need to go back:

1. Quit OpenEmu-Silicon
2. Restore your save state backup (if you made one)
3. Relaunch the original OpenEmu

Your library database will still be there — the only data that may be different is save states for the affected cores listed above.

---

## Troubleshooting

**The app shows no games in my library after switching.**
This usually means the library database path has changed. Go to Preferences → Library and verify the path points to `~/Library/Application Support/OpenEmu/Game Library`.

**My cores say "not installed" after first launch.**
The ARM64 core download may not have completed. Check your internet connection, then go to Preferences → Cores and click "Install" for any cores listed as not installed.

**A game that worked in the original OpenEmu doesn't launch now.**
Check the [Known Issues](https://github.com/nickybmon/OpenEmu-Silicon/issues) tracker. If it's not there, open an issue with your Mac model, macOS version, and the system/game you're trying to run.
