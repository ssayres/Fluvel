import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_front/blocs/auth/auth_bloc.dart';
import 'package:flutter_front/blocs/chat/chat_bloc.dart';
import 'package:flutter_front/blocs/user/user_bloc.dart';
import 'package:flutter_front/cubits/cubits.dart';
import 'package:flutter_front/models/models.dart';
import 'package:flutter_front/screens/guest/guest_screen.dart';
import 'package:flutter_front/utils/utils.dart';
import 'package:flutter_front/widgets/widgets.dart';
import 'package:search_page/search_page.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const routeName = 'chat-list';

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
        },
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Suas conversas"),
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
          body: BlocConsumer<ChatBloc, ChatState>(
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
                  return Text("Hello");
                },
                separatorBuilder: (_, __) => const Divider(height: 1.5),
                itemCount: state.chats.length,
              );
            },
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
              eLog(state);
              return FloatingActionButton(
                onPressed: () => _showSearch(context, []),
                child: const Icon(Icons.search),
              );
            },
          ),
        ));
  }

  void _showSearch(BuildContext context, List<UserEntity> users) {
    showSearch(
      context: context,
      delegate: SearchPage<UserEntity>(
          items: users,
          searchLabel: 'Procurar contatos',
          filter: (user) => [
                user.email,
              ],
          suggestion: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.search,
                    size: 25.0,
                    color: Colors.grey,
                  ),
                  Text('Procure pelo nome de usuário'),
                ]),
          ),
          failure: const Center(
            child: Text(
              'Contato não encontrado : (',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          builder: (user) => ListTile(
                leading: const Icon(Icons.account_circle, size: 50.0),
                title: Text(user.username),
                subtitle: Text(user.email),
                onTap: () {},
              )),
    );
  }
}
