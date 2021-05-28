import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_connect/Screens/Profile/bloc/profile_bloc.dart';
import 'package:lets_connect/Screens/edit_profile/edit_profile_screen.dart';

class ProfileButton extends StatelessWidget {
  final bool isCurrentUser;
  final bool isFollowing;

  const ProfileButton(
      {Key key, @required this.isCurrentUser, @required this.isFollowing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isCurrentUser
        ? FlatButton(
            hoverColor: Colors.indigoAccent,
            onPressed: () => Navigator.of(context).pushNamed(
                EditProfileScreen.routeName,
                arguments: EditProfileScreenArgs(context: context)),
            color: Colors.lightBlue,
            textColor: Colors.white,
            child: const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 16.0, letterSpacing: 0.9),
            ),
          )
        : FlatButton(
            hoverColor: Colors.indigoAccent,
            onPressed: () => isFollowing
                ? context.read<ProfileBloc>().add(ProfileUnfollowUser())
                : context.read<ProfileBloc>().add(ProfileFollowUser()),
            textColor: isFollowing ? Colors.black : Colors.white,
            color: isFollowing ? Colors.grey[300] : Colors.lightBlue,
            child: Text(
              isFollowing ? 'Unfollow' : 'Follow',
              style: TextStyle(
                fontSize: 16.0,
                letterSpacing: 0.9,
              ),
            ),
          );
  }
}
