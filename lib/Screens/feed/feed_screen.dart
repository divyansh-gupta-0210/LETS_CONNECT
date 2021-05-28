import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_connect/Screens/feed/bloc/feed_bloc.dart';
import 'package:lets_connect/widgets/error_dialog.dart';
import 'package:lets_connect/widgets/post_view.dart';
import 'package:lets_connect/cubits/liked_posts/liked_posts_cubit.dart';

class FeedScreen extends StatefulWidget {
  static const String routeName = '/feed';

  const FeedScreen({Key key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent &&
            !_scrollController.position.outOfRange &&
            context.read<FeedBloc>().state.status != FeedStatus.paginating) {
          context.read<FeedBloc>().add(FeedPaginatePosts());
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.status == FeedStatus.error) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              content: state.failure.message,
            ),
          );
        } else if (state.status == FeedStatus.paginating) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              duration: const Duration(seconds: 1),
              content: const Text('Fetching More Posts. . .'),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lets-Connect'),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.video_call,
                  color: Colors.black,
                ),
                onPressed: () => {},
              ),
              if (state.posts.isEmpty && state.status == FeedStatus.loaded)
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.black,
                  ),
                  onPressed: () =>
                      context.read<FeedBloc>().add(FeedFetchPosts()),
                ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(FeedState state) {
    switch (state.status) {
      case FeedStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      default:
        return RefreshIndicator(
          onRefresh: () async {
            context.read<FeedBloc>().add(FeedFetchPosts());
            return true;
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.posts.length,
            itemBuilder: (BuildContext context, int index) {
              final post = state.posts[index];
              final likedPostState = context.watch<LikedPostsCubit>().state;
              final isLiked = likedPostState.likedPostIds.contains(post.id);
              final recentlyLiked =
                  likedPostState.recentlyLikedPostIds.contains(post.id);
              return PostView(
                post: post,
                isLiked: isLiked,
                recentlyLiked: recentlyLiked,
                onLike: () {
                  if (isLiked) {
                    context.read<LikedPostsCubit>().unlikePost(post: post);
                  } else {
                    context.read<LikedPostsCubit>().likePost(post: post);
                  }
                },
              );
            },
          ),
        );
    }
  }
}
