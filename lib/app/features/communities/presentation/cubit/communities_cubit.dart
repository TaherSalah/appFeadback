import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/community.dart';
import 'package:muslimdaily/app/features/communities/domain/repositories/communities_repository.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_state.dart';
import 'package:uuid/uuid.dart';

class CommunitiesCubit extends Cubit<CommunitiesState> {
  final CommunitiesRepository repository;

  CommunitiesCubit({required this.repository}) : super(CommunitiesInitial());

  Future<void> getUserCommunities() async {
    emit(CommunitiesLoading());
    final hasProfileResult = await repository.hasProfile();
    bool hasProfile = false;
    hasProfileResult.fold((l) => null, (r) => hasProfile = r);

    if (!hasProfile) {
      emit(CommunitiesProfileRequired());
      return;
    }

    final result = await repository.getUserCommunities();
    result.fold(
      (failure) => emit(CommunitiesError(message: failure.errorMessage)),
      (communities) => emit(CommunitiesLoaded(communities: communities)),
    );
  }

  Future<bool> saveProfile(String name, String gender, {String? email, String? phone, String? location}) async {
    emit(CommunitiesLoading());
    final result = await repository.saveProfile(name, gender, email: email, phone: phone, location: location);
    bool isExisting = false;
    result.fold(
      (failure) => emit(CommunitiesError(message: failure.errorMessage)),
      (existing) {
        isExisting = existing;
        getUserCommunities();
      },
    );
    return isExisting;
  }

  Future<void> createCommunity({
    required String name,
    String? description,
    String? communityType,
    String targetGender = 'both',
  }) async {
    emit(CommunityActionLoading());
    
    final inviteCode = const Uuid().v4().substring(0, 8).toUpperCase();
    final newCommunity = Community(
      id: const Uuid().v4(),
      name: name,
      description: description,
      inviteCode: inviteCode,
      communityType: communityType,
      targetGender: targetGender,
      createdBy: '', // Set by Supabase
      createdAt: DateTime.now(),
    );

    final result = await repository.createCommunity(newCommunity);
    result.fold(
      (failure) => emit(CommunitiesError(message: failure.errorMessage)),
      (community) => emit(CommunityActionSuccess(community: community)),
    );
  }

  Future<void> joinCommunity(String inviteCode) async {
    emit(CommunityActionLoading());
    final result = await repository.joinCommunity(inviteCode);
    result.fold(
      (failure) => emit(CommunitiesError(message: failure.errorMessage)),
      (community) => emit(CommunityActionSuccess(community: community)),
    );
  }

  Future<void> joinCommunityById(String communityId) async {
    emit(CommunityActionLoading());
    final result = await repository.joinCommunityById(communityId);
    result.fold(
      (failure) => emit(CommunitiesError(message: failure.errorMessage)),
      (community) => emit(CommunityActionSuccess(community: community)),
    );
  }

  Future<void> getUsersStatistics() async {
    emit(CommunitiesLoading());
    final result = await repository.getUsersStatistics();
    result.fold(
      (failure) => emit(CommunitiesError(message: failure.errorMessage)),
      (stats) => emit(CommunitiesStatisticsLoaded(statistics: stats)),
    );
  }

  Future<void> logout() async {
    emit(CommunitiesLoading());
    await repository.clearProfile();
    emit(CommunitiesProfileRequired());
  }
}
