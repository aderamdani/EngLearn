#!/bin/bash
set -e

DMG_PATH="$1"

if [ -z "$DMG_PATH" ]; then
    DMG_PATH=$(ls dist/EngLearn-*.dmg 2>/dev/null | head -1)
fi

if [ -z "$DMG_PATH" ]; then
    echo "Error: No DMG found. Run build_dmg.sh first."
    exit 1
fi

echo "=== Notarizing: ${DMG_PATH} ==="

# Submit
xcrun notarytool submit "$DMG_PATH" \
    --apple-id "${APPLE_ID}" \
    --password "${APP_PASSWORD}" \
    --team-id "${TEAM_ID}" \
    --wait

# Staple
echo "Stapling ticket..."
xcrun stapler staple "$DMG_PATH"

# Verify
echo "Verifying..."
spctl --assess --type open --context context:primary-signature \
    --verbose=2 "$DMG_PATH"

echo "=== Notarization complete ==="
