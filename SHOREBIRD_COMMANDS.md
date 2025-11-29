# 🚀 Shorebird Commands Reference

## Quick Reference

| Situation | Command |
|-----------|---------|
| First time publishing | `shorebird release android/ios` |
| Bug fix | `shorebird patch android/ios` |
| UI change | `shorebird patch android/ios` |
| Text update | `shorebird patch android/ios` |
| New Dart package | `shorebird patch android/ios` |
| New native package | `shorebird release android/ios` |
| Flutter SDK update | `shorebird release android/ios` |
| Check patches | `shorebird patches list` |
| Check releases | `shorebird releases list` |
| Preview patch | `shorebird patch --dry-run` |

---

## Understanding Shorebird Updates

### **Two Types of Updates:**

1. **Full Release** - For major changes (new native code, dependencies, etc.)
2. **Patch** - For minor Dart code changes (bug fixes, UI tweaks, etc.)

---

## 📦 Initial Release Commands

### First Time Publishing or Major Updates

Use when:
- First time publishing your app
- Adding/updating native dependencies
- Changing native code (Android/iOS)
- Updating Flutter SDK version
- Major version bump

```bash
# For Android
shorebird release android

# For iOS
shorebird release ios

# For both platforms
shorebird release android
shorebird release ios
```

**After running these commands:**
- Upload the generated APK/AAB to Google Play Store
- Upload the generated IPA to Apple App Store

---

## 🔧 Patch Commands (Most Common)

### Deploy Bug Fixes & Minor Updates

Use when:
- Fixing bugs in Dart code
- Updating UI/text
- Changing business logic
- Any Dart-only changes

```bash
# For Android
shorebird patch android

# For iOS  
shorebird patch ios

# For both platforms
shorebird patch android
shorebird patch ios

# With a descriptive message
shorebird patch android --message "Fixed login bug"
shorebird patch ios --message "Fixed login bug"
```

**Benefits:**
- No app store submission required
- Users get updates within minutes
- No review process needed

---

## 🔍 Preview & Testing Commands

### Preview Before Deploying

```bash
# Dry run - see what will be patched without deploying
shorebird patch android --dry-run
shorebird patch ios --dry-run

# Create a preview build for testing
shorebird preview
```

---

## 📊 Status & Information Commands

### Check Releases

```bash
# List all releases
shorebird releases list

# Get details about a specific release
shorebird releases info <release-version>
```

### Check Patches

```bash
# List all patches for current release
shorebird patches list

# Check patch status
shorebird patch android --status
shorebird patch ios --status
```

### Account Information

```bash
# Check current account
shorebird account

# Login to Shorebird
shorebird login

# Logout
shorebird logout
```

---

## 🔄 Rollback & Management Commands

### Promote a Previous Patch

```bash
# If a patch has issues, promote a previous working patch
shorebird patch promote <patch-id>
```

### Delete a Patch

```bash
# Delete a specific patch (use with caution)
shorebird patch delete <patch-id>
```

---

## 📋 Common Workflows

### Workflow 1: Daily Bug Fix

```bash
# 1. Fix the bug in your code
# 2. Test locally
flutter run

# 3. Deploy the patch
shorebird patch android
shorebird patch ios
```

### Workflow 2: New Dart-Only Feature

```bash
# 1. Implement the feature
# 2. Test thoroughly
flutter run

# 3. Preview the patch
shorebird patch android --dry-run

# 4. Deploy if preview looks good
shorebird patch android --message "Added new feature"
shorebird patch ios --message "Added new feature"
```

### Workflow 3: Adding a New Package

```bash
# 1. Add package to pubspec.yaml
flutter pub add package_name

# 2. Check if it's Dart-only or has native code
flutter pub deps

# 3a. If Dart-only package:
shorebird patch android
shorebird patch ios

# 3b. If package has native code:
shorebird release android
shorebird release ios
# Then upload to app stores
```

### Workflow 4: Text/Translation Update

```bash
# 1. Update translation files
# 2. Test changes
flutter run

# 3. Deploy patch (fastest way to update users!)
shorebird patch android --message "Updated translations"
shorebird patch ios --message "Updated translations"
```

---

## ✅ What Can Be Patched

### Safe to Patch (Use `shorebird patch`):
- ✅ Bug fixes in Dart code
- ✅ UI changes and tweaks
- ✅ Text and translation updates
- ✅ Business logic changes
- ✅ Performance improvements (Dart code)
- ✅ Analytics updates
- ✅ Dart-only package additions
- ✅ Asset changes (images, fonts)

### Requires Full Release (Use `shorebird release`):
- ❌ Adding native dependencies
- ❌ Updating Flutter SDK
- ❌ Changing AndroidManifest.xml
- ❌ Changing Info.plist
- ❌ Adding permissions
- ❌ Changing app icons
- ❌ Changing splash screens
- ❌ Native code changes
- ❌ Major version updates

---

## 🎯 Best Practices

### 1. Always Test Before Patching
```bash
# Use dry-run to preview
shorebird patch android --dry-run
shorebird patch ios --dry-run
```

### 2. Add Descriptive Messages
```bash
# Good practice
shorebird patch android --message "Fixed crash on login screen"

# Instead of
shorebird patch android
```

### 3. Test Patches on Staging First
```bash
# Create a preview build
shorebird preview

# Test thoroughly before deploying to production
```

### 4. Monitor Patch Adoption
- Check your app analytics
- Monitor crash reports
- Use the update service we implemented to track patch numbers

### 5. Keep Track of Patches
```bash
# Regularly check what patches are deployed
shorebird patches list
```

---

## 🚨 Troubleshooting

### Patch Failed to Apply

```bash
# Check the error message
shorebird patch android --verbose

# Try dry-run to see what's wrong
shorebird patch android --dry-run
```

### Users Not Getting Updates

```bash
# Verify patch was created successfully
shorebird patches list

# Check if auto_update is configured correctly in shorebird.yaml
# In our case, we set auto_update: false for manual control
```

### Rollback a Bad Patch

```bash
# List all patches
shorebird patches list

# Promote a previous working patch
shorebird patch promote <previous-patch-id>
```

---

## 📱 Testing Your Patches

After creating a patch:

1. **Wait 2-3 minutes** for the patch to propagate
2. **Close your app completely** (kill it from recent apps)
3. **Reopen the app**
4. **You should see the update notification** (from our ShorebirdUpdateService)
5. **Tap "Update Now"** and verify the changes
6. **Restart the app** to see the patch applied

---

## 💡 Pro Tips

### Tip 1: Version Your Patches
```bash
# Keep your version numbers updated in pubspec.yaml
# version: 1.0.0+1 -> 1.0.0+2 (for patches)
# version: 1.0.0+1 -> 1.1.0+1 (for releases)
```

### Tip 2: Use Git Tags
```bash
# Tag your releases and patches
git tag -a v1.0.0-patch.1 -m "Fixed login bug"
git push origin v1.0.0-patch.1
```

### Tip 3: Automate with CI/CD
```bash
# Example GitHub Actions workflow
# Create patches automatically on merge to main
shorebird patch android --message "${{ github.event.head_commit.message }}"
```

### Tip 4: Monitor Logs
```bash
# Our ShorebirdUpdateService logs all operations
# Check your app logs to see:
# - Current patch number
# - Update check results
# - Download status
```

---

## 🔗 Useful Links

- [Shorebird Documentation](https://docs.shorebird.dev)
- [Shorebird Console](https://console.shorebird.dev)
- [Shorebird Discord](https://discord.gg/shorebird)

---

## 📝 Your Typical Daily Workflow

```bash
# 1. Make your changes in the code
# 2. Test locally
flutter run

# 3. Check if changes are patch-eligible
shorebird patch android --dry-run

# 4. If successful, deploy the patch
shorebird patch android --message "Brief description of changes"
shorebird patch ios --message "Brief description of changes"

# 5. Wait 2-3 minutes and test on a device
# 6. Monitor user adoption through analytics
```

---

## 🎉 Summary

**For 90% of your updates:**
```bash
shorebird patch android
shorebird patch ios
```

**For major updates:**
```bash
shorebird release android
shorebird release ios
# Then upload to stores
```

**That's it!** Shorebird makes it incredibly easy to push updates without app store reviews. 🚀
