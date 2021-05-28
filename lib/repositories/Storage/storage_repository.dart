import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:lets_connect/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

class StorageRepository extends BaseStorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  Future<String> _uploadImage(
      {@required File image, @required String ref}) async {
    final downLoadUrl = await _firebaseStorage
        .ref(ref)
        .putFile(image)
        .then((taskSnapshot) => taskSnapshot.ref.getDownloadURL());

    return downLoadUrl;
  }

  @override
  Future<String> uploadProfileImage(
      {@required String url, @required File image}) async{
    var imageId = Uuid().v4();

    if(url.isNotEmpty){
      final exp = RegExp(r'userProfile_(.*).jpg');
      imageId = exp.firstMatch(url)[1];
    }

    final downloadUrl = await _uploadImage(image: image, ref: 'images/users/userProfile_$imageId.jpg');
    return downloadUrl;
  }

  @override
  Future<String> uploadPostImage({@required File image}) async{
    final imageId = Uuid().v4();
    final downloadUrl = await _uploadImage(image: image, ref: 'images/posts/posts_$imageId.jpg');
    return downloadUrl;
  }
}
