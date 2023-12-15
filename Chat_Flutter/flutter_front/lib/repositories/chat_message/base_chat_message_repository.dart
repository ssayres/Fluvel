import 'package:flutter_front/models/models.dart';
import 'package:flutter_front/models/requests/create_chat_message_request.dart';
import 'package:flutter_front/models/requests/requests.dart';

abstract class BaseChatMessageRepository {
  Future<AppResponse<List<ChatMessageEntity>>> getChatMessages({
    required int chatId,
    required int page,
  });

  Future<AppResponse<ChatMessageEntity?>> createChatMessage(
    CreateChatMessageRequest request,
    String socketId,
  );
}