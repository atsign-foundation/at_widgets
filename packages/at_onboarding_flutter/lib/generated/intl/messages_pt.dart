// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
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
  String get localeName => 'pt';

  static String m0(givenAtsign) =>
      "O atSign não coincide. Por favor, forneça o código QR de ${givenAtsign} para emparelhar.";

  static String m1(givenAtsign) =>
      "O atSign não coincide. Por favor, forneça o ficheiro de chave de backup de ${givenAtsign} para emparelhar.";

  static String m2(atsign) =>
      "O ${atsign} já estava emparelhado com este dispositivo. Primeiro remova/redefina este atSign do dispositivo para adicionar.";

  static String m3(contactAddress) =>
      "Tempo de espera de resposta do servidor!\nPor favor, verifique a sua ligação à internet e tente novamente. Contacte ${contactAddress} se o problema persistir.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activate": MessageLookupByLibrary.simpleMessage("Ativar"),
        "activate_an_atSign":
            MessageLookupByLibrary.simpleMessage("Ativar um atSign"),
        "already_have_an_atSign":
            MessageLookupByLibrary.simpleMessage("Já tem um atSign?"),
        "atSign_mismatches_need_to_provide_QRCode": m0,
        "atSign_mismatches_need_to_provide_backupKey": m1,
        "btn_activate_atSign":
            MessageLookupByLibrary.simpleMessage("Ativar atSign"),
        "btn_already_have_atSign":
            MessageLookupByLibrary.simpleMessage("Já tem um atSign?"),
        "btn_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "btn_close": MessageLookupByLibrary.simpleMessage("Fechar"),
        "btn_continue": MessageLookupByLibrary.simpleMessage("CONTINUAR"),
        "btn_generate_atSign":
            MessageLookupByLibrary.simpleMessage("Gerar um atSign gratuito"),
        "btn_no": MessageLookupByLibrary.simpleMessage("Não"),
        "btn_pair": MessageLookupByLibrary.simpleMessage("Emparelhar"),
        "btn_refresh": MessageLookupByLibrary.simpleMessage("Atualizar"),
        "btn_remind_me_later":
            MessageLookupByLibrary.simpleMessage("Lembrar-me mais tarde"),
        "btn_save": MessageLookupByLibrary.simpleMessage("GUARDAR"),
        "btn_scan_QRCode":
            MessageLookupByLibrary.simpleMessage("Ler código QR"),
        "btn_skip_tutorial":
            MessageLookupByLibrary.simpleMessage("Saltar Tutorial"),
        "btn_upload_QRCode":
            MessageLookupByLibrary.simpleMessage("Carregar código QR"),
        "btn_yes": MessageLookupByLibrary.simpleMessage("Sim"),
        "btn_yes_continue":
            MessageLookupByLibrary.simpleMessage("Sim, continuar"),
        "enter_atSign_need_to_activate": MessageLookupByLibrary.simpleMessage(
            "Introduza o atSign que pretende ativar"),
        "enter_code": MessageLookupByLibrary.simpleMessage(
            "Por favor, introduza o código de verificação de 4 caracteres que foi enviado para o seu endereço de e-mail"),
        "enter_verification_code": MessageLookupByLibrary.simpleMessage(
            "Introduzir código de verificação"),
        "enter_your_email_address": MessageLookupByLibrary.simpleMessage(
            "Introduza o seu endereço de e-mail"),
        "error_activate_server": MessageLookupByLibrary.simpleMessage(
            "Não foi possível ativar o servidor. Contacte o administrador."),
        "error_atSign_activated": MessageLookupByLibrary.simpleMessage(
            "Este atSign já foi ativado. Carregue as suas atKeys para emparelhar com este dispositivo"),
        "error_atSign_already_paired": m2,
        "error_atSign_logged": MessageLookupByLibrary.simpleMessage(
            "Este atSign já foi ativado e emparelhado com este dispositivo"),
        "error_authenticated_failed":
            MessageLookupByLibrary.simpleMessage("Autenticação falhou"),
        "error_enter_valid_email": MessageLookupByLibrary.simpleMessage(
            "Introduza um endereço de e-mail válido"),
        "error_incorrect_QRFile":
            MessageLookupByLibrary.simpleMessage("Ficheiro QR incorreto"),
        "error_invalid_atSign_provided": MessageLookupByLibrary.simpleMessage(
            "O atSign fornecido é inválido. Contacte o administrador."),
        "error_perform_operation": MessageLookupByLibrary.simpleMessage(
            "Não foi possível realizar a operação de leitura/escrita. Por favor, tente novamente."),
        "error_please_enter_email": MessageLookupByLibrary.simpleMessage(
            "Por favor, introduza um endereço de e-mail válido"),
        "error_process_file": MessageLookupByLibrary.simpleMessage(
            "Falha ao processar o ficheiro"),
        "error_processing": MessageLookupByLibrary.simpleMessage(
            "Falha no processamento. Por favor, tente novamente."),
        "error_processing_files": MessageLookupByLibrary.simpleMessage(
            "Falha ao processar os ficheiros. Por favor, tente novamente"),
        "error_provide_backupKey": MessageLookupByLibrary.simpleMessage(
            "Por favor, forneça um ficheiro de chave de backup válido para continuar."),
        "error_provide_relevant_backupKey": MessageLookupByLibrary.simpleMessage(
            "Por favor, forneça um ficheiro de chave de backup relevante para autenticação."),
        "error_provide_valid_QRCode": MessageLookupByLibrary.simpleMessage(
            "Por favor, forneça um código QR válido para autenticação."),
        "error_server_not_found":
            MessageLookupByLibrary.simpleMessage("Servidor não encontrado"),
        "error_server_response_timed_out": m3,
        "error_server_unavailable": MessageLookupByLibrary.simpleMessage(
            "Servidor indisponível. Por favor, tente novamente mais tarde."),
        "error_unable_connect": MessageLookupByLibrary.simpleMessage(
            "Não foi possível conectar. Por favor, verifique a sua ligação à internet e tente novamente."),
        "error_unable_to_authenticate": MessageLookupByLibrary.simpleMessage(
            "Não foi possível autenticar. Por favor, tente novamente."),
        "error_unable_to_connect_server": MessageLookupByLibrary.simpleMessage(
            "Não foi possível conectar ao servidor. Por favor, tente novamente mais tarde."),
        "error_unable_to_perform_this_action": MessageLookupByLibrary.simpleMessage(
            "Não foi possível executar esta ação. Por favor, tente novamente."),
        "error_unknown":
            MessageLookupByLibrary.simpleMessage("Erro desconhecido."),
        "get_free_atSign":
            MessageLookupByLibrary.simpleMessage("Obter um atSign gratuito"),
        "have_QRCode":
            MessageLookupByLibrary.simpleMessage("Tem um código QR?"),
        "images": MessageLookupByLibrary.simpleMessage("imagens"),
        "invalid_QR": MessageLookupByLibrary.simpleMessage("QR inválido."),
        "learn_about_atSign":
            MessageLookupByLibrary.simpleMessage("Saiba mais sobre atSign"),
        "learn_more": MessageLookupByLibrary.simpleMessage("Saiba mais"),
        "loading_atSigns":
            MessageLookupByLibrary.simpleMessage("A carregar atSign"),
        "msg_action_cannot_undone": MessageLookupByLibrary.simpleMessage(
            "Atenção: Esta ação não pode ser desfeita"),
        "msg_atSign_cannot_empty": MessageLookupByLibrary.simpleMessage(
            "O atSign não pode estar vazio"),
        "msg_atSign_not_registered": MessageLookupByLibrary.simpleMessage(
            "O seu atSign ainda não está registado. Por favor, tente com um registado."),
        "msg_atSign_required":
            MessageLookupByLibrary.simpleMessage("É necessário um atSign."),
        "msg_atSign_unreachable": MessageLookupByLibrary.simpleMessage(
            "O seu atSign e o servidor são inacessíveis. Por favor, tente novamente ou contacte support@atsign.com"),
        "msg_auth_failed":
            MessageLookupByLibrary.simpleMessage("Autenticação falhou"),
        "msg_cannot_fetch_keys_from_chosen_file":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível obter as chaves do ficheiro selecionado. Por favor, selecione o ficheiro correto"),
        "msg_maximum_atSign_next": MessageLookupByLibrary.simpleMessage(
            " para selecionar um dos seus atSigns existentes."),
        "msg_maximum_atSign_prev": MessageLookupByLibrary.simpleMessage(
            "Ops! Já tem o número máximo de atSigns gratuitos. Por favor, faça login em "),
        "msg_refresh_atSign": MessageLookupByLibrary.simpleMessage(
            "Atualize até ver um atSign que goste, depois carregue em Emparelhar"),
        "msg_response_time_out":
            MessageLookupByLibrary.simpleMessage("Tempo limite de resposta"),
        "msg_save_atKey_in_secure_location": MessageLookupByLibrary.simpleMessage(
            "Por favor, guarde a sua chave num local seguro (recomendamos Google Drive ou iCloud Drive). Vai precisar dela para voltar a iniciar sessão E usar outras aplicações atPlatform."),
        "msg_shared_storage": MessageLookupByLibrary.simpleMessage(
            "Isto poupará o processo de integrar este atSign noutras aplicações novamente."),
        "msg_wait_fetching_atSign": MessageLookupByLibrary.simpleMessage(
            "Por favor, aguarde enquanto obtemos o estado do atSign"),
        "no_atSigns_paired_to_reset": MessageLookupByLibrary.simpleMessage(
            "Não existem atSigns emparelhados para redefinir. "),
        "no_permission": MessageLookupByLibrary.simpleMessage("Sem permissão"),
        "note": MessageLookupByLibrary.simpleMessage("Nota:"),
        "note_otp_content": MessageLookupByLibrary.simpleMessage(
            "Se não recebeu o nosso e-mail:\n- Confirme se o seu endereço de e-mail está correto.\n- Verifique a sua pasta de spam/lixo ou promoções."),
        "note_pair_content": MessageLookupByLibrary.simpleMessage(
            "Nota: Não partilhamos a sua informação pessoal nem a usamos para ganhos financeiros."),
        "notice": MessageLookupByLibrary.simpleMessage("Aviso"),
        "onboarding": MessageLookupByLibrary.simpleMessage("Integração"),
        "pair_atSign": MessageLookupByLibrary.simpleMessage(
            "Emparelhar um atSign usando as suas atKeys"),
        "processing": MessageLookupByLibrary.simpleMessage("A processar..."),
        "remove": MessageLookupByLibrary.simpleMessage("Remover"),
        "resend_code": MessageLookupByLibrary.simpleMessage("Reenviar código"),
        "reset": MessageLookupByLibrary.simpleMessage("Redefinir"),
        "reset_description": MessageLookupByLibrary.simpleMessage(
            "Isto irá remover o atSign selecionado e os seus detalhes apenas desta aplicação."),
        "scan_your_QR": MessageLookupByLibrary.simpleMessage("Leia o seu QR!"),
        "select_all": MessageLookupByLibrary.simpleMessage("Selecionar tudo"),
        "select_atSign":
            MessageLookupByLibrary.simpleMessage("Selecionar atSigns"),
        "select_atSign_to_reset": MessageLookupByLibrary.simpleMessage(
            "Por favor, selecione pelo menos um atSign para redefinir"),
        "send_code": MessageLookupByLibrary.simpleMessage("Enviar código"),
        "sub_upload_atKeys": MessageLookupByLibrary.simpleMessage(
            "Carregue o seu ficheiro atKey. Este ficheiro foi gerado quando ativou e emparelhou o seu atSign e foi-lhe pedido para o guardar num local seguro."),
        "title_FAQ": MessageLookupByLibrary.simpleMessage("FAQ"),
        "title_activate_an_atSign":
            MessageLookupByLibrary.simpleMessage("Ativar um atSign?"),
        "title_important": MessageLookupByLibrary.simpleMessage("IMPORTANTE!"),
        "title_intro": MessageLookupByLibrary.simpleMessage(
            "Esta aplicação foi construída na plataforma atPlatform. Todas as aplicações atPlatform requerem um atSign. "),
        "title_pair_atSign_next": MessageLookupByLibrary.simpleMessage(
            "para emparelhar com este dispositivo"),
        "title_pair_atSign_prev":
            MessageLookupByLibrary.simpleMessage("Selecionou "),
        "title_save_your_key":
            MessageLookupByLibrary.simpleMessage("Guarde a sua chave"),
        "title_select_atSign": MessageLookupByLibrary.simpleMessage(
            "Já tem alguns atSigns existentes. Por favor, selecione um atSign ou continue com um novo."),
        "title_session_expired":
            MessageLookupByLibrary.simpleMessage("A sua sessão expirou"),
        "title_setting_up_your_atSign":
            MessageLookupByLibrary.simpleMessage("A configurar o seu atSign"),
        "title_shared_storage": MessageLookupByLibrary.simpleMessage(
            "Deseja partilhar este atSign integrado com outras aplicações na atPlatform?"),
        "tutorial_activate_your_atSign": MessageLookupByLibrary.simpleMessage(
            "Toque aqui para ativar o seu atSign"),
        "tutorial_generate_atSign": MessageLookupByLibrary.simpleMessage(
            "Toque para gerar um novo atSign gratuito"),
        "tutorial_get_atSign": MessageLookupByLibrary.simpleMessage(
            "Se não tem um atSign, toque aqui para obter um"),
        "tutorial_scan_QRCode":
            MessageLookupByLibrary.simpleMessage("Toque para ler o código QR"),
        "tutorial_upload_atSign_key": MessageLookupByLibrary.simpleMessage(
            "Se tem um atSign, toque para carregar a chave do atSign"),
        "tutorial_upload_image_QRCode": MessageLookupByLibrary.simpleMessage(
            "Toque para carregar a imagem do código QR"),
        "tutorial_upload_your_atKey": MessageLookupByLibrary.simpleMessage(
            "Se tem um atSign ativado, toque para carregar as suas atKeys"),
        "upload_atKeys":
            MessageLookupByLibrary.simpleMessage("Carregar atKeys"),
        "verification_code_has_been_sent_to":
            MessageLookupByLibrary.simpleMessage(
                "Um código de verificação foi enviado para"),
        "verification_code_sent_to": MessageLookupByLibrary.simpleMessage(
            "Código de verificação enviado para"),
        "verify_and_login":
            MessageLookupByLibrary.simpleMessage("Verificar e iniciar sessão"),
        "your_registered_email":
            MessageLookupByLibrary.simpleMessage("o seu e-mail registado.")
      };
}
