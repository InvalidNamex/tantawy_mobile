# 🚀 Quick Start Guide

## Prerequisites
- Flutter SDK installed
- Android device/emulator or iOS simulator
- Backend API running at `http://127.0.0.1:8000/`

## Run the App (3 Steps)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Code (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run
```bash
flutter run
```

## First Time Setup

1. **Start Backend API**
   - Make sure your Django backend is running at `http://127.0.0.1:8000/`

2. **Login**
   - Open the app
   - Enter agent username and password
   - First login requires internet connection
   - App will fetch and cache all data

3. **Test Offline Mode**
   - Turn off internet
   - App should still work with cached data
   - Create transactions (they'll be saved locally)

4. **Sync Data**
   - Turn internet back on
   - Tap sync button in AppBar
   - All pending transactions will be uploaded

## Default Settings
- **Language**: Arabic (can switch to English)
- **Theme**: System (auto light/dark mode)
- **Base URL**: http://127.0.0.1:8000/

## Features to Test

### ✅ Visit Plan
- View all customers from active visit plan
- Tap customer to expand actions
- 4 buttons: Sale, Return Sale, Voucher, Negative Visit

### ✅ Sales Invoice
- Select multiple items
- Edit quantity, price, discount, VAT
- Auto-calculated totals
- Choose payment type and status
- Works online and offline

### ✅ Return Sales Invoice
- Same as sales invoice
- Different invoice type (4)

### ✅ Voucher
- Enter amount and notes
- Switch between Receive/Payment
- Works online and offline

### ✅ Negative Visit
- Enter notes
- Location auto-captured
- Works online and offline

### ✅ Sync
- Red dot shows pending data
- Tap sync to upload all pending transactions
- Requires internet connection

## Troubleshooting

### Build Errors
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Location Not Working
- Check device location is enabled
- Grant location permissions when prompted

### API Connection Failed
- Verify backend is running
- Check base URL in `lib/app/utils/constants.dart`
- For Android emulator, use `http://10.0.2.2:8000/` instead of `http://127.0.0.1:8000/`

### Hive Errors
- Delete app data and reinstall
- Or run: `flutter clean` then rebuild

## Project Files
- `README.md` - Complete project documentation
- `mobile_api.md` - API endpoints reference
- `PROJECT_STRUCTURE.md` - Folder structure guide
- `BUILD_INSTRUCTIONS.md` - Detailed build steps
- `IMPLEMENTATION_SUMMARY.md` - What's been implemented

## Support
- Check README.md for detailed documentation
- Review mobile_api.md for API details
- See IMPLEMENTATION_SUMMARY.md for feature list

---

**Ready to go!** 🎉
