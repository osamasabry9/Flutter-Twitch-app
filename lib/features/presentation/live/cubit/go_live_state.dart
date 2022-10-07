abstract class GoLiveState  {}

// ----------------live states
class GoLiveInitialState extends GoLiveState {}

class GoLiveLoadingState extends GoLiveState {}

class GoLiveSuccessState extends GoLiveState {}

class GoLiveErrorState extends GoLiveState {
  final String error;

  GoLiveErrorState(this.error);
}
// ---------------- user states
class GetUserLoadingState extends GoLiveState {}
class GetUserSuccessState extends GoLiveState {}
class GetUserErrorState extends GoLiveState {
  final String error;

  GetUserErrorState(this.error);
}

// ----------------get image states
class GoLiveImagePackerLoadingState extends GoLiveState {}
class GoLiveImagePackerSuccessState extends GoLiveState {}
class GoLiveImagePackerErrorState extends GoLiveState {
  final String error;

  GoLiveImagePackerErrorState(this.error);
}


// Post Image packer
class GoLiveUploadImageLoadingState extends GoLiveState {}
class GoLiveUploadImageSuccessState extends GoLiveState {}
class GoLiveImageRemoveState extends GoLiveState {}
class GoLiveUploadImageErrorState extends GoLiveState {
  final String error;

  GoLiveUploadImageErrorState(this.error);
}

