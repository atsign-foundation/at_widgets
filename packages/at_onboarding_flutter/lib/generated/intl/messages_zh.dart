// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(givenAtsign) => "@符号不匹配。请提供${givenAtsign}的二维码进行配对。";

  static String m1(givenAtsign) => "@符号不匹配。请提供${givenAtsign}的备份密钥文件进行配对。";

  static String m2(atsign) => "${atsign}已与该设备配对。请先从设备中删除/重置此@符号才能添加。";

  static String m3(contactAddress) =>
      "服务器响应超时！\n请检查您的网络连接并重试。如果问题仍然存在，请联系${contactAddress}。";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activate": MessageLookupByLibrary.simpleMessage("激活"),
        "activate_an_atSign": MessageLookupByLibrary.simpleMessage("激活一个@符号"),
        "already_have_an_atSign":
            MessageLookupByLibrary.simpleMessage("已经有@符号了？"),
        "atSign_mismatches_need_to_provide_QRCode": m0,
        "atSign_mismatches_need_to_provide_backupKey": m1,
        "btn_activate_atSign": MessageLookupByLibrary.simpleMessage("激活@符号"),
        "btn_already_have_atSign":
            MessageLookupByLibrary.simpleMessage("已经有@符号了？"),
        "btn_cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "btn_close": MessageLookupByLibrary.simpleMessage("关闭"),
        "btn_continue": MessageLookupByLibrary.simpleMessage("继续"),
        "btn_generate_atSign":
            MessageLookupByLibrary.simpleMessage("生成一个免费@符号"),
        "btn_no": MessageLookupByLibrary.simpleMessage("否"),
        "btn_pair": MessageLookupByLibrary.simpleMessage("配对"),
        "btn_refresh": MessageLookupByLibrary.simpleMessage("刷新"),
        "btn_remind_me_later": MessageLookupByLibrary.simpleMessage("稍后提醒我"),
        "btn_save": MessageLookupByLibrary.simpleMessage("保存"),
        "btn_scan_QRCode": MessageLookupByLibrary.simpleMessage("扫描二维码"),
        "btn_skip_tutorial": MessageLookupByLibrary.simpleMessage("跳过教程"),
        "btn_upload_QRCode": MessageLookupByLibrary.simpleMessage("上传二维码"),
        "btn_yes": MessageLookupByLibrary.simpleMessage("是"),
        "btn_yes_continue": MessageLookupByLibrary.simpleMessage("是的，继续"),
        "enter_atSign_need_to_activate":
            MessageLookupByLibrary.simpleMessage("输入您想要激活的@符号"),
        "enter_code": MessageLookupByLibrary.simpleMessage("请输入发送到您邮箱的4位验证码"),
        "enter_verification_code":
            MessageLookupByLibrary.simpleMessage("输入验证码"),
        "enter_your_email_address":
            MessageLookupByLibrary.simpleMessage("输入您的邮箱地址"),
        "error_activate_server":
            MessageLookupByLibrary.simpleMessage("无法激活服务器。请联系管理员。"),
        "error_atSign_activated":
            MessageLookupByLibrary.simpleMessage("此@符号已被激活。请上传您的atKeys与该设备配对"),
        "error_atSign_already_paired": m2,
        "error_atSign_logged":
            MessageLookupByLibrary.simpleMessage("此@符号已激活并与该设备配对"),
        "error_authenticated_failed":
            MessageLookupByLibrary.simpleMessage("身份验证失败"),
        "error_enter_valid_email":
            MessageLookupByLibrary.simpleMessage("请输入有效的邮箱地址"),
        "error_incorrect_QRFile":
            MessageLookupByLibrary.simpleMessage("二维码文件错误"),
        "error_invalid_atSign_provided":
            MessageLookupByLibrary.simpleMessage("提供的@符号无效。请联系管理员。"),
        "error_perform_operation":
            MessageLookupByLibrary.simpleMessage("无法执行读/写操作。请重试。"),
        "error_please_enter_email":
            MessageLookupByLibrary.simpleMessage("请输入有效的邮箱地址"),
        "error_process_file": MessageLookupByLibrary.simpleMessage("文件处理失败"),
        "error_processing": MessageLookupByLibrary.simpleMessage("处理失败。请重试。"),
        "error_processing_files":
            MessageLookupByLibrary.simpleMessage("文件处理失败。请重试"),
        "error_provide_backupKey":
            MessageLookupByLibrary.simpleMessage("请提供有效的备份密钥文件以继续。"),
        "error_provide_relevant_backupKey":
            MessageLookupByLibrary.simpleMessage("请提供相关的备份密钥文件进行身份验证。"),
        "error_provide_valid_QRCode":
            MessageLookupByLibrary.simpleMessage("请提供有效的二维码进行身份验证。"),
        "error_server_not_found":
            MessageLookupByLibrary.simpleMessage("服务器未找到"),
        "error_server_response_timed_out": m3,
        "error_server_unavailable":
            MessageLookupByLibrary.simpleMessage("服务器不可用。请稍后再试。"),
        "error_unable_connect":
            MessageLookupByLibrary.simpleMessage("无法连接。请检查网络连接并重试。"),
        "error_unable_to_authenticate":
            MessageLookupByLibrary.simpleMessage("无法进行身份验证。请重试。"),
        "error_unable_to_connect_server":
            MessageLookupByLibrary.simpleMessage("无法连接服务器。请稍后再试。"),
        "error_unable_to_perform_this_action":
            MessageLookupByLibrary.simpleMessage("无法执行此操作。请重试。"),
        "error_unknown": MessageLookupByLibrary.simpleMessage("未知错误。"),
        "get_free_atSign": MessageLookupByLibrary.simpleMessage("获取免费@符号"),
        "have_QRCode": MessageLookupByLibrary.simpleMessage("有二维码吗？"),
        "images": MessageLookupByLibrary.simpleMessage("图片"),
        "invalid_QR": MessageLookupByLibrary.simpleMessage("二维码无效。"),
        "learn_about_atSign":
            MessageLookupByLibrary.simpleMessage("了解更多关于@符号的信息"),
        "learn_more": MessageLookupByLibrary.simpleMessage("了解更多"),
        "loading_atSigns": MessageLookupByLibrary.simpleMessage("正在加载@符号"),
        "msg_action_cannot_undone":
            MessageLookupByLibrary.simpleMessage("警告：此操作无法撤销"),
        "msg_atSign_cannot_empty":
            MessageLookupByLibrary.simpleMessage("@符号不能为空"),
        "msg_atSign_not_registered":
            MessageLookupByLibrary.simpleMessage("您的@符号尚未注册。请尝试使用已注册的@符号。"),
        "msg_atSign_required": MessageLookupByLibrary.simpleMessage("需要一个@符号。"),
        "msg_atSign_unreachable": MessageLookupByLibrary.simpleMessage(
            "您的@符号和服务器无法访问。请重试或联系support@atsign.com"),
        "msg_auth_failed": MessageLookupByLibrary.simpleMessage("身份验证失败"),
        "msg_cannot_fetch_keys_from_chosen_file":
            MessageLookupByLibrary.simpleMessage("无法从所选文件中获取密钥。请选择正确的文件"),
        "msg_maximum_atSign_next":
            MessageLookupByLibrary.simpleMessage("来选择您现有的@符号之一。"),
        "msg_maximum_atSign_prev":
            MessageLookupByLibrary.simpleMessage("糟糕！您已经拥有了最大数量的免费@符号。请登录到"),
        "msg_refresh_atSign":
            MessageLookupByLibrary.simpleMessage("刷新直到您看到您喜欢的@符号，然后点击配对"),
        "msg_response_time_out": MessageLookupByLibrary.simpleMessage("响应超时"),
        "msg_save_atKey_in_secure_location": MessageLookupByLibrary.simpleMessage(
            "请将您的密钥保存在安全的地方（我们建议使用Google Drive或iCloud Drive）。您需要它才能重新登录并使用其他atPlatform应用程序。"),
        "msg_shared_storage":
            MessageLookupByLibrary.simpleMessage("这将节省您在其他应用程序上再次集成此@符号的过程。"),
        "msg_wait_fetching_atSign":
            MessageLookupByLibrary.simpleMessage("请等待获取@符号状态"),
        "no_atSigns_paired_to_reset":
            MessageLookupByLibrary.simpleMessage("没有@符号需要重置。"),
        "no_permission": MessageLookupByLibrary.simpleMessage("无权限"),
        "note": MessageLookupByLibrary.simpleMessage("注意："),
        "note_otp_content": MessageLookupByLibrary.simpleMessage(
            "如果您没有收到我们的邮件：\n- 确认您的邮箱地址输入正确。\n- 检查您的垃圾邮件/垃圾箱或推广文件夹。"),
        "note_pair_content":
            MessageLookupByLibrary.simpleMessage("注意：我们不会分享您的个人信息或将其用于牟利。"),
        "notice": MessageLookupByLibrary.simpleMessage("通知"),
        "onboarding": MessageLookupByLibrary.simpleMessage("入门"),
        "pair_atSign": MessageLookupByLibrary.simpleMessage("使用您的atKeys配对@符号"),
        "processing": MessageLookupByLibrary.simpleMessage("处理中..."),
        "remove": MessageLookupByLibrary.simpleMessage("移除"),
        "resend_code": MessageLookupByLibrary.simpleMessage("重新发送验证码"),
        "reset": MessageLookupByLibrary.simpleMessage("重置"),
        "reset_description":
            MessageLookupByLibrary.simpleMessage("这将仅从该应用程序中删除所选@符号及其详细信息。"),
        "scan_your_QR": MessageLookupByLibrary.simpleMessage("扫描您的二维码！"),
        "select_all": MessageLookupByLibrary.simpleMessage("全选"),
        "select_atSign": MessageLookupByLibrary.simpleMessage("选择@符号"),
        "select_atSign_to_reset":
            MessageLookupByLibrary.simpleMessage("请选择至少一个@符号进行重置"),
        "send_code": MessageLookupByLibrary.simpleMessage("发送验证码"),
        "sub_upload_atKeys": MessageLookupByLibrary.simpleMessage(
            "上传您的atKey文件。此文件在您激活并配对@符号时生成，并提示您将其存储在安全位置。"),
        "title_FAQ": MessageLookupByLibrary.simpleMessage("常见问题"),
        "title_activate_an_atSign":
            MessageLookupByLibrary.simpleMessage("激活一个@符号？"),
        "title_important": MessageLookupByLibrary.simpleMessage("重要提示！"),
        "title_intro": MessageLookupByLibrary.simpleMessage(
            "此应用程序基于atPlatform构建。所有atPlatform应用程序都需要一个@符号。"),
        "title_pair_atSign_next":
            MessageLookupByLibrary.simpleMessage("与该设备配对"),
        "title_pair_atSign_prev": MessageLookupByLibrary.simpleMessage("您已选择"),
        "title_save_your_key": MessageLookupByLibrary.simpleMessage("保存您的密钥"),
        "title_select_atSign": MessageLookupByLibrary.simpleMessage(
            "您已经有了一些现有的@符号。请选择一个@符号，或者继续使用新的@符号。"),
        "title_session_expired":
            MessageLookupByLibrary.simpleMessage("您的会话已过期"),
        "title_setting_up_your_atSign":
            MessageLookupByLibrary.simpleMessage("设置您的@符号"),
        "title_shared_storage": MessageLookupByLibrary.simpleMessage(
            "您是否希望将此已集成的@符号与atPlatform上的其他应用程序共享？"),
        "tutorial_activate_your_atSign":
            MessageLookupByLibrary.simpleMessage("点击此处激活您的@符号"),
        "tutorial_generate_atSign":
            MessageLookupByLibrary.simpleMessage("点击此处生成新的免费@符号"),
        "tutorial_get_atSign":
            MessageLookupByLibrary.simpleMessage("如果您没有@符号，请点击此处获取一个"),
        "tutorial_scan_QRCode":
            MessageLookupByLibrary.simpleMessage("点击此处扫描二维码"),
        "tutorial_upload_atSign_key":
            MessageLookupByLibrary.simpleMessage("如果您有@符号，请点击此处上传@符号密钥"),
        "tutorial_upload_image_QRCode":
            MessageLookupByLibrary.simpleMessage("点击此处上传二维码图片"),
        "tutorial_upload_your_atKey":
            MessageLookupByLibrary.simpleMessage("如果您已激活@符号，请点击此处上传您的atKeys"),
        "upload_atKeys": MessageLookupByLibrary.simpleMessage("上传atKeys"),
        "verification_code_has_been_sent_to":
            MessageLookupByLibrary.simpleMessage("验证码已发送到"),
        "verification_code_sent_to":
            MessageLookupByLibrary.simpleMessage("验证码已发送到"),
        "verify_and_login": MessageLookupByLibrary.simpleMessage("验证并登录"),
        "your_registered_email": MessageLookupByLibrary.simpleMessage("您注册的邮箱。")
      };
}
