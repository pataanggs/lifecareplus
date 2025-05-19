part of 'home_cubit.dart';

class HomeStateData extends Equatable {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final bool isLoggedIn;
  final String? errorMessage;
  final String? gender;
  final int? age;
  final int? weight;
  final int? height;
  final double? bmi;

  const HomeStateData({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isEmailVerified = false,
    this.isLoggedIn = false,
    this.errorMessage,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.bmi,
  });

  HomeStateData copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isEmailVerified,
    bool? isLoggedIn,
    String? errorMessage,
    String? gender,
    int? age,
    int? weight,
    int? height,
    double? bmi,
  }) {
    return HomeStateData(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: errorMessage ?? this.errorMessage,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
    );
  }

  bool get hasUser => uid != null && email != null;
  bool get isProfileComplete => hasUser && displayName != null;

  @override
  List<Object?> get props {
    return [
      uid,
      email,
      displayName,
      photoURL,
      isEmailVerified,
      isLoggedIn,
      errorMessage,
      gender,
      age,
      weight,
      height,
      bmi,
    ];
  }
}

sealed class HomeState extends Equatable {
  final HomeStateData data;
  const HomeState(this.data);

  @override
  List<Object?> get props => [data];
}

class HomeStateInitial extends HomeState {
  const HomeStateInitial() : super(const HomeStateData());
}

class HomeStateLoading extends HomeState {
  const HomeStateLoading(super.data);
}

class HomeStateLoaded extends HomeState {
  const HomeStateLoaded(super.data);
}

class HomeStateFailure extends HomeState {
  const HomeStateFailure(super.data);
}
