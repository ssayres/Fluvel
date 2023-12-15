import 'package:dio/dio.dart';
import 'package:flutter_front/models/requests/create_chat_message_request.dart';
import 'package:flutter_front/models/requests/create_chat_request.dart';
import 'package:flutter_front/models/chat_model.dart';
import 'package:flutter_front/models/app_response.dart';
import 'package:flutter_front/repositories/chat/base_chat_repository.dart';
import 'package:flutter_front/repositories/core/endpoints.dart';
import 'package:flutter_front/utils/dio_client/dio_client.dart';
import 'package:flutter_front/models/models.dart';

class ChatRepository extends BaseChatRepository {
  final Dio _dioClient;

  ChatRepository({
    Dio? dioClient,
  }) : _dioClient = dioClient ?? DioClient().instance;

  @override
  Future<AppResponse<ChatEntity?>> createChat(CreateChatMessageRequest request) async {
    final response =
        await _dioClient.post(Endpoints.createChat, data: request.toJson());

    return AppResponse<ChatEntity?>.fromJson(
      response.data,
      (dynamic json) => response.data['success'] && json != null
          ? ChatEntity.fromJson(json)
          : null,
    );
  }

  @override
  Future<AppResponse<List<ChatEntity>>> getChats() async {
    final response = await _dioClient.get(Endpoints.getChats);

    return AppResponse<List<ChatEntity>>.fromJson(
      response.data,
      (dynamic json) => response.data['success'] && json != null
          ? (json as List<dynamic>).map((e) => ChatEntity.fromJson(e)).toList()
          : [],
    );
  }

  @override
  Future<AppResponse<ChatEntity?>> getSingleChat(int chatId) async {
    final response = await _dioClient.get("${Endpoints.getSingleChat}$chatId");

    return AppResponse<ChatEntity?>.fromJson(
      response.data,
      (dynamic json) => response.data['success'] && json != null
          ? ChatEntity.fromJson(json)
          : null,
    );
  }
}