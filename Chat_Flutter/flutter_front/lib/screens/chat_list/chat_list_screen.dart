import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_front/blocs/blocs.dart';
import 'package:flutter_front/blocs/chat/chat_bloc.dart';
import 'package:flutter_front/blocs/user/user_bloc.dart';
import 'package:flutter_front/cubits/cubits.dart';
import 'package:flutter_front/models/models.dart';
import 'package:flutter_front/screens/chat/chat_screen.dart';
import 'package:flutter_front/screens/chat_list/chat_list_item.dart';
import 'package:flutter_front/screens/guest/guest_screen.dart';
import 'package:flutter_front/utils/utils.dart';
import 'package:flutter_front/widgets/widgets.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:search_page/search_page.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  static const routeName = "chat-list";

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
//   Future<void> setupOneSignal(int userId) async {
//     await initOneSignal();
//     registerOneSignalEventListener(
//       onOpened: onOpened,
//       onReceivedInForeground: onReceivedInForeground,
//     );
//     promptPolicyPrivacy(userId);
//   }

//   void onOpened(OSNotificationOpenedResult result) {
//     vLog('NOTIFICATION OPENED HANDLER CALLED WITH: ${result}');
//     vLog(
//         "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}");

//     try {
//       final data = result.notification.additionalData;
//       if (data != null) {
//         final chatId = (data['data']['chatId'] as int);
//         final chatBloc = context.read<ChatBloc>();
//         final selectedChat = chatBloc.state.selectedChat;

//         if (chatId != selectedChat?.id) {
//           chatBloc.add(ChatNotificationOpened(chatId));
//           Navigator.of(context).pushNamed(ChatScreen.routeName);
//         }
//       }
//     } catch (_) {}
//   }

//   void onReceivedInForeground(OSNotificationReceivedEvent event) {
//     vLog(
//         "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
//     final chatBloc = context.read<ChatBloc>();
//     try {
//       final data = event.notification.additionalData;
//       final selectedChat = chatBloc.state.selectedChat;

//       if (selectedChat != null && data != null) {
//         vLog(data);
//         final chatId = (data['data']['chatId'] as int);

//         if (selectedChat.id == chatId) {
//           event.complete(null);
//           return;
//         }
//       }
//       chatBloc.add(const ChatStarted());
//       event.complete(event.notification);

//       vLog(data);
//     } catch (_) {
//       event.complete(null);
//     }
//   }

//   Future<void> promptPolicyPrivacy(int userId) async {
//     final oneSignalShared = OneSignal.shared;

//     bool userProvidedPrivacyConsent =
//         await oneSignalShared.userProvidedPrivacyConsent();

//     if (userProvidedPrivacyConsent) {
//       sendUserTag(userId);
//     } else {
//       bool requiresConsent = await oneSignalShared.requiresUserPrivacyConsent();

//       if (requiresConsent) {
//         final accepted =
//             await oneSignalShared.promptUserForPushNotificationPermission();
//         if (accepted) {
//           await oneSignalShared.consentGranted(true);
//           sendUserTag(userId);
//         }
//       } else {
//         sendUserTag(userId);
//       }
//     }
//   }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final currentUser = authBloc.state.user!;
    final chatBloc = context.read<ChatBloc>();
    final userBloc = context.read<UserBloc>();

    return StartUpContainer(
      onInit: () async {
        chatBloc.add(const ChatStarted());
        userBloc.add(const UserStarted());

        LaravelEcho.init(token: authBloc.state.token!);
        // setupOneSignal(authBloc.state.user!.id);
      },
      onDisposed: () {
        LaravelEcho.instance.disconnect();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Conversas"),
              Text(
                "User Id : ${currentUser.username}",
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (!state.isAuthenticated) {
                  // deleteUserTag();
                  Navigator.of(context)
                      .pushReplacementNamed(GuestScreen.routeName);
                }
              },
              builder: (context, state) {
                return IconButton(
                  onPressed: () {
                    context.read<GuestCubit>().signOut();
                  },
                  icon: const Icon(Icons.logout),
                );
              },
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            chatBloc.add(const ChatStarted());
            userBloc.add(const UserStarted());
          },
          child: BlocConsumer<ChatBloc, ChatState>(
            listener: (_, __) {},
            builder: (context, state) {
              if (state.chats.isEmpty) {
                return const BlankContent(
                  content: "Você não tem nenhuma conversa",
                  icon: Icons.chat_rounded,
                );
              }

              return ListView.separated(
                itemBuilder: (context, index) {
                  final item = state.chats[index];

                  return ChatListItem(
                    key: ValueKey(item.id),
                    item: item,
                    currentUser: currentUser,
                    onPressed: (chat) {
                      chatBloc.add(ChatSelected(chat));
                      Navigator.of(context).pushNamed(ChatScreen.routeName);
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider(
                  height: 1.5,
                ),
                itemCount: state.chats.length,
              );
            },
          ),
        ),
        floatingActionButton:
            BlocSelector<UserBloc, UserState, List<UserEntity>>(
          selector: (state) {
            return state.map(
              initial: (_) => [],
              loaded: (state) => state.users,
            );
          },
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: () => _showSearch(context, state),
              child: const Icon(Icons.search),
            );
          },
        ),
      ),
    );
  }

  void _showSearch(BuildContext context, List<UserEntity> users) {
    showSearch(
      context: context,
      delegate: SearchPage<UserEntity>(
        items: users,
        searchLabel: 'Procurar contatos',
        suggestion: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.search,
                size: 25.0,
                color: Colors.grey,
              ),
              Text(
                'Procure pelo nome de usuário',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        failure: const Center(
          child: Text(
            'Nenhum contato encontrado',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
        filter: (user) => [
          user.email,
        ],
        builder: (user) => ListTile(
          leading: const Icon(Icons.account_circle, size: 50.0),
          title: Text(user.username),
          subtitle: Text(user.email),
          onTap: () {
            /// selected user
            context.read<ChatBloc>().add(UserSelected(user));

            /// push to chat screen
            Navigator.of(context).pushNamed(ChatScreen.routeName);
          },
        ),
      ),
    );
  }
}
