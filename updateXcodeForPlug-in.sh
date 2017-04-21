#!/bin/sh
read -s -p "Input password:" password
echo "$password" | sudo -S ls &> /dev/null
#password correct
if [ "$?" == "0" ]
then
	echo "\nThe whole process takes 30 minutes to 45 minutes, if the use of solid state disk this time will be shorter!"

	pkill -f /Applications/XcodeUnsigner.app/Contents/MacOS/Xcode 
	rm -rf /Applications/XcodeUnsigner.app
	
	echo "Create XcodeUnsigner.app"
	cp -R /Applications/Xcode.app /Applications/XcodeUnsigner.app
	
	cp -R ~/Library/Developer/Xcode/UserData/ ./UserData
	
	echo "Check whether there is a code signing certificate..."
	security find-identity -v -p appleID > appleID
	if !(grep -q "XcodeSigner" appleID)
	then
		security unlock-keychain -p $password
		security import ./XcodeSigner.p12 -P 111111
	fi
	
	echo "Instead of Xcode signature, Need to wait about 10 minutes!"
	echo $password | sudo -S codesign -f -s XcodeSigner /Applications/XcodeUnsigner.app &> /dev/null
	
	echo "Clean Xcode's data,Prevent XcodeUnsigner.app flash back"
	rm -rf ~/Library/Developer/
	rm -rf ~/Library/Application\ Support/Developer/
	rm -rf ~/Library/Application\ Support/Xcode
	
	
	echo "Copy backup data"
	if [ ! -d "~/Library/Application\ Support/Developer" ]; then
	  mkdir -p ~/Library/Application\ Support/Developer/Shared/Xcode/
	fi
	if [ ! -d "~/Library/Developer/Xcode/" ]; then
	  mkdir -p ~/Library/Developer/Xcode/
	fi
	cp -R ./UserData ~/Library/Developer/Xcode/
	cp -R ./Plug-ins ~/Library/Application\ Support/Developer/Shared/Xcode/
	find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/XcodeUnsigner.app/Contents/Info.plist DVTPlugInCompatibilityUUID`
	open /Applications/XcodeUnsigner.app
	
	rm -rf UserData/ appleID
	
	echo "Success"	
else
	echo "\nPassword incorrect"
	exit
fi
