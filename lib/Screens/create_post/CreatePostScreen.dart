import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:lets_connect/Screens/create_post/cubit/create_post_cubit.dart';
import 'package:lets_connect/helper/image_helper.dart';
import 'package:lets_connect/widgets/error_dialog.dart';

class CreatePostScreen extends StatelessWidget {
  static const String routeName = '/createPost';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CreatePostScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Text'),
        ),
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state.status == CreatePostStatus.success) {
              _formKey.currentState.reset();
              context.read<CreatePostCubit>().reset();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.purple,
                  content: const Text(
                    'Post Created',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            } else if (state.status == CreatePostStatus.error) {
              showDialog(
                  context: context,
                  builder: (context) =>
                      ErrorDialog(content: state.failure.message));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _selectPostImage(context),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: state.postImage != null
                          ? Image.file(
                              state.postImage,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 120,
                            ),
                    ),
                  ),
                  if (state.status == CreatePostStatus.submitting)
                    const LinearProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(hintText: 'Caption'),
                            onChanged: (value) => context
                                .read<CreatePostCubit>()
                                .captionChanged(value),
                            validator: (value) => value.trim().isEmpty
                                ? 'Caption cannot be empty'
                                : null,
                          ),
                          const SizedBox(
                            height: 28.0,
                          ),
                          RaisedButton(
                            elevation: 1.0,
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            onPressed: () => _submitForm(
                                context,
                                state.postImage,
                                state.status == CreatePostStatus.submitting),
                            child: Text('Post'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectPostImage(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallary(
        context: context, cropStyle: CropStyle.rectangle, title: 'Create Post');
    if (pickedFile != null) {
      context.read<CreatePostCubit>().postImageChanged(pickedFile);
    }
  }

  void _submitForm(BuildContext context, File postImage, bool isSubmitting) {
    if(_formKey.currentState.validate() && postImage != null && !isSubmitting){
      context.read<CreatePostCubit>().submit();
    }
  }
}
