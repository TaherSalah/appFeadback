import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/communities/domain/repositories/communities_repository.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/explore_communities_state.dart';

class ExploreCommunitiesCubit extends Cubit<ExploreCommunitiesState> {
  final CommunitiesRepository repository;

  ExploreCommunitiesCubit({required this.repository}) : super(ExploreCommunitiesInitial());

  Future<void> loadAvailableCommunities() async {
    emit(ExploreCommunitiesLoading());
    
    // First, get the profile to know the gender
    final profileResult = await repository.getProfile();
    String gender = 'both';
    
    await profileResult.fold(
      (failure) async {
        emit(const ExploreCommunitiesError(message: 'Profile not found. Please setup your profile first.'));
      },
      (profile) async {
        gender = profile['gender'] ?? 'both';
        
        // Then, fetch communities targeting this gender or 'both'
        final result = await repository.getAvailableCommunities(gender);
        final joinedResult = await repository.getUserCommunities();
        
        List<String> joinedIds = [];
        joinedResult.fold(
          (l) => null,
          (joined) => joinedIds = joined.map((e) => e.id).toList(),
        );

        result.fold(
          (failure) => emit(ExploreCommunitiesError(message: failure.errorMessage)),
          (communities) => emit(ExploreCommunitiesLoaded(
            communities: communities,
            joinedCommunityIds: joinedIds,
          )),
        );
      }
    );
  }

  Future<void> joinCommunity(String communityId) async {
    emit(ExploreCommunityJoinLoading());
    final result = await repository.joinCommunityById(communityId);
    result.fold(
      (failure) {
        emit(ExploreCommunitiesError(message: failure.errorMessage));
        loadAvailableCommunities(); // Reload list
      },
      (community) {
        emit(ExploreCommunityJoinSuccess());
      },
    );
  }
}
