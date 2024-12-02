// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_Hans_CH locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_Hans_CH';

  static String m0(givenAtsign) => "atSign 不符。請提供 ${givenAtsign} 的二維碼以配對。";

  static String m1(givenAtsign) => "atSign 不符。請提供 ${givenAtsign} 的備份金鑰檔案以配對。";

  static String m2(atsign) => "${atsign} 已經與此裝置配對。請先從裝置中刪除/重置此 atSign 才能新增。";

  static String m3(contactAddress) =>
      "伺服器回應逾時！\n請檢查您的網絡連線並重試。如果問題仍然存在，請聯絡 ${contactAddress}。";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activate": MessageLookupByLibrary.simpleMessage("啟動"),
        "activate_an_atSign":
            MessageLookupByLibrary.simpleMessage("啟動一個 atSign"),
        "already_have_an_atSign":
            MessageLookupByLibrary.simpleMessage("已經有 atSign 了？"),
        "atSign_mismatches_need_to_provide_QRCode": m0,
        "atSign_mismatches_need_to_provide_backupKey": m1,
        "btn_activate_atSign":
            MessageLookupByLibrary.simpleMessage("啟動 atSign"),
        "btn_already_have_atSign":
            MessageLookupByLibrary.simpleMessage("已經有 atSign 了嗎？"),
        "btn_cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "btn_close": MessageLookupByLibrary.simpleMessage("關閉"),
        "btn_continue": MessageLookupByLibrary.simpleMessage("繼續"),
        "btn_generate_atSign":
            MessageLookupByLibrary.simpleMessage("生成一個免費 atSign"),
        "btn_no": MessageLookupByLibrary.simpleMessage("否"),
        "btn_pair": MessageLookupByLibrary.simpleMessage("配對"),
        "btn_refresh": MessageLookupByLibrary.simpleMessage("重新整理"),
        "btn_remind_me_later": MessageLookupByLibrary.simpleMessage("稍後提醒我"),
        "btn_save": MessageLookupByLibrary.simpleMessage("儲存"),
        "btn_scan_QRCode": MessageLookupByLibrary.simpleMessage("掃描二維碼"),
        "btn_skip_tutorial": MessageLookupByLibrary.simpleMessage("跳過教學"),
        "btn_upload_QRCode": MessageLookupByLibrary.simpleMessage("上傳二維碼"),
        "btn_yes": MessageLookupByLibrary.simpleMessage("是"),
        "btn_yes_continue": MessageLookupByLibrary.simpleMessage("是，繼續"),
        "enter_atSign_need_to_activate":
            MessageLookupByLibrary.simpleMessage("輸入您想啟動的 atSign"),
        "enter_code":
            MessageLookupByLibrary.simpleMessage("請輸入已發送到您的電郵地址的4位驗證碼"),
        "enter_verification_code":
            MessageLookupByLibrary.simpleMessage("輸入驗證碼"),
        "enter_your_email_address":
            MessageLookupByLibrary.simpleMessage("輸入您的電郵地址"),
        "error_activate_server":
            MessageLookupByLibrary.simpleMessage("無法啟動伺服器。請聯絡管理員。"),
        "error_atSign_activated": MessageLookupByLibrary.simpleMessage(
            "此 atSign 已啟動。請上傳您的 atKeys 以與此裝置配對"),
        "error_atSign_already_paired": m2,
        "error_atSign_logged":
            MessageLookupByLibrary.simpleMessage("此 atSign 已啟動並與此裝置配對"),
        "error_authenticated_failed":
            MessageLookupByLibrary.simpleMessage("身份驗證失敗"),
        "error_enter_valid_email":
            MessageLookupByLibrary.simpleMessage("請輸入有效的電郵地址"),
        "error_incorrect_QRFile":
            MessageLookupByLibrary.simpleMessage("二維碼檔案錯誤"),
        "error_invalid_atSign_provided":
            MessageLookupByLibrary.simpleMessage("提供的 atSign 無效。請聯絡管理員。"),
        "error_perform_operation":
            MessageLookupByLibrary.simpleMessage("無法執行讀取/寫入操作。請重試。"),
        "error_please_enter_email":
            MessageLookupByLibrary.simpleMessage("請輸入有效的電郵地址"),
        "error_process_file": MessageLookupByLibrary.simpleMessage("檔案處理失敗"),
        "error_processing": MessageLookupByLibrary.simpleMessage("處理失敗。請重試。"),
        "error_processing_files":
            MessageLookupByLibrary.simpleMessage("檔案處理失敗。請重試"),
        "error_provide_backupKey":
            MessageLookupByLibrary.simpleMessage("請提供有效的備份金鑰檔案以繼續。"),
        "error_provide_relevant_backupKey":
            MessageLookupByLibrary.simpleMessage("請提供相關的備份金鑰檔案以進行身份驗證。"),
        "error_provide_valid_QRCode":
            MessageLookupByLibrary.simpleMessage("請提供有效的二維碼以進行身份驗證。"),
        "error_server_not_found":
            MessageLookupByLibrary.simpleMessage("伺服器找不到"),
        "error_server_response_timed_out": m3,
        "error_server_unavailable":
            MessageLookupByLibrary.simpleMessage("伺服器不可用。請稍後再試。"),
        "error_unable_connect":
            MessageLookupByLibrary.simpleMessage("無法連線。請檢查網絡連線並重試。"),
        "error_unable_to_authenticate":
            MessageLookupByLibrary.simpleMessage("無法進行身份驗證。請重試。"),
        "error_unable_to_connect_server":
            MessageLookupByLibrary.simpleMessage("無法連接伺服器。請稍後再試。"),
        "error_unable_to_perform_this_action":
            MessageLookupByLibrary.simpleMessage("無法執行此操作。請重試。"),
        "error_unknown": MessageLookupByLibrary.simpleMessage("不明錯誤。"),
        "get_free_atSign": MessageLookupByLibrary.simpleMessage("取得免費 atSign"),
        "have_QRCode": MessageLookupByLibrary.simpleMessage("有二維碼嗎？"),
        "images": MessageLookupByLibrary.simpleMessage("圖片"),
        "invalid_QR": MessageLookupByLibrary.simpleMessage("二維碼無效。"),
        "learn_about_atSign":
            MessageLookupByLibrary.simpleMessage("了解更多關於 atSign 的資訊"),
        "learn_more": MessageLookupByLibrary.simpleMessage("了解更多"),
        "loading_atSigns": MessageLookupByLibrary.simpleMessage("正在載入 atSign"),
        "msg_action_cannot_undone":
            MessageLookupByLibrary.simpleMessage("警告：此操作無法復原"),
        "msg_atSign_cannot_empty":
            MessageLookupByLibrary.simpleMessage("atSign 不可為空"),
        "msg_atSign_not_registered": MessageLookupByLibrary.simpleMessage(
            "您的 atSign 尚未註冊。請嘗試使用已註冊的 atSign。"),
        "msg_atSign_required":
            MessageLookupByLibrary.simpleMessage("需要一個 atSign。"),
        "msg_atSign_unreachable": MessageLookupByLibrary.simpleMessage(
            "您的 atSign 和伺服器無法連線。請重試或聯絡 support@atsign.com"),
        "msg_auth_failed": MessageLookupByLibrary.simpleMessage("身份驗證失敗"),
        "msg_cannot_fetch_keys_from_chosen_file":
            MessageLookupByLibrary.simpleMessage("無法從已選檔案取得金鑰。請選擇正確的檔案"),
        "msg_maximum_atSign_next":
            MessageLookupByLibrary.simpleMessage("以選擇您現有的 atSign 之一。"),
        "msg_maximum_atSign_prev":
            MessageLookupByLibrary.simpleMessage("糟糕！您已經擁有最多數量的免費 atSign。請登入"),
        "msg_refresh_atSign":
            MessageLookupByLibrary.simpleMessage("重新整理直到您看到您喜歡的 atSign，然後點擊配對"),
        "msg_response_time_out": MessageLookupByLibrary.simpleMessage("回應逾時"),
        "msg_save_atKey_in_secure_location": MessageLookupByLibrary.simpleMessage(
            "請將您的金鑰儲存在安全的地方（我們建議使用 Google Drive 或 iCloud Drive）。您需要它才能再次登入和使用其他 atPlatform 應用程式。"),
        "msg_shared_storage": MessageLookupByLibrary.simpleMessage(
            "這將節省您在其他應用程式上再次整合此 atSign 的步驟。"),
        "msg_wait_fetching_atSign":
            MessageLookupByLibrary.simpleMessage("請等待擷取 atSign 狀態"),
        "no_atSigns_paired_to_reset":
            MessageLookupByLibrary.simpleMessage("沒有 atSign 需要重置。"),
        "no_permission": MessageLookupByLibrary.simpleMessage("沒有權限"),
        "note": MessageLookupByLibrary.simpleMessage("注意："),
        "note_otp_content": MessageLookupByLibrary.simpleMessage(
            "如果您沒有收到我們的電郵：\n- 確認您的電郵地址輸入正確。\n- 檢查您的垃圾郵件/垃圾郵件或促銷郵件資料夾。"),
        "note_pair_content":
            MessageLookupByLibrary.simpleMessage("注意：我們不會分享您的個人資料或將其用於牟利。"),
        "notice": MessageLookupByLibrary.simpleMessage("通知"),
        "onboarding": MessageLookupByLibrary.simpleMessage("開始使用"),
        "pair_atSign":
            MessageLookupByLibrary.simpleMessage("使用您的 atKeys 配對 atSign"),
        "processing": MessageLookupByLibrary.simpleMessage("處理中..."),
        "remove": MessageLookupByLibrary.simpleMessage("移除"),
        "resend_code": MessageLookupByLibrary.simpleMessage("重新傳送驗證碼"),
        "reset": MessageLookupByLibrary.simpleMessage("重置"),
        "reset_description": MessageLookupByLibrary.simpleMessage(
            "這將只會從此應用程式中移除所選 atSign 及其詳細資料。"),
        "scan_your_QR": MessageLookupByLibrary.simpleMessage("掃描您的二維碼！"),
        "select_all": MessageLookupByLibrary.simpleMessage("全選"),
        "select_atSign": MessageLookupByLibrary.simpleMessage("選擇 atSign"),
        "select_atSign_to_reset":
            MessageLookupByLibrary.simpleMessage("請選擇至少一個 atSign 以進行重置"),
        "send_code": MessageLookupByLibrary.simpleMessage("傳送驗證碼"),
        "sub_upload_atKeys": MessageLookupByLibrary.simpleMessage(
            "上傳您的 atKey 檔案。此檔案是在您啟動及配對您的 atSign 時生成的，並已提示您將其儲存在安全位置。"),
        "title_FAQ": MessageLookupByLibrary.simpleMessage("常見問題"),
        "title_activate_an_atSign":
            MessageLookupByLibrary.simpleMessage("啟動一個 atSign？"),
        "title_important": MessageLookupByLibrary.simpleMessage("重要提示！"),
        "title_intro": MessageLookupByLibrary.simpleMessage(
            "此應用程式建基於 atPlatform。所有 atPlatform 應用程式都需要一個 atSign。"),
        "title_pair_atSign_next":
            MessageLookupByLibrary.simpleMessage("以與此裝置配對"),
        "title_pair_atSign_prev": MessageLookupByLibrary.simpleMessage("您已選擇"),
        "title_save_your_key": MessageLookupByLibrary.simpleMessage("儲存您的金鑰"),
        "title_select_atSign": MessageLookupByLibrary.simpleMessage(
            "您已經擁有一些現有的 atSign。請選擇一個 atSign，或繼續使用新的 atSign。"),
        "title_session_expired":
            MessageLookupByLibrary.simpleMessage("您的工作階段已過期"),
        "title_setting_up_your_atSign":
            MessageLookupByLibrary.simpleMessage("設定您的 atSign"),
        "title_shared_storage": MessageLookupByLibrary.simpleMessage(
            "您想將此已整合的 atSign 與 atPlatform 上的其他應用程式分享嗎？"),
        "tutorial_activate_your_atSign":
            MessageLookupByLibrary.simpleMessage("點按此處以啟動您的 atSign"),
        "tutorial_generate_atSign":
            MessageLookupByLibrary.simpleMessage("點按以生成新的免費 atSign"),
        "tutorial_get_atSign":
            MessageLookupByLibrary.simpleMessage("如果您沒有 atSign，請點按此處以取得一個"),
        "tutorial_scan_QRCode":
            MessageLookupByLibrary.simpleMessage("點按以掃描二維碼"),
        "tutorial_upload_atSign_key": MessageLookupByLibrary.simpleMessage(
            "如果您有 atSign，請點按以上傳 atSign 金鑰"),
        "tutorial_upload_image_QRCode":
            MessageLookupByLibrary.simpleMessage("點按以上傳二維碼圖片"),
        "tutorial_upload_your_atKey": MessageLookupByLibrary.simpleMessage(
            "如果您已啟動 atSign，請點按以上傳您的 atKeys"),
        "upload_atKeys": MessageLookupByLibrary.simpleMessage("上傳 atKeys"),
        "verification_code_has_been_sent_to":
            MessageLookupByLibrary.simpleMessage("驗證碼已發送到"),
        "verification_code_sent_to":
            MessageLookupByLibrary.simpleMessage("驗證碼已發送到"),
        "verify_and_login": MessageLookupByLibrary.simpleMessage("驗證並登入"),
        "your_registered_email": MessageLookupByLibrary.simpleMessage("您註冊的電郵。")
      };
}
