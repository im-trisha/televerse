import 'package:televerse/src/telegram/models/abstracts/chat_member.dart';
import 'package:televerse/src/types/chat_member_status.dart';

import 'user.dart';

class ChatMemberMember implements ChatMember {
  /// The member's status in the chat, always “creator”

  @override
  final ChatMemberStatus status = ChatMemberStatus.member;

  /// Information about the user
  @override
  final User user;

  const ChatMemberMember({
    required this.user,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
      'user': user.toJson(),
    };
  }

  factory ChatMemberMember.fromJson(Map<String, dynamic> json) {
    return ChatMemberMember(
      user: User.fromJson(json['user']),
    );
  }
}
