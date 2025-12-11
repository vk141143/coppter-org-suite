# iOS Build Setup

## File Structure Created

```
ios/
├── Flutter/
│   ├── AppFrameworkInfo.plist
│   ├── Debug.xcconfig
│   └── Release.xcconfig
├── Runner/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   │   └── Contents.json
│   │   └── LaunchImage.imageset/
│   │       └── Contents.json
│   ├── Base.lproj/
│   │   ├── LaunchScreen.storyboard
│   │   └── Main.storyboard
│   ├── AppDelegate.swift
│   ├── Info.plist
│   └── Runner-Bridging-Header.h
├── Runner.xcodeproj/
│   └── project.pbxproj
├── Runner.xcworkspace/
│   └── contents.xcworkspacedata
├── .gitignore
└── Podfile
```

## Setup Instructions

### 1. Install Dependencies
```bash
cd ios
pod install
```

### 2. Open in Xcode
```bash
open Runner.xcworkspace
```

### 3. Configure Signing
- Open Xcode
- Select Runner project
- Go to Signing & Capabilities
- Select your Team
- Update Bundle Identifier: `com.yourcompany.wastemanagement`

### 4. Build & Run
```bash
# From project root
flutter run -d ios

# Or from Xcode
# Select target device and press Run (Cmd+R)
```

## App Configuration

### Bundle Identifier
Update in `Runner.xcodeproj` and `Info.plist`:
- Current: `com.example.wasteManagementApp`
- Change to: `com.yourcompany.wastemanagement`

### App Name
- Display Name: "Waste Management"
- Bundle Name: "waste_management_app"

### Permissions Configured
- Camera Usage: For uploading waste images
- Photo Library: For selecting images
- Location When In Use: For tracking waste pickup

### Minimum iOS Version
- iOS 12.0+

## App Icons
Place your app icons in:
`Runner/Assets.xcassets/AppIcon.appiconset/`

Required sizes:
- 20x20 (@1x, @2x, @3x)
- 29x29 (@1x, @2x, @3x)
- 40x40 (@1x, @2x, @3x)
- 60x60 (@2x, @3x)
- 76x76 (@1x, @2x)
- 83.5x83.5 (@2x)
- 1024x1024 (@1x)

## Launch Images
Place launch images in:
`Runner/Assets.xcassets/LaunchImage.imageset/`

Required:
- LaunchImage.png (@1x)
- LaunchImage@2x.png (@2x)
- LaunchImage@3x.png (@3x)

## Build Configurations

### Debug
- Development mode
- Hot reload enabled
- Debug symbols included

### Release
- Production mode
- Optimized build
- Code signing required

## Troubleshooting

### Pod Install Issues
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

### Signing Issues
- Ensure you have a valid Apple Developer account
- Check provisioning profiles in Xcode
- Update Bundle Identifier to unique value

### Build Errors
```bash
# Clean build
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
flutter run -d ios
```

## Next Steps

1. Add app icons (1024x1024 and all required sizes)
2. Add launch screen images
3. Configure code signing with your Apple Developer account
4. Test on physical iOS device
5. Prepare for App Store submission

## App Store Submission Checklist

- [ ] App icons (all sizes)
- [ ] Launch screen
- [ ] Privacy policy URL
- [ ] App description and keywords
- [ ] Screenshots (all device sizes)
- [ ] App Store Connect account
- [ ] Code signing certificates
- [ ] Provisioning profiles
- [ ] TestFlight testing
- [ ] App review information

## Resources

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
