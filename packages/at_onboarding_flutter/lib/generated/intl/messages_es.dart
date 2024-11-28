// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(givenAtsign) =>
      "El @sign no coincide. Por favor, proporciona el código QR de ${givenAtsign} para vincularlo.";

  static String m1(givenAtsign) =>
      "El @sign no coincide. Por favor, proporciona el archivo de clave de respaldo de ${givenAtsign} para vincularlo.";

  static String m2(atsign) =>
      "${atsign} ya estaba vinculado a este dispositivo. Primero elimina/reinicia este @sign del dispositivo para agregarlo.";

  static String m3(contactAddress) =>
      "¡Tiempo de espera de respuesta del servidor!\nPor favor, verifica tu conexión de red e inténtalo de nuevo. Contacta a ${contactAddress} si el problema persiste.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activate": MessageLookupByLibrary.simpleMessage("Activar"),
        "activate_an_atSign":
            MessageLookupByLibrary.simpleMessage("Activar un @sign"),
        "already_have_an_atSign":
            MessageLookupByLibrary.simpleMessage("¿Ya tienes un @sign?"),
        "atSign_mismatches_need_to_provide_QRCode": m0,
        "atSign_mismatches_need_to_provide_backupKey": m1,
        "btn_activate_atSign":
            MessageLookupByLibrary.simpleMessage("Activar @sign"),
        "btn_already_have_atSign":
            MessageLookupByLibrary.simpleMessage("¿Ya tienes un @sign?"),
        "btn_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "btn_close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "btn_continue": MessageLookupByLibrary.simpleMessage("CONTINUAR"),
        "btn_generate_atSign":
            MessageLookupByLibrary.simpleMessage("Generar un @sign gratuito"),
        "btn_no": MessageLookupByLibrary.simpleMessage("No"),
        "btn_pair": MessageLookupByLibrary.simpleMessage("Vincular"),
        "btn_refresh": MessageLookupByLibrary.simpleMessage("Actualizar"),
        "btn_remind_me_later":
            MessageLookupByLibrary.simpleMessage("Recordarme más tarde"),
        "btn_save": MessageLookupByLibrary.simpleMessage("GUARDAR"),
        "btn_scan_QRCode":
            MessageLookupByLibrary.simpleMessage("Escanear código QR"),
        "btn_skip_tutorial":
            MessageLookupByLibrary.simpleMessage("OMITIR TUTORIAL"),
        "btn_upload_QRCode":
            MessageLookupByLibrary.simpleMessage("Subir código QR"),
        "btn_yes": MessageLookupByLibrary.simpleMessage("Sí"),
        "btn_yes_continue":
            MessageLookupByLibrary.simpleMessage("Sí, continuar"),
        "enter_atSign_need_to_activate": MessageLookupByLibrary.simpleMessage(
            "Ingresa el @sign que deseas activar"),
        "enter_code": MessageLookupByLibrary.simpleMessage(
            "Por favor, ingresa el código de verificación de 4 caracteres que se envió a tu dirección de correo electrónico"),
        "enter_verification_code": MessageLookupByLibrary.simpleMessage(
            "Ingresa el código de verificación"),
        "enter_your_email_address": MessageLookupByLibrary.simpleMessage(
            "Ingresa tu dirección de correo electrónico"),
        "error_activate_server": MessageLookupByLibrary.simpleMessage(
            "No se pudo activar el servidor. Por favor, contacta al administrador."),
        "error_atSign_activated": MessageLookupByLibrary.simpleMessage(
            "Este @sign ya ha sido activado. Por favor, sube tus atKeys para vincularlo con este dispositivo"),
        "error_atSign_already_paired": m2,
        "error_atSign_logged": MessageLookupByLibrary.simpleMessage(
            "Este @sign ya ha sido activado y vinculado a este dispositivo"),
        "error_authenticated_failed":
            MessageLookupByLibrary.simpleMessage("Autenticación fallida"),
        "error_enter_valid_email": MessageLookupByLibrary.simpleMessage(
            "Ingresa una dirección de correo electrónico válida"),
        "error_incorrect_QRFile":
            MessageLookupByLibrary.simpleMessage("Archivo QR incorrecto"),
        "error_invalid_atSign_provided": MessageLookupByLibrary.simpleMessage(
            "Se proporcionó un @sign inválido. Por favor, contacta al administrador."),
        "error_perform_operation": MessageLookupByLibrary.simpleMessage(
            "No se pudo realizar la operación de lectura/escritura. Por favor, inténtalo de nuevo."),
        "error_please_enter_email": MessageLookupByLibrary.simpleMessage(
            "Por favor, ingresa una dirección de correo electrónico válida"),
        "error_process_file": MessageLookupByLibrary.simpleMessage(
            "Error al procesar el archivo"),
        "error_processing": MessageLookupByLibrary.simpleMessage(
            "Error en el procesamiento. Por favor, inténtalo de nuevo."),
        "error_processing_files": MessageLookupByLibrary.simpleMessage(
            "Error al procesar los archivos. Por favor, inténtalo de nuevo"),
        "error_provide_backupKey": MessageLookupByLibrary.simpleMessage(
            "Por favor, proporciona un archivo de clave de respaldo válido para continuar."),
        "error_provide_relevant_backupKey": MessageLookupByLibrary.simpleMessage(
            "Por favor, proporciona un archivo de clave de respaldo relevante para autenticarte."),
        "error_provide_valid_QRCode": MessageLookupByLibrary.simpleMessage(
            "Por favor, proporciona un código QR válido para autenticarte."),
        "error_server_not_found":
            MessageLookupByLibrary.simpleMessage("Servidor no encontrado"),
        "error_server_response_timed_out": m3,
        "error_server_unavailable": MessageLookupByLibrary.simpleMessage(
            "El servidor no está disponible. Por favor, inténtalo más tarde."),
        "error_unable_connect": MessageLookupByLibrary.simpleMessage(
            "No se puede conectar. Por favor, verifica tu conexión de red e inténtalo de nuevo."),
        "error_unable_to_authenticate": MessageLookupByLibrary.simpleMessage(
            "No se pudo autenticar. Por favor, inténtalo de nuevo."),
        "error_unable_to_connect_server": MessageLookupByLibrary.simpleMessage(
            "No se pudo conectar al servidor. Por favor, inténtalo más tarde."),
        "error_unable_to_perform_this_action": MessageLookupByLibrary.simpleMessage(
            "No se puede realizar esta acción. Por favor, inténtalo de nuevo."),
        "error_unknown":
            MessageLookupByLibrary.simpleMessage("Error desconocido."),
        "get_free_atSign":
            MessageLookupByLibrary.simpleMessage("Obtener un @sign gratuito"),
        "have_QRCode":
            MessageLookupByLibrary.simpleMessage("¿Tienes un código QR?"),
        "images": MessageLookupByLibrary.simpleMessage("imágenes"),
        "invalid_QR": MessageLookupByLibrary.simpleMessage("QR inválido."),
        "learn_about_atSign":
            MessageLookupByLibrary.simpleMessage("Aprende más sobre @signs"),
        "learn_more": MessageLookupByLibrary.simpleMessage("Aprende más"),
        "loading_atSigns":
            MessageLookupByLibrary.simpleMessage("Cargando @signs"),
        "msg_action_cannot_undone": MessageLookupByLibrary.simpleMessage(
            "Advertencia: Esta acción no se puede deshacer"),
        "msg_atSign_cannot_empty": MessageLookupByLibrary.simpleMessage(
            "El @sign no puede estar vacío"),
        "msg_atSign_not_registered": MessageLookupByLibrary.simpleMessage(
            "Tu @sign aún no está registrado. Por favor, inténtalo con uno registrado."),
        "msg_atSign_required":
            MessageLookupByLibrary.simpleMessage("Se requiere un @sign."),
        "msg_atSign_unreachable": MessageLookupByLibrary.simpleMessage(
            "Tu @sign y el servidor son inaccesibles. Por favor, inténtalo de nuevo o contacta a support@atsign.com"),
        "msg_auth_failed":
            MessageLookupByLibrary.simpleMessage("Autenticación fallida"),
        "msg_cannot_fetch_keys_from_chosen_file":
            MessageLookupByLibrary.simpleMessage(
                "No se pudieron obtener las claves del archivo seleccionado. Por favor, selecciona el archivo correcto"),
        "msg_maximum_atSign_next": MessageLookupByLibrary.simpleMessage(
            " para seleccionar uno de tus @signs existentes."),
        "msg_maximum_atSign_prev": MessageLookupByLibrary.simpleMessage(
            "¡Ups! Ya tienes el número máximo de @signs gratuitos. Por favor, inicia sesión en "),
        "msg_refresh_atSign": MessageLookupByLibrary.simpleMessage(
            "Actualiza hasta que veas un @sign que te guste, luego presiona Vincular"),
        "msg_response_time_out": MessageLookupByLibrary.simpleMessage(
            "Tiempo de espera de respuesta"),
        "msg_save_atKey_in_secure_location": MessageLookupByLibrary.simpleMessage(
            "Por favor, guarda tu clave en un lugar seguro (recomendamos Google Drive o iCloud Drive). La necesitarás para volver a iniciar sesión Y usar otras aplicaciones de atPlatform."),
        "msg_shared_storage": MessageLookupByLibrary.simpleMessage(
            "Esto te ahorrará el proceso de integrar este @sign en otras aplicaciones nuevamente."),
        "msg_wait_fetching_atSign": MessageLookupByLibrary.simpleMessage(
            "Por favor, espera mientras se obtiene el estado del @sign"),
        "no_atSigns_paired_to_reset": MessageLookupByLibrary.simpleMessage(
            "No hay @signs vinculados para restablecer. "),
        "no_permission": MessageLookupByLibrary.simpleMessage("Sin permiso"),
        "note": MessageLookupByLibrary.simpleMessage("Nota:"),
        "note_otp_content": MessageLookupByLibrary.simpleMessage(
            " Si no recibiste nuestro correo electrónico:\n- Confirma que tu dirección de correo electrónico se ingresó correctamente.\n- Revisa tu carpeta de spam/correo no deseado o promociones."),
        "note_pair_content": MessageLookupByLibrary.simpleMessage(
            "Nota: No compartimos tu información personal ni la usamos para obtener ganancias financieras."),
        "notice": MessageLookupByLibrary.simpleMessage("Aviso"),
        "onboarding": MessageLookupByLibrary.simpleMessage("Integración"),
        "pair_atSign": MessageLookupByLibrary.simpleMessage(
            "Vincular un @sign usando tus atKeys"),
        "processing": MessageLookupByLibrary.simpleMessage("Procesando..."),
        "remove": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "resend_code": MessageLookupByLibrary.simpleMessage("Reenviar código"),
        "reset": MessageLookupByLibrary.simpleMessage("Restablecer"),
        "reset_description": MessageLookupByLibrary.simpleMessage(
            "Esto eliminará el @sign seleccionado y sus detalles de esta aplicación solamente."),
        "scan_your_QR": MessageLookupByLibrary.simpleMessage("¡Escanea tu QR!"),
        "select_all": MessageLookupByLibrary.simpleMessage("Seleccionar todo"),
        "select_atSign":
            MessageLookupByLibrary.simpleMessage("Seleccionar @signs"),
        "select_atSign_to_reset": MessageLookupByLibrary.simpleMessage(
            "Por favor, selecciona al menos un @sign para restablecer"),
        "send_code": MessageLookupByLibrary.simpleMessage("Enviar código"),
        "sub_upload_atKeys": MessageLookupByLibrary.simpleMessage(
            "Sube tu archivo atKey. Este archivo se generó cuando activaste y vinculaste tu @sign y se te pidió que lo guardaras en un lugar seguro."),
        "title_FAQ":
            MessageLookupByLibrary.simpleMessage("Preguntas frecuentes"),
        "title_activate_an_atSign":
            MessageLookupByLibrary.simpleMessage("¿Activar un @sign?"),
        "title_important": MessageLookupByLibrary.simpleMessage("¡IMPORTANTE!"),
        "title_intro": MessageLookupByLibrary.simpleMessage(
            "Esta aplicación fue construida en la plataforma atPlatform. Todas las aplicaciones atPlatform requieren un @sign. "),
        "title_pair_atSign_next": MessageLookupByLibrary.simpleMessage(
            "para vincular con este dispositivo"),
        "title_pair_atSign_prev":
            MessageLookupByLibrary.simpleMessage("Has seleccionado "),
        "title_save_your_key":
            MessageLookupByLibrary.simpleMessage("Guarda tu clave"),
        "title_select_atSign": MessageLookupByLibrary.simpleMessage(
            "Ya tienes algunos @signs existentes. Por favor, selecciona un @sign o continúa con uno nuevo."),
        "title_session_expired":
            MessageLookupByLibrary.simpleMessage("Tu sesión ha expirado"),
        "title_setting_up_your_atSign":
            MessageLookupByLibrary.simpleMessage("Configurando tu @sign"),
        "title_shared_storage": MessageLookupByLibrary.simpleMessage(
            "¿Deseas compartir este @sign integrado con otras aplicaciones en atPlatform?"),
        "tutorial_activate_your_atSign": MessageLookupByLibrary.simpleMessage(
            "Toca aquí para activar tu @sign"),
        "tutorial_generate_atSign": MessageLookupByLibrary.simpleMessage(
            "Toca para generar un nuevo @sign gratuito"),
        "tutorial_get_atSign": MessageLookupByLibrary.simpleMessage(
            "Si no tienes un @sign, toca aquí para obtener uno"),
        "tutorial_scan_QRCode": MessageLookupByLibrary.simpleMessage(
            "Toca para escanear el código QR"),
        "tutorial_upload_atSign_key": MessageLookupByLibrary.simpleMessage(
            "Si tienes un @sign, toca para subir la clave del @sign"),
        "tutorial_upload_image_QRCode": MessageLookupByLibrary.simpleMessage(
            "Toca para subir la imagen del código QR"),
        "tutorial_upload_your_atKey": MessageLookupByLibrary.simpleMessage(
            "Si tienes un @sign activado, toca para subir tus atKeys"),
        "upload_atKeys": MessageLookupByLibrary.simpleMessage("Subir atKeys"),
        "verification_code_has_been_sent_to":
            MessageLookupByLibrary.simpleMessage(
                "Se ha enviado un código de verificación a"),
        "verification_code_sent_to": MessageLookupByLibrary.simpleMessage(
            "Código de verificación enviado a"),
        "verify_and_login":
            MessageLookupByLibrary.simpleMessage("Verificar e iniciar sesión"),
        "your_registered_email": MessageLookupByLibrary.simpleMessage(
            "tu correo electrónico registrado.")
      };
}
