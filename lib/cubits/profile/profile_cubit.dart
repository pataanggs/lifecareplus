import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifecareplus/services/auth_service.dart';
import 'dart:developer' as developer;

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthService _authService;

  ProfileCubit(this._authService) : super(const ProfileStateInitial());

  Future<void> loadUserProfile() async {
    try {
      emit(const ProfileStateLoading());

      developer.log('Fetching user profile...');
      final userProfile = await _authService.getCurrentUserProfile();

      if (userProfile == null) {
        emit(
          const ProfileStateError(
            'Tidak dapat memuat profil. Pastikan Anda telah masuk.',
          ),
        );
        return;
      }

      emit(ProfileStateLoaded(userProfile));
    } catch (e) {
      developer.log('Error loading profile: $e');
      emit(ProfileStateError('Terjadi kesalahan saat memuat profil: $e'));
    }
  }
}
