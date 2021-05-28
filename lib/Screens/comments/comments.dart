import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lets_connect/Screens/Profile/ProfileScreen.dart';
import 'package:lets_connect/Screens/comments/bloc/comments_bloc.dart';
import 'package:lets_connect/blocs/auth/auth_bloc.dart';
import 'package:lets_connect/models/models.dart';
import 'package:lets_connect/repositories/post/post_repository.dart';
import 'package:lets_connect/widgets/error_dialog.dart';
import 'package:lets_connect/widgets/user_profile_image.dart';

class CommentScreenArgs {
  final Post post;

  const CommentScreenArgs({@required this.post});
}

class CommentsScreen extends StatefulWidget {
  static const String routeName = '/comments';

  static Route route({@required CommentScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider<CommentsBloc>(
        create: (_) => CommentsBloc(
          postRepository: context.read<PostRepository>(),
          authBloc: context.read<AuthBloc>(),
        )..add(CommentsFetchComments(post: args.post)),
        child: CommentsScreen(),
      ),
    );
  }

  const CommentsScreen({Key key}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state.status == CommentsStatus.error) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(content: state.failure.message),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Comments'),
            centerTitle: true,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.only(bottom: 60.0),
            itemCount: state.comments.length,
            itemBuilder: (BuildContext context, int index) {
              final comment = state.comments[index];
              return ListTile(
                leading: UserProfileImage(
                  radius: 22.0,
                  profileImageUrl: comment.author.profileImageUrl,
                ),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: comment.author.username,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: comment.content,
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  DateFormat.yMd().add_jm().format(comment.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.of(context).pushNamed(
                    ProfileScreen.routeName,
                    arguments: ProfileScreenArgs(userId: comment.author.id)),
              );
            },
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.status == CommentsStatus.submitting)
                  const LinearProgressIndicator(),
                Row(
                  children: [
                    SizedBox(width: 5,),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration.collapsed(
                            hintText: 'Leave a comment...'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        final content = _commentController.text.trim();
                        if (content.isNotEmpty) {
                          context
                              .read<CommentsBloc>()
                              .add(CommentsPostComment(content: content));
                          _commentController.clear();
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
