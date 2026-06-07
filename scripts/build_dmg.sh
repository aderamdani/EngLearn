#!/bin/bash
set -e

APP_NAME="EngLearn"
VERSION=$(grep MARKETING_VERSION ${APP_NAME}.xcodeproj/project.pbxproj \
    | head -1 | sed 's/.*= //' | sed 's/;.*//' | tr -d ' ')
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
BUILD_DIR="dist"
ARCHIVE_PATH="${BUILD_DIR}/${APP_NAME}.xcarchive"

echo "=== Building ${APP_NAME} v${VERSION} ==="

# 1. Clean previous
rm -rf "${BUILD_DIR}/${APP_NAME}.app" "${BUILD_DIR}/${DMG_NAME}"
mkdir -p "${BUILD_DIR}"

# 2. Clean DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/${APP_NAME}-*

# 3. Archive (ARM64 only)
echo "Archiving..."
xcodebuild -project ${APP_NAME}.xcodeproj \
    -scheme ${APP_NAME} \
    -configuration Release \
    -destination 'platform=macOS,arch=arm64' \
    ARCHS=arm64 \
    -archivePath "${ARCHIVE_PATH}" \
    archive 2>&1 | xcbeautify

# 4. Export
echo "Exporting..."
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${BUILD_DIR}" \
    -exportOptionsPlist ExportOptions.plist 2>&1 | xcbeautify

# 5. Generate DMG background
if [ -f "generate_dmg_background.swift" ]; then
    swift generate_dmg_background.swift
fi

# 6. Create DMG
echo "Creating DMG..."
mkdir -p "${BUILD_DIR}/dmg_staging"
cp -R "${BUILD_DIR}/${APP_NAME}.app" "${BUILD_DIR}/dmg_staging/"
ln -s /Applications "${BUILD_DIR}/dmg_staging/Applications"

hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${BUILD_DIR}/dmg_staging" \
    -ov -format UDZO \
    "${BUILD_DIR}/${DMG_NAME}"

# 7. Cleanup
rm -rf "${BUILD_DIR}/dmg_staging" "${ARCHIVE_PATH}"

echo "=== DMG created: ${BUILD_DIR}/${DMG_NAME} ==="
