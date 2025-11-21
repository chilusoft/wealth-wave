# Changelog

All notable changes to the Wealth Wave expense tracker app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-11-21

### Added
- **Transaction ID Extraction**: Automatically extract and store unique transaction IDs from SMS messages
- **Duplicate Transaction Prevention**: Smart duplicate detection using transaction IDs to prevent the same transaction from being added multiple times
- **Enhanced SMS Filtering**: Only process SMS from verified sources (MoMo, AirtelMoney, StanChartZM)
- **Transaction ID Validation**: Reject promotional messages by requiring valid transaction IDs
- **Transparent App Icon**: New minimalistic app icon with transparent background and larger logo
- **Adaptive Icons**: Android adaptive icon support for better integration with different launchers

### Changed
- **Database Schema**: Upgraded to version 3, added `transactionId` column to transactions table
- **App Icon**: Replaced small logo with text with a larger, cleaner icon-only design
- **Icon Configuration**: Updated to use transparent PNG with proper adaptive icon setup

### Removed
- **FNB Support**: Removed FNB bank SMS parsing to focus on primary mobile money providers
- **Alpha Channel Removal**: Disabled iOS alpha channel removal to preserve transparent backgrounds

### Fixed
- **Duplicate Transactions**: Transactions with the same transaction ID will no longer create duplicates in the database
- **Promotional SMS**: Non-transactional promotional messages are now automatically filtered out
- **Icon Visibility**: App icon is now larger and more visible on device home screens

### Technical Details
- Database migration from v2 to v3 (automatic, non-breaking)
- New regex pattern for transaction ID extraction: matches various formats (Txn Id, Ref, Transaction No, etc.)
- Duplicate checking logic: Primary by transactionId, fallback to body+date for legacy transactions
- Supported SMS sources (case-insensitive): MoMo, MTN, Airtel, StanChart, SCB, StanChartZM

### Breaking Changes
None - This is a backward-compatible update. Existing transactions without transaction IDs will continue to work with fallback duplicate detection.

## [1.0.0] - Initial Release

### Features
- SMS reading and parsing for transaction tracking
- Support for AirtelMoney, MoMo, StanChart, and FNB
- Transaction filtering by date range, search query, and source
- Beautiful UI with orange and sky blue color scheme
- Detailed transaction view
- Balance, income, and expense calculations
- Splash screen
- Cross-platform support (Android, iOS, Web)
