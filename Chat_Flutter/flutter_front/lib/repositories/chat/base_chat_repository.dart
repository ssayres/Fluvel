import 'package:flutter_front/models/models.dart';
import 'package:flutter_front/models/requests/create_chat_message_request.dart';
import 'package:flutter_front/models/requests/requests.dart';

abstract class BaseChatRepository {
  Future<AppResponse<List<ChatEntity>>> getChats();

  Future<AppResponse<ChatEntity?>> createChat(CreateChatMessageRequest request);

  Future<AppResponse<ChatEntity?>> getSingleChat(int chatId);
}
