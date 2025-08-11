MacOS Version: 15.3.2
Flutter Version: 3.27.3
Xcode Version: 16.2
Android SDK Version: 35.0.1

1. Install Flutter On Mac

Download Android Studio 
Download Xcode 
Get the Flutter SDK 

MacOS Version: 15.3.2
Flutter Version: 3.27.3
Xcode Version: 16.2
Android SDK Version: 35.0.1

2. Install Flutter And Dart Plugins

Android Studio
Go to Preferences or Settings.
Select Plugins from the left sidebar.
Click on the Marketplace tab.
Search for "Flutter" in the search bar.

Visual Studio Code
Go to the Extensions view by clicking on the square icon in the Sidebar.
Search for "Flutter" in the Extensions Marketplace.

Open terminal and run: flutter pub get

3. Register your app on Firebase.
For IOS:
Make sure that GoogleService-Info.plist is the name of the file you downloaded from Firebase.
Move or copy the GoogleService-Info.plist into the [My_project]/ios/Runner folder.
For Android:
Just need to change the android/app/google-services.json file.
Create a new firebase account, register your application with your package name.
Then download the google-services.json file and replace with curren

Android Configuration:
Change bundle id:
Go to android/app/build.gradle and find defaultConfig, change the applicationId to yours.

IOS Configuration:
Open Project in Xcode
Navigate to the directory of your Flutter project. Look for a file with the extension ".xcworkspace" or ".xcodeproj"
- Open Runner.xcodeproj
Go to Runner in 'TARGETS' tab and find 'Singing & Capabilities', register your own dev accout and 
replace the 'Bundle identifier' with your owns either in 'General' or 'Singing & Capabilities' tab.
Go to Runner in 'TARGETS' tab and find 'Build Settings' and find 'Deployment'. Setup the IOS Deployment Target to 'IOS 14.0'
- Open Runner.xcworkspace
Go to Runner in 'TARGETS' tab and find 'General', setup the Miunimum Deployments to IOS 14.0
Go to Runner in 'TARGETS' tab and find 'Singing & Capabilities'. Do the same setup as above.

Open terminal cd ios and run: pod install

4. apk generation
At root folder run: flutter build apk


