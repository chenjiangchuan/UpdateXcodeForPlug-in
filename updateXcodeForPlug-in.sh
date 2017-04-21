#!/bin/sh
echo "The whole process takes 30 minutes to 45 minutes, if the use of solid state disk this time will be shorter!"
sleep 5s
echo "Delete old version XcodeUnsigner.app"
pkill -f /Applications/XcodeUnsigner.app/Contents/MacOS/Xcode 
rm -rf /Applications/XcodeUnsigner.app

echo "Create new version XcodeUnsigner.app"
cp -R /Applications/Xcode.app /Applications/XcodeUnsigner.app

echo "Backup Xcode's UserData "
cp -R ~/Library/Developer/Xcode/UserData/ .

echo "Check whether there is a code signing certificate..."
security find-identity -v -p appleID > appleID
if !(grep -q "XcodeSigner" appleID)
then
	security import ./XcodeSigner.p12 -P 111111
fi

echo "Instead of Xcode signature, Need to wait about 10 minutes!"
sudo codesign -f -s XcodeSigner /Applications/XcodeUnsigner.app

echo "Clean Xcode's data"
rm -rf ~/Library/Developer/
rm -rf ~/Library/Application\ Support/Developer/
rm -rf ~/Library/Application\ Support/Xcode

open /Applications/XcodeUnsigner.app
sleep 15s
pkill -f /Applications/XcodeUnsigner.app/Contents/MacOS/Xcode

echo "Clone and build Alcatraz..."
git clone https://github.com/alcatraz/Alcatraz.git
cd Alcatraz
xcodebuild -scheme Alcatraz build

echo "Copy backup data"
cp -R ./UserData ~/Library/Developer/Xcode/
cp -R ./Plug-ins ~/Library/Application\ Support/Developer/Shared/Xcode/
find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/XcodeUnsigner.app/Contents/Info.plist DVTPlugInCompatibilityUUID`
open /Applications/XcodeUnsigner.app

echo "Delete all downloaded files..."
#rm -rf ./UserData

echo "Success"