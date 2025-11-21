# Release v1.1.0 - Enhanced Duplicate Detection & Updated App Icon

## 🎉 What's New

### ✨ Major Features
- **Transaction ID Extraction** - Automatically extract and store unique transaction IDs from SMS messages
- **Smart Duplicate Detection** - Prevents the same transaction from being added multiple times using transaction IDs
- **Enhanced SMS Filtering** - Now only processes SMS from verified sources: MoMo, AirtelMoney, and StanChartZM
- **Promotional Message Blocking** - Automatically rejects promotional messages without transaction IDs
- **New App Icon** - Beautiful transparent icon with larger logo and no text for better visibility

### 🔧 Technical Improvements
- Database upgraded to version 3 (added `transactionId` column)
- Robust regex pattern for extracting transaction IDs from various SMS formats
- Improved duplicate checking: Primary by transactionId, fallback to body+date
- Android adaptive icon support for better launcher integration

### 🎨 Design Updates
- Replaced small logo with text to a larger, cleaner icon-only design
- Transparent PNG background for seamless integration with device launchers
- Premium orange & sky blue gradient maintained

### 🗑️ Removed
- FNB bank SMS parsing support (focusing on mobile money providers only)
- Desktop platform support (macOS, Linux, Windows, Web) - mobile-only focus

### 🔒 Privacy & Security
- **100% Offline Operation** - No internet connection required
- **Zero Data Collection** - No personal information ever collected
- **Firewall-Proof** - Works perfectly even when blocked by mobile firewalls
- See [PRIVACY.md](https://github.com/chilusoft/wealth-wave/blob/main/PRIVACY.md) for complete details

## 📱 Installation

1. Download the `wealth-wave-v1.1.0.apk` file below
2. **Disable Google Play Protect** (see README for instructions)
3. Install the APK on your Android device
4. Grant SMS and Storage permissions when prompted
5. Start tracking your expenses automatically!

## ⚠️ Important Notes

### Google Play Protect
Since this app is not available on the Google Play Store, you'll need to temporarily disable Google Play Protect to install it:
- Open Google Play Store → Profile → Play Protect → Settings
- Turn off "Scan apps with Play Protect"
- Install the app
- You can re-enable Play Protect after installation

### Privacy Verification
Don't just trust us - verify yourself:
- Block the app with a mobile firewall (NetGuard, AFWall+)
- The app will continue to work perfectly
- This proves no data leaves your device

## 📋 Full Changelog

See [CHANGELOG.md](https://github.com/chilusoft/wealth-wave/blob/main/CHANGELOG.md) for detailed changes.

## 🔗 Links

- [Privacy Policy](https://github.com/chilusoft/wealth-wave/blob/main/PRIVACY.md)
- [Source Code](https://github.com/chilusoft/wealth-wave)
- [Report Issues](https://github.com/chilusoft/wealth-wave/issues)

## 💬 Support

Having issues? Open an issue on our [GitHub Issues page](https://github.com/chilusoft/wealth-wave/issues).

---

**APK Size:** 51.9 MB  
**Minimum Android Version:** API 21 (Android 5.0 Lollipop)  
**Target Android Version:** API 34 (Android 14)

**SHA256 Checksum:** (Will be added after upload)

---

Made with ❤️ for Zambian mobile money users  
*Your financial data is yours alone. We don't want it, we don't need it, we never collect it.*
