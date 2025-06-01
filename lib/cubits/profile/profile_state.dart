// ignore_for_file: library_private_types_in_public_api

import 'package:lifecareplus/models/user_profile.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileStateInitial extends ProfileState {
  const ProfileStateInitial();
}

class ProfileStateLoading extends ProfileState {
  const ProfileStateLoading();
}

class ProfileStateLoaded extends ProfileState {
  final UserProfile profile;
  const ProfileStateLoaded(this.profile);
}

class ProfileStateError extends ProfileState {
  final String message;
  const ProfileStateError(this.message);
}
