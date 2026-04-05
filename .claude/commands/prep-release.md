Prepare a new release of OpenEmu-Silicon. Accepts an optional version argument (e.g. `/prep-release 1.0.5`). If no version is provided, read the current version from `OpenEmu/OpenEmu-Info.plist` and ask the user what the new version should be.

Follow these steps exactly, in order. Do not skip any step.

## Step 1 — Confirm we are on main and up to date

```bash
git checkout main
git fetch origin && git merge origin/main
```

If there are uncommitted changes, stop and tell the user before continuing.

## Step 2 — Determine the new version

If a version argument was passed to this command, use it. Otherwise:
1. Read `OpenEmu/OpenEmu-Info.plist` and report the current `CFBundleShortVersionString` and `CFBundleVersion`.
2. Ask the user: "What should the new version be? (e.g. 1.0.5)" and wait for their answer before continuing.
3. Ask the user: "What should the new build number be? (current is N)" and wait for their answer.

Validate that the version matches `X.Y.Z` format before proceeding.

## Step 3 — Bump the version in source files

Update these two files:

**`OpenEmu/OpenEmu-Info.plist`** — update both keys:
- `CFBundleShortVersionString` → new version string (e.g. `1.0.5`)
- `CFBundleVersion` → new build number (e.g. `6`)

**`OpenEmu/OpenEmu.xcodeproj/project.pbxproj`** — update `MARKETING_VERSION` (appears twice, one per build configuration). Use sed to replace both occurrences:
```bash
sed -i '' 's/MARKETING_VERSION = OLD;/MARKETING_VERSION = NEW;/g' \
  "OpenEmu/OpenEmu.xcodeproj/project.pbxproj"
```

After editing, verify the changes took effect by grepping both files and reporting the new values to the user.

## Step 4 — Run a build check

```bash
xcodebuild -workspace OpenEmu-metal.xcworkspace -scheme OpenEmu \
  -configuration Debug -destination 'platform=macOS,arch=arm64' \
  build 2>&1 | tail -10
```

If the build fails, stop and report the errors. Do not continue to the commit step.

## Step 5 — Commit the version bump directly to main

This is a config-only change and qualifies for a direct commit to main per the CLAUDE.md rule.

```bash
git add OpenEmu/OpenEmu-Info.plist OpenEmu/OpenEmu.xcodeproj/project.pbxproj
git commit -m "chore: bump version to VERSION (build BUILD)"
git push origin main
```

Report the commit SHA.

## Step 6 — Check for release notes

Check if `Releases/notes-VERSION.md` exists. If it does, report it and confirm with the user that they want to use it. If it does not exist, ask the user:

"No release notes file found at Releases/notes-VERSION.md. Would you like to write release notes now? If yes, describe what changed and I'll create the file. If no, the appcast will use a placeholder that you'll need to edit manually before publishing."

If the user provides notes, create `Releases/notes-VERSION.md` with this structure:
```markdown
## What's New in VERSION

- First bullet
- Second bullet

## Bug Fixes

- First fix
- Second fix
```

## Step 7 — Pre-flight checklist

Run these checks and report results before asking the user to run the release script:

```bash
# notarytool credentials
xcrun notarytool history --keychain-profile "OpenEmu" &>/dev/null && echo "OK: notarytool" || echo "MISSING: notarytool credentials — run: xcrun notarytool store-credentials OpenEmu"

# gh CLI auth
gh auth status &>/dev/null && echo "OK: gh CLI" || echo "MISSING: gh not authenticated — run: gh auth login"

# Developer ID cert
security find-identity -v | grep -q "Developer ID Application" && echo "OK: Developer ID cert" || echo "MISSING: Developer ID certificate not in keychain"

# sentry-cli (non-fatal)
command -v sentry-cli &>/dev/null && (sentry-cli info &>/dev/null && echo "OK: sentry-cli" || echo "WARNING: sentry-cli not authenticated — run: sentry-cli login") || echo "WARNING: sentry-cli not installed (dSYMs won't upload)"
```

If any required check (notarytool, gh, Developer ID) fails, stop and tell the user what to fix. sentry-cli is a warning only — do not block.

## Step 8 — Hand off to the user

Report a summary of everything completed, then give the user the exact command to run:

```
Everything is ready. When you have finished testing, run:

  ./Scripts/release.sh VERSION Releases/notes-VERSION.md

The script will archive, notarize, sign for Sparkle, update appcast.xml, and create a draft GitHub Release.
When the script finishes, review the draft at:
  https://github.com/nickybmon/OpenEmu-Silicon/releases

Then publish with:
  gh release edit vVERSION --draft=false --repo nickybmon/OpenEmu-Silicon
```

Do NOT run the release script yourself. The user runs it manually because it takes 10–20 minutes and requires interactive confirmation from Apple's notarization service.
