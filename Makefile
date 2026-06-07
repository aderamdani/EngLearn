SCHEME = EngLearn
PROJECT = EngLearn.xcodeproj
DEST = 'platform=macOS,arch=arm64'
CONFIG_DEBUG = Debug
CONFIG_RELEASE = Release

.PHONY: build run test clean archive dmg version lint

build:
	xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIG_DEBUG) \
		-destination $(DEST) \
		ARCHS=arm64 \
		build 2>&1 | xcbeautify

run: build
	@open -a "$$(find ~/Library/Developer/Xcode/DerivedData \
		-name '$(SCHEME).app' -path '*/Debug/*' | head -1)"

test:
	xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIG_DEBUG) \
		-destination $(DEST) \
		-enableCodeCoverage YES \
		test 2>&1 | xcbeautify

clean:
	xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		clean 2>&1 | xcbeautify
	rm -rf ~/Library/Developer/Xcode/DerivedData/$(SCHEME)-*

archive:
	xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIG_RELEASE) \
		-destination $(DEST) \
		ARCHS=arm64 \
		-archivePath dist/$(SCHEME).xcarchive \
		archive 2>&1 | xcbeautify

dmg: archive
	bash scripts/build_dmg.sh

lint:
	swiftlint lint --strict

version:
	@grep MARKETING_VERSION $(PROJECT)/project.pbxproj \
		| head -1 | sed 's/.*= //' | sed 's/;.*//'
