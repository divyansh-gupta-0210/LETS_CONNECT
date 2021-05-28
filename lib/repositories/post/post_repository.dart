import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:lets_connect/config/paths.dart';
import 'package:lets_connect/enums/enums.dart';
import 'package:lets_connect/models/comment_model.dart';
import 'package:lets_connect/models/models.dart';
import 'package:lets_connect/models/post_model.dart';
import 'package:lets_connect/repositories/post/base_post_repository.dart';

class PostRepository extends BasePostRepository {
  final FirebaseFirestore _firebaseFirestore;

  PostRepository({FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createComment(
      {@required Post post, @required Comment comment}) async {
    await _firebaseFirestore
        .collection(Paths.comments)
        .doc(comment.postId)
        .collection(Paths.postComments)
        .add(comment.toDocument());

    final notifications = Notif(
        type: NotifType.comment,
        fromUser: comment.author,
        post: post,
        date: DateTime.now());

    _firebaseFirestore
        .collection(Paths.notifications)
        .doc(post.author.id)
        .collection(Paths.userNotifications)
        .add(notifications.toDocument());
  }

  @override
  void createLike({@required Post post, @required String userId}) {
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(post.id)
        .update({'likes': FieldValue.increment(1)});
    _firebaseFirestore
        .collection(Paths.likes)
        .doc(post.id)
        .collection(Paths.postLikes)
        .doc(userId)
        .set({});

    final notifications = Notif(
        type: NotifType.like,
        fromUser: User.empty.copyWith(id: userId),
        post: post,
        date: DateTime.now());

    _firebaseFirestore
        .collection(Paths.notifications)
        .doc(post.author.id)
        .collection(Paths.userNotifications)
        .add(notifications.toDocument());

  }

  @override
  Future<void> createPost({@required Post post}) async {
    await _firebaseFirestore.collection(Paths.posts).add(post.toDocument());
  }

  @override
  void deleteLike({@required String postId, @required String userId}) {
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(postId)
        .update({'likes': FieldValue.increment(-1)});

    _firebaseFirestore
        .collection(Paths.likes)
        .doc(postId)
        .collection(Paths.postLikes)
        .doc(userId)
        .delete();
  }

  @override
  Future<Set<String>> getLikedPostIds(
      {@required String userId, @required List<Post> posts}) async {
    final postIds = <String>{};
    for (final post in posts) {
      final likeDoc = await _firebaseFirestore
          .collection(Paths.likes)
          .doc(post.id)
          .collection(Paths.postLikes)
          .doc(userId)
          .get();

      if (likeDoc.exists) {
        postIds.add(post.id);
      }
    }
    return postIds;
  }

  @override
  Stream<List<Future<Comment>>> getPostComments({@required String postId}) {
    return _firebaseFirestore
        .collection(Paths.comments)
        .doc(postId)
        .collection(Paths.postComments)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Comment.fromDocument(doc)).toList());
  }

  @override
  Future<List<Post>> getUserFeed(
      {@required String userId, String lastPostId}) async {
    QuerySnapshot postsSnap;
    if (lastPostId == null) {
      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .limit(3)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .doc(lastPostId)
          .get();

      if (!lastPostDoc.exists) {
        return [];
      }
      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(3)
          .get();
    }
    final posts = Future.wait(
        postsSnap.docs.map((doc) => Post.fromDocument(doc)).toList());
    return posts;
  }

  @override
  Stream<List<Future<Post>>> getUserPosts({@required String userId}) {
    final authorRef = _firebaseFirestore.collection(Paths.users).doc(userId);
    return _firebaseFirestore
        .collection(Paths.posts)
        .where('author', isEqualTo: authorRef)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromDocument(doc)).toList());
  }
}
