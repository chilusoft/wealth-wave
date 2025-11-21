# 💰 Wealth Wave - Smart Expense Tracker

<p align="center">
  <img src="assets/app_icon.png" alt="Wealth Wave Logo" width="150"/>
</p>

**Wealth Wave** is a smart, privacy-focused mobile money expense tracker for Zambia. The app automatically reads your mobile money transaction SMS from MoMo, AirtelMoney, and StanChart to help you track your income and expenses effortlessly.

## 🔒 Privacy & Security - 100% Offline

> **⚠️ IMPORTANT PRIVACY NOTICE**
> 
> **Wealth Wave NEVER collects, stores, or transmits any of your personal information.**
> 
> - ✅ All SMS data is read and processed **entirely on your device**
> - ✅ No internet connection required for core functionality
> - ✅ No data is sent to any server or third party
> - ✅ Your financial information stays **100% private** and **100% offline**
> - ✅ All transaction data is stored locally on your device only
> - ✅ No analytics, no tracking, no data collection whatsoever

**Your privacy is our top priority. What happens on your phone, stays on your phone.**

### 🔥 Firewall Test - Prove It Yourself!

**Don't just take our word for it - verify it yourself:**

You can block Wealth Wave's internet access using any mobile firewall app (NetGuard, AFWall+, etc.) and the app will **continue to work perfectly**. This proves that no data ever leaves your device.

Try it:
1. Install a firewall app (e.g., NetGuard from F-Droid)
2. Block Wealth Wave's internet access completely
3. Use the app normally - all features work!

**See [PRIVACY.md](PRIVACY.md) for our complete privacy policy.**

## 📱 Installation Instructions

### Option 1: Download from Releases
1. Go to the [Releases](https://github.com/chilusoft/wealth-wave/releases) page
2. Download the latest `.apk` file
3. Follow the installation steps below

### Option 2: Build from Source
```bash
git clone https://github.com/chilusoft/wealth-wave.git
cd wealth-wave
flutter pub get
flutter build apk --release
```

### ⚠️ Important: Disable Google Play Protect

Since this app is not available on the Google Play Store, you'll need to disable Google Play Protect to install it:

1. **Before Installing:**
   - Open **Google Play Store** on your device
   - Tap your **profile icon** (top right)
   - Go to **Play Protect**
   - Tap the **Settings gear icon** (top right)
   - Turn off **"Scan apps with Play Protect"**

2. **Install the APK:**
   - Transfer the `.apk` file to your device
   - Open the file and tap **Install**
   - If prompted, allow installation from unknown sources

3. **After Installing (Optional):**
   - You can re-enable Play Protect if desired
   - The app will continue to work normally

> **Why disable Play Protect?**  
> Google Play Protect may flag apps not published on the Play Store as potentially harmful, even when they're completely safe. Since Wealth Wave is open source and built independently, it requires this step for installation.

## ✨ Features

- 📨 **Automatic SMS Parsing** - Reads transaction SMS from MoMo, AirtelMoney, and StanChart
- 🔍 **Smart Filtering** - Only processes verified transaction messages (no promotional SMS)
- 🚫 **Duplicate Prevention** - Automatically detects and prevents duplicate transactions
- 📊 **Financial Overview** - Track your balance, income, and expenses at a glance
- 🔎 **Advanced Search** - Filter by date range, search query, and source
- 💳 **Transaction Details** - View detailed information for each transaction
- 🎨 **Beautiful UI** - Modern design with smooth animations
- 🌙 **Clean Interface** - Minimalistic and easy to use

## 🏦 Supported Mobile Money Providers

- **MoMo** (MTN Mobile Money)
- **AirtelMoney**
- **StanChart** (Standard Chartered Bank Zambia)

## 🛠️ Technical Details

- **Platform:** Android & iOS (Mobile-only)
- **Framework:** Flutter
- **Database:** SQLite (local storage)
- **Permissions Required:**
  - 📱 SMS Read Permission (to parse transaction messages)
  - 💾 Storage Permission (to save data locally)

## 📋 Permissions Explanation

Wealth Wave requires the following permissions:

| Permission | Why We Need It |
|------------|----------------|
| **Read SMS** | To automatically detect and parse mobile money transaction messages |
| **Storage** | To save your transaction history on your device |

**We only read SMS from verified mobile money providers. All other SMS are completely ignored.**

## 🔐 Open Source & Transparent

This app is fully open source. You can:
- ✅ Review the entire source code
- ✅ Verify that no data is collected or transmitted
- ✅ Build the app yourself from source
- ✅ Contribute improvements or report issues

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed release notes.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 💬 Support

If you encounter any issues or have questions:
- Open an issue on [GitHub Issues](https://github.com/chilusoft/wealth-wave/issues)
- Check existing issues for solutions

## ⚖️ Disclaimer

This app is provided as-is for personal use. While we strive for accuracy in parsing transaction SMS, always verify important financial information with your mobile money provider's official statements.

---

**Made with ❤️ for Zambian mobile money users**

*Your financial data is yours alone. We don't want it, we don't need it, we never collect it.*
