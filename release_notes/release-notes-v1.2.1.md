# Wealth Wave v1.2.1 Release Notes

## 🐛 Bug Fixes

### 💾 Persistence
- **Fixed**: Deleted transactions no longer reappear after refreshing/syncing SMS.
- **New**: Added a `deleted_transactions` table to track and respect user deletions.

### 📩 Airtel Money Parsing
- **Fixed**: Improved detection for Airtel Money SMS messages.
- **Enhanced**: Added support for multiple Transaction ID formats:
    - `Reference: ...`
    - `Trans ID: ...`
    - IDs appearing at the start of the message.
- **Sender Name**: Now correctly identifies `AirtelMoney` (case-insensitive).

## 📦 Installation

1.  Download `WealthWave_v1.2.1.apk`.
2.  Install on your Android device.
3.  **Note**: You may need to uninstall the previous version if you encounter signature conflicts (though usually an update works fine).
