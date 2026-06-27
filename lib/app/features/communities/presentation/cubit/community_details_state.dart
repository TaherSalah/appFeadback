import 'package:equatable/equatable.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/meeting.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/post.dart';

abstract class CommunityDetailsState extends Equatable {
  const CommunityDetailsState();

  @override
  List<Object> get props => [];
}

class CommunityDetailsInitial extends CommunityDetailsState {}

class CommunityDetailsLoading extends CommunityDetailsState {}

class CommunityDetailsLoaded extends CommunityDetailsState {
  final List<Meeting> meetings;

  const CommunityDetailsLoaded({
    required this.meetings,
  });

  @override
  List<Object> get props => [meetings];
}

class CommunityDetailsError extends CommunityDetailsState {
  final String message;

  const CommunityDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}

class CommunityDetailsActionLoading extends CommunityDetailsState {}

class CommunityDetailsActionSuccess extends CommunityDetailsState {}
