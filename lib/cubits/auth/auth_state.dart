part of 'auth_cubit.dart';

class AuthStateData extends Equatable {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final bool isLoggedIn;

  const AuthStateData({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isEmailVerified = false,
    this.isLoggedIn = false,
  });

  AuthStateData copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isEmailVerified,
    bool? isLoggedIn,
  }) {
    return AuthStateData(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoURL,
    isEmailVerified,
    isLoggedIn,
  ];
}

sealed class AuthState extends Equatable {
  final AuthStateData data;
  const AuthState(this.data);

  @override
  List<Object?> get props => [data];
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial() : super(const AuthStateData());
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading(super.data);
}

class AuthStateLoaded extends AuthState {
  const AuthStateLoaded(super.data);
}

class AuthStateFailure extends AuthState {
  const AuthStateFailure(super.data);
}
