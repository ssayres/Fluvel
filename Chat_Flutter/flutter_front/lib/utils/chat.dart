import 'package:flutter_front/models/models.dart';

String getChatName(
    List<ChatParticipantEntity> participants, UserEntity currentUser) {
  final otherParticipants =
      participants.where((el) => el.userId != currentUser.id).toList();

  if (otherParticipants.isNotEmpty) {
    return otherParticipants[0].user.username;
  }

  return 'N/A';
}
