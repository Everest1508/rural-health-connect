# Releases

This directory contains release builds of the Rural Health Connect Flutter application.

## Structure

```
releases/
├── android/
│   ├── rural-health-connect-v1.0.0-build1.apk    # Android APK
│   └── rural-health-connect-v1.0.0-build1.aab    # Android App Bundle
└── README.md
```

## Building Releases

### Using GitHub Actions (Recommended)

1. **Automatic on Tag Push**: Push a version tag to trigger automatic build:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Manual Trigger**: Go to Actions tab in GitHub and manually trigger the "Build Flutter Release" workflow.

### Manual Build

1. Navigate to the Flutter app directory:
   ```bash
   cd flutter_app
   ```

2. Run the build script:
   ```bash
   # Build both APK and App Bundle
   ./build_release.sh both
   
   # Build only APK
   ./build_release.sh apk
   
   # Build only App Bundle
   ./build_release.sh appbundle
   ```

3. Or use Flutter commands directly:
   ```bash
   # Build APK
   flutter build apk --release
   
   # Build App Bundle (for Play Store)
   flutter build appbundle --release
   ```

## Versioning

The version is defined in `flutter_app/pubspec.yaml`:
```yaml
version: 1.0.0+1
```

Format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes
- **BUILD_NUMBER**: Incremental build number

## Release Notes

When creating a GitHub release, include:
- Version number
- New features
- Bug fixes
- Known issues
- Installation instructions

## Distribution

- **APK**: Direct installation on Android devices
- **AAB**: Upload to Google Play Store

