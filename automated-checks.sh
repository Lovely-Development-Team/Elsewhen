FILE=build
if test -f "$FILE"; then
    # Bump the build version
	agvtool bump
	# Store the new build number for use in commit
	NEW_BUILD=$(agvtool what-version -terse)
	PROJECT_FILE=$(find . -maxdepth 1 -name '*.xcodeproj')
	# Build the app and upload
	xcodebuild -project "$PROJECT_FILE" -scheme "Discord Helper" -configuration Release -archivePath ./app.xcarchive  archive
	xcodebuild -exportArchive -archivePath ./app.xcarchive -exportOptionsPlist exportOptions.plist
	# PR with new version number
	git checkout -B "release/$NEW_BUILD"
	rm build
	git add "$PROJECT_FILE/project.pbxproj"
	git add build
	git commit -m "Bump build ($NEW_BUILD)"
	gh pr create --title "Release $NEW_BUILD"
	git checkout main
fi
