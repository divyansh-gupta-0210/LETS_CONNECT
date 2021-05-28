import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:lets_connect/blocs/auth/auth_bloc.dart';
import 'package:lets_connect/cubits/cubits.dart';
import 'package:lets_connect/models/models.dart';
import 'package:lets_connect/repositories/post/post_repository.dart';
import 'package:meta/meta.dart';

part 'feed_event.dart';

part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository _postRepository;
  final AuthBloc _authBloc;
  final LikedPostsCubit _likedPostsCubit;

  FeedBloc(
      {@required PostRepository postRepository,
      @required AuthBloc authBloc,
      @required LikedPostsCubit likedPostsCubit})
      : _postRepository = postRepository,
        _authBloc = authBloc,
        _likedPostsCubit = likedPostsCubit,
        super(FeedState.initial());

  @override
  Stream<FeedState> mapEventToState(FeedEvent event) async* {
    if (event is FeedFetchPosts) {
      yield* _mapFeedFetchPostsToState();
    } else if (event is FeedPaginatePosts) {
      yield* _mapFeedPaginatePostsToState();
    }
  }

  Stream<FeedState> _mapFeedFetchPostsToState() async* {
    yield state.copyWith(posts: [], status: FeedStatus.loading);
    try {
      final posts =
          await _postRepository.getUserFeed(userId: _authBloc.state.user.uid);
      _likedPostsCubit.clearAllLikedPosts();
      final likedPostIds = await _postRepository.getLikedPostIds(
          userId: _authBloc.state.user.uid, posts: posts);
      _likedPostsCubit.updateLikedPosts(postIds: likedPostIds);

      yield state.copyWith(posts: posts, status: FeedStatus.loaded);

    } catch (err) {
      yield state.copyWith(
        status: FeedStatus.error,
        failure: const Failure(message: 'We were unable to load your feed.'),
      );
    }
  }

  Stream<FeedState> _mapFeedPaginatePostsToState() async* {
    yield state.copyWith(status: FeedStatus.paginating);
    try {
      final lastPostId = state.posts.isNotEmpty ? state.posts.last.id : null;
      final posts = await _postRepository.getUserFeed(
        userId: _authBloc.state.user.uid,
        lastPostId: lastPostId,
      );
      final updatedPosts = List<Post>.from(state.posts)..addAll(posts);

      final likedPostIds = await _postRepository.getLikedPostIds(
          userId: _authBloc.state.user.uid, posts: posts);
      _likedPostsCubit.updateLikedPosts(postIds: likedPostIds);

      yield state.copyWith(posts: updatedPosts, status: FeedStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: FeedStatus.error,
        failure: const Failure(message: 'We were unable to load your feed.'),
      );
    }
  }
}
