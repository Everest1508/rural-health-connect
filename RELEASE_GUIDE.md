# Release Guide

This guide explains how to create and manage releases for the Rural Health Connect Flutter application.

## Quick Start

### Creating a Release

1. **Using the release script** (recommended):
   ```bash
   ./scripts/create_release.sh 1.0.0 "Initial release"
   ```
   This will:
   - Update the version in `pubspec.yaml`
   - Create a git tag
   - Push to GitHub
   - Trigger GitHub Actions to build the release

2. **Manual process**:
   ```bash
   # Update version in flutter_app/pubspec.yaml
   # Then create and push tag:
   git tag v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

### Building Locally

If you want to build releases locally:

```bash
cd flutter_app
./build_release.sh both  # Builds both APK and AAB
```

Or build individually:
```bash
flutter build apk --release        # For APK
flutter build appbundle --release  # For App Bundle (Play Store)
```

## Version Numbering

The version format is: `MAJOR.MINOR.PATCH+BUILD_NUMBER`

Example: `1.0.0+1`
- `1.0.0` = Version number (semantic versioning)
- `+1` = Build number (auto-incremented)

### Semantic Versioning Guidelines

- **MAJOR** (1.0.0): Breaking changes, incompatible API changes
- **MINOR** (0.1.0): New features, backward compatible
- **PATCH** (0.0.1): Bug fixes, backward compatible

## GitHub Actions Workflow

The `.github/workflows/build-release.yml` workflow automatically:

1. **Triggers on**:
   - Version tags (e.g., `v1.0.0`)
   - Manual workflow dispatch from GitHub Actions tab

2. **Builds**:
   - Android APK (for direct installation)
   - Android App Bundle (for Google Play Store)

3. **Creates**:
   - GitHub Release with attached artifacts
   - Artifacts available for download

## Release Checklist

Before creating a release:

- [ ] Update `CHANGELOG.md` (if exists)
- [ ] Test the app thoroughly
- [ ] Update version in `pubspec.yaml` (or use release script)
- [ ] Commit all changes
- [ ] Create release tag
- [ ] Push tag to trigger build
- [ ] Verify GitHub Actions build succeeds
- [ ] Review and publish GitHub release
- [ ] Update release notes on GitHub

## Distribution

### Android APK
- Direct installation on Android devices
- Share via file sharing services
- Upload to alternative app stores

### Android App Bundle (AAB)
- Required for Google Play Store
- Upload via Google Play Console
- Better optimization and smaller download size

## Troubleshooting

### Build Fails
1. Check GitHub Actions logs
2. Verify Flutter version compatibility
3. Ensure all dependencies are up to date
4. Run `flutter clean` and rebuild

### Version Not Updating
- Ensure `pubspec.yaml` is committed
- Check that the tag format is correct (`v*.*.*`)
- Verify GitHub Actions workflow is triggered

### Artifacts Not Appearing
- Check GitHub Actions workflow status
- Verify artifact upload step completed
- Check GitHub Release page for attached files

## Files Structure

```
.
├── .github/
│   └── workflows/
│       └── build-release.yml      # GitHub Actions workflow
├── flutter_app/
│   ├── pubspec.yaml                # Version definition
│   └── build_release.sh            # Local build script
├── releases/
│   ├── android/                    # Release builds
│   └── README.md                   # Release directory info
└── scripts/
    └── create_release.sh           # Release creation script
```

## Additional Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Semantic Versioning](https://semver.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

