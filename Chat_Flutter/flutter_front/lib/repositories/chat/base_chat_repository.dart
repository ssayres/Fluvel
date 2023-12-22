import 'package:flutter_front/models/models.dart';
import 'package:flutter_front/models/requests/requests.dart';

abstract class BaseChatRepository {
  Future<AppResponse<List<ChatEntity>>> getChats();

  Future<AppResponse<ChatEntity?>> createChat(CreateChatRequest request);

  Future<AppResponse<ChatEntity?>> getSingleChat(int chatId);
}
