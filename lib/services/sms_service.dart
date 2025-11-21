import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<bool> requestPermission() async {
    if (kIsWeb) return true; // Always "granted" on web
    var status = await Permission.sms.status;
    if (status.isDenied) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  Future<List<SmsMessage>> getMessages() async {
    if (kIsWeb) {
      // Return empty list for web (no mock messages needed)
      return [];
    }

    final permission = await requestPermission();
    if (!permission) {
      throw Exception("SMS permission not granted");
    }

    return await _query.querySms(
      kinds: [SmsQueryKind.inbox],
    );
  }
}
