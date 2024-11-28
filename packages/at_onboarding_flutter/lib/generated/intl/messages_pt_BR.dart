// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt_BR locale. All the
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
  String get localeName => 'pt_BR';

  static String m0(givenAtsign) =>
      "O @sign não confere. Forneça o código QR de ${givenAtsign} para emparelhar.";

  static String m1(givenAtsign) =>
      "O @sign não confere. Forneça o arquivo de chave de backup de ${givenAtsign} para emparelhar.";

  static String m2(atsign) =>
      "${atsign} já foi emparelhado com este dispositivo. Primeiro, remova/redefina este @sign do dispositivo para adicionar.";

  static String m3(contactAddress) =>
      "Tempo limite de resposta do servidor!\nVerifique sua conexão com a internet e tente novamente. Entre em contato com ${contactAddress} se o problema persistir.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activate": MessageLookupByLibrary.simpleMessage("Ativar"),
        "activate_an_atSign":
            MessageLookupByLibrary.simpleMessage("Ativar um @sign"),
        "already_have_an_atSign":
            MessageLookupByLibrary.simpleMessage("Já possui um @sign?"),
        "atSign_mismatches_need_to_provide_QRCode": m0,
        "atSign_mismatches_need_to_provide_backupKey": m1,
        "btn_activate_atSign":
            MessageLookupByLibrary.simpleMessage("Ativar @sign"),
        "btn_already_have_atSign":
            MessageLookupByLibrary.simpleMessage("Já possui um @sign?"),
        "btn_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "btn_close": MessageLookupByLibrary.simpleMessage("Fechar"),
        "btn_continue": MessageLookupByLibrary.simpleMessage("CONTINUAR"),
        "btn_generate_atSign":
            MessageLookupByLibrary.simpleMessage("Gerar um @sign gratuito"),
        "btn_no": MessageLookupByLibrary.simpleMessage("Não"),
        "btn_pair": MessageLookupByLibrary.simpleMessage("Emparelhar"),
        "btn_refresh": MessageLookupByLibrary.simpleMessage("Atualizar"),
        "btn_remind_me_later":
            MessageLookupByLibrary.simpleMessage("Lembrar-me mais tarde"),
        "btn_save": MessageLookupByLibrary.simpleMessage("SALVAR"),
        "btn_scan_QRCode":
            MessageLookupByLibrary.simpleMessage("Escanear código QR"),
        "btn_skip_tutorial":
            MessageLookupByLibrary.simpleMessage("PULAR TUTORIAL"),
        "btn_upload_QRCode":
            MessageLookupByLibrary.simpleMessage("Carregar código QR"),
        "btn_yes": MessageLookupByLibrary.simpleMessage("Sim"),
        "btn_yes_continue":
            MessageLookupByLibrary.simpleMessage("Sim, continuar"),
        "enter_atSign_need_to_activate": MessageLookupByLibrary.simpleMessage(
            "Digite o @sign que deseja ativar"),
        "enter_code": MessageLookupByLibrary.simpleMessage(
            "Digite o código de verificação de 4 caracteres enviado para seu endereço de e-mail"),
        "enter_verification_code": MessageLookupByLibrary.simpleMessage(
            "Digite o código de verificação"),
        "enter_your_email_address": MessageLookupByLibrary.simpleMessage(
            "Digite seu endereço de e-mail"),
        "error_activate_server": MessageLookupByLibrary.simpleMessage(
            "Não foi possível ativar o servidor. Entre em contato com o administrador."),
        "error_atSign_activated": MessageLookupByLibrary.simpleMessage(
            "Este @sign já foi ativado. Carregue suas atKeys para emparelhar com este dispositivo"),
        "error_atSign_already_paired": m2,
        "error_atSign_logged": MessageLookupByLibrary.simpleMessage(
            "Este @sign já foi ativado e emparelhado com este dispositivo"),
        "error_authenticated_failed":
            MessageLookupByLibrary.simpleMessage("Falha na autenticação"),
        "error_enter_valid_email": MessageLookupByLibrary.simpleMessage(
            "Digite um endereço de e-mail válido"),
        "error_incorrect_QRFile":
            MessageLookupByLibrary.simpleMessage("Arquivo QR incorreto"),
        "error_invalid_atSign_provided": MessageLookupByLibrary.simpleMessage(
            "O @sign fornecido é inválido. Entre em contato com o administrador."),
        "error_perform_operation": MessageLookupByLibrary.simpleMessage(
            "Não foi possível realizar a operação de leitura/escrita. Tente novamente."),
        "error_please_enter_email": MessageLookupByLibrary.simpleMessage(
            "Por favor, digite um endereço de e-mail válido"),
        "error_process_file": MessageLookupByLibrary.simpleMessage(
            "Falha ao processar o arquivo"),
        "error_processing": MessageLookupByLibrary.simpleMessage(
            "Falha no processamento. Tente novamente."),
        "error_processing_files": MessageLookupByLibrary.simpleMessage(
            "Falha ao processar os arquivos. Tente novamente"),
        "error_provide_backupKey": MessageLookupByLibrary.simpleMessage(
            "Forneça um arquivo de chave de backup válido para continuar."),
        "error_provide_relevant_backupKey": MessageLookupByLibrary.simpleMessage(
            "Forneça um arquivo de chave de backup relevante para autenticação."),
        "error_provide_valid_QRCode": MessageLookupByLibrary.simpleMessage(
            "Forneça um código QR válido para autenticação."),
        "error_server_not_found":
            MessageLookupByLibrary.simpleMessage("Servidor não encontrado"),
        "error_server_response_timed_out": m3,
        "error_server_unavailable": MessageLookupByLibrary.simpleMessage(
            "Servidor indisponível. Tente novamente mais tarde."),
        "error_unable_connect": MessageLookupByLibrary.simpleMessage(
            "Não foi possível conectar. Verifique sua conexão com a internet e tente novamente."),
        "error_unable_to_authenticate": MessageLookupByLibrary.simpleMessage(
            "Não foi possível autenticar. Tente novamente."),
        "error_unable_to_connect_server": MessageLookupByLibrary.simpleMessage(
            "Não foi possível conectar ao servidor. Tente novamente mais tarde."),
        "error_unable_to_perform_this_action":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível executar esta ação. Tente novamente."),
        "error_unknown":
            MessageLookupByLibrary.simpleMessage("Erro desconhecido."),
        "get_free_atSign":
            MessageLookupByLibrary.simpleMessage("Obter um @sign gratuito"),
        "have_QRCode":
            MessageLookupByLibrary.simpleMessage("Possui um código QR?"),
        "images": MessageLookupByLibrary.simpleMessage("imagens"),
        "invalid_QR": MessageLookupByLibrary.simpleMessage("QR inválido."),
        "learn_about_atSign":
            MessageLookupByLibrary.simpleMessage("Saiba mais sobre @signs"),
        "learn_more": MessageLookupByLibrary.simpleMessage("Saiba mais"),
        "loading_atSigns":
            MessageLookupByLibrary.simpleMessage("Carregando @signs"),
        "msg_action_cannot_undone": MessageLookupByLibrary.simpleMessage(
            "Atenção: Esta ação não pode ser desfeita"),
        "msg_atSign_cannot_empty": MessageLookupByLibrary.simpleMessage(
            "O @sign não pode estar vazio"),
        "msg_atSign_not_registered": MessageLookupByLibrary.simpleMessage(
            "Seu @sign ainda não está registrado. Tente com um registrado."),
        "msg_atSign_required":
            MessageLookupByLibrary.simpleMessage("É necessário um @sign."),
        "msg_atSign_unreachable": MessageLookupByLibrary.simpleMessage(
            "Seu @sign e o servidor estão inacessíveis. Tente novamente ou entre em contato com support@atsign.com"),
        "msg_auth_failed":
            MessageLookupByLibrary.simpleMessage("Autenticação falhou"),
        "msg_cannot_fetch_keys_from_chosen_file":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível obter as chaves do arquivo selecionado. Selecione o arquivo correto"),
        "msg_maximum_atSign_next": MessageLookupByLibrary.simpleMessage(
            " para selecionar um de seus @signs existentes."),
        "msg_maximum_atSign_prev": MessageLookupByLibrary.simpleMessage(
            "Ops! Você já possui o número máximo de @signs gratuitos. Faça login em "),
        "msg_refresh_atSign": MessageLookupByLibrary.simpleMessage(
            "Atualize até ver um @sign que goste, então pressione Emparelhar"),
        "msg_response_time_out":
            MessageLookupByLibrary.simpleMessage("Tempo limite de resposta"),
        "msg_save_atKey_in_secure_location": MessageLookupByLibrary.simpleMessage(
            "Salve sua chave em um local seguro (recomendamos Google Drive ou iCloud Drive). Você precisará dela para fazer login novamente E usar outros aplicativos atPlatform."),
        "msg_shared_storage": MessageLookupByLibrary.simpleMessage(
            "Isso economizará o processo de integrar este @sign em outros aplicativos novamente."),
        "msg_wait_fetching_atSign": MessageLookupByLibrary.simpleMessage(
            "Aguarde enquanto buscamos o status do @sign"),
        "no_atSigns_paired_to_reset": MessageLookupByLibrary.simpleMessage(
            "Nenhum @sign está emparelhado para redefinição. "),
        "no_permission": MessageLookupByLibrary.simpleMessage("Sem permissão"),
        "note": MessageLookupByLibrary.simpleMessage("Observação:"),
        "note_otp_content": MessageLookupByLibrary.simpleMessage(
            "Se você não recebeu nosso e-mail:\n- Confirme se seu endereço de e-mail está correto.\n- Verifique sua caixa de spam/lixo ou promoções."),
        "note_pair_content": MessageLookupByLibrary.simpleMessage(
            "Observação: Não compartilhamos suas informações pessoais nem as usamos para ganhos financeiros."),
        "notice": MessageLookupByLibrary.simpleMessage("Aviso"),
        "onboarding": MessageLookupByLibrary.simpleMessage("Integração"),
        "pair_atSign": MessageLookupByLibrary.simpleMessage(
            "Emparelhar um @sign usando suas atKeys"),
        "processing": MessageLookupByLibrary.simpleMessage("Processando..."),
        "remove": MessageLookupByLibrary.simpleMessage("Remover"),
        "resend_code": MessageLookupByLibrary.simpleMessage("Reenviar código"),
        "reset": MessageLookupByLibrary.simpleMessage("Redefinir"),
        "reset_description": MessageLookupByLibrary.simpleMessage(
            "Isso removerá o @sign selecionado e seus detalhes apenas deste aplicativo."),
        "scan_your_QR":
            MessageLookupByLibrary.simpleMessage("Escanear seu QR!"),
        "select_all": MessageLookupByLibrary.simpleMessage("Selecionar todos"),
        "select_atSign":
            MessageLookupByLibrary.simpleMessage("Selecionar @signs"),
        "select_atSign_to_reset": MessageLookupByLibrary.simpleMessage(
            "Selecione pelo menos um @sign para redefinir"),
        "send_code": MessageLookupByLibrary.simpleMessage("Enviar código"),
        "sub_upload_atKeys": MessageLookupByLibrary.simpleMessage(
            "Carregue seu arquivo atKey. Este arquivo foi gerado quando você ativou e emparelhou seu @sign e foi solicitado a armazená-lo em um local seguro."),
        "title_FAQ": MessageLookupByLibrary.simpleMessage("FAQ"),
        "title_activate_an_atSign":
            MessageLookupByLibrary.simpleMessage("Ativar um @sign?"),
        "title_important": MessageLookupByLibrary.simpleMessage("IMPORTANTE!"),
        "title_intro": MessageLookupByLibrary.simpleMessage(
            "Este aplicativo foi criado na plataforma atPlatform. Todos os aplicativos atPlatform exigem um @sign. "),
        "title_pair_atSign_next": MessageLookupByLibrary.simpleMessage(
            "para emparelhar com este dispositivo"),
        "title_pair_atSign_prev":
            MessageLookupByLibrary.simpleMessage("Você selecionou "),
        "title_save_your_key":
            MessageLookupByLibrary.simpleMessage("Salve sua chave"),
        "title_select_atSign": MessageLookupByLibrary.simpleMessage(
            "Você já possui alguns @signs existentes. Selecione um @sign ou continue com um novo."),
        "title_session_expired":
            MessageLookupByLibrary.simpleMessage("Sua sessão expirou"),
        "title_setting_up_your_atSign":
            MessageLookupByLibrary.simpleMessage("Configurando seu @sign"),
        "title_shared_storage": MessageLookupByLibrary.simpleMessage(
            "Deseja compartilhar este @sign integrado com outros aplicativos na atPlatform?"),
        "tutorial_activate_your_atSign": MessageLookupByLibrary.simpleMessage(
            "Toque aqui para ativar seu @sign"),
        "tutorial_generate_atSign": MessageLookupByLibrary.simpleMessage(
            "Toque para gerar um novo @sign gratuito"),
        "tutorial_get_atSign": MessageLookupByLibrary.simpleMessage(
            "Se você não possui um @sign, toque aqui para obter um"),
        "tutorial_scan_QRCode": MessageLookupByLibrary.simpleMessage(
            "Toque para escanear o código QR"),
        "tutorial_upload_atSign_key": MessageLookupByLibrary.simpleMessage(
            "Se você possui um @sign, toque para carregar a chave do @sign"),
        "tutorial_upload_image_QRCode": MessageLookupByLibrary.simpleMessage(
            "Toque para carregar a imagem do código QR"),
        "tutorial_upload_your_atKey": MessageLookupByLibrary.simpleMessage(
            "Se você possui um @sign ativado, toque para carregar suas atKeys"),
        "upload_atKeys":
            MessageLookupByLibrary.simpleMessage("Carregar atKeys"),
        "verification_code_has_been_sent_to":
            MessageLookupByLibrary.simpleMessage(
                "Um código de verificação foi enviado para"),
        "verification_code_sent_to": MessageLookupByLibrary.simpleMessage(
            "Código de verificação enviado para"),
        "verify_and_login":
            MessageLookupByLibrary.simpleMessage("Verificar e fazer login"),
        "your_registered_email":
            MessageLookupByLibrary.simpleMessage("seu e-mail registrado.")
      };
}
