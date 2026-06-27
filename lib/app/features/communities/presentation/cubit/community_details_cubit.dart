import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/meeting.dart';
import 'package:muslimdaily/app/features/communities/domain/repositories/communities_repository.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/community_details_state.dart';
import 'package:uuid/uuid.dart';

class CommunityDetailsCubit extends Cubit<CommunityDetailsState> {
  final CommunitiesRepository repository;
  

  List<Meeting> currentMeetings = [];

  CommunityDetailsCubit({required this.repository}) : super(CommunityDetailsInitial());

  Future<void> loadDetails(String communityId) async {
    emit(CommunityDetailsLoading());
    
    // Get profile to determine gender and teacher status
    final profileResult = await repository.getProfile();
    String gender = 'both';
    bool isTeacher = false;
    profileResult.fold(
      (l) => null,
      (profile) {
        gender = profile['gender'] ?? 'both';
        isTeacher = profile['is_teacher'] == 'true';
      },
    );

    final meetingsResult = await repository.getCommunityMeetings(communityId);
    
    String? errorMessage;
    
    meetingsResult.fold(
      (failure) => errorMessage = failure.errorMessage,
      (meetings) {
        currentMeetings = meetings.where((m) => 
          isTeacher || m.targetGender == 'both' || m.targetGender == gender
        ).toList();
      },
    );

    if (errorMessage != null) {
      emit(CommunityDetailsError(message: errorMessage!));
    } else {
      emit(CommunityDetailsLoaded(meetings: currentMeetings));
    }
  }



  Future<void> createMeeting({
    required String communityId,
    required String title,
    String? meetUrl,
    required DateTime meetingDate,
    required int durationMinutes,
  }) async {
    emit(CommunityDetailsActionLoading());
    
    final newMeeting = Meeting(
      id: const Uuid().v4(),
      communityId: communityId,
      title: title,
      meetUrl: meetUrl,
      meetingDate: meetingDate,
      durationMinutes: durationMinutes,
      createdBy: '',
      createdAt: DateTime.now(),
    );

    final result = await repository.createMeeting(newMeeting);
    result.fold(
      (failure) => emit(CommunityDetailsError(message: failure.errorMessage)),
      (meeting) {
        emit(CommunityDetailsActionSuccess());
        loadDetails(communityId); // Reload
      },
    );
  }
}
