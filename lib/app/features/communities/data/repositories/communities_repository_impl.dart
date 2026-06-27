import 'package:dartz/dartz.dart';
import 'package:muslimdaily/app/core/errors/failure.dart';
import 'package:muslimdaily/app/features/communities/data/datasources/communities_remote_data_source.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/community.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/post.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/meeting.dart';
import 'package:muslimdaily/app/features/communities/domain/repositories/communities_repository.dart';
import 'package:muslimdaily/app/features/communities/data/datasources/communities_local_data_source.dart';

class CommunitiesRepositoryImpl implements CommunitiesRepository {
  final CommunitiesRemoteDataSource remoteDataSource;
  final CommunitiesLocalDataSource localDataSource;

  CommunitiesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Community>>> getUserCommunities() async {
    try {
      final result = await remoteDataSource.getUserCommunities();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Community>> createCommunity(Community community) async {
    try {
      final result = await remoteDataSource.createCommunity(community);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Community>> joinCommunity(String inviteCode) async {
    try {
      final result = await remoteDataSource.joinCommunity(inviteCode);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Community>> joinCommunityById(String communityId) async {
    try {
      final result = await remoteDataSource.joinCommunityById(communityId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Community>>> getAvailableCommunities(String gender) async {
    try {
      final result = await remoteDataSource.getAvailableCommunities(gender);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getCommunityPosts(String communityId) async {
    try {
      final result = await remoteDataSource.getCommunityPosts(communityId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> createPost(Post post) async {
    try {
      final result = await remoteDataSource.createPost(post);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Meeting>>> getCommunityMeetings(String communityId) async {
    try {
      final result = await remoteDataSource.getCommunityMeetings(communityId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Meeting>> createMeeting(Meeting meeting) async {
    try {
      final result = await remoteDataSource.createMeeting(meeting);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasProfile() async {
    try {
      final result = await localDataSource.hasProfile();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveProfile(String name, String gender, {String? email, String? phone, String? location}) async {
    try {
      bool isTeacher = false;
      bool isExisting = false;
      try {
        final result = await remoteDataSource.saveUserProfile(name, gender, email: email, phone: phone, location: location);
        isTeacher = result['isTeacher'] ?? false;
        isExisting = result['isExisting'] ?? false;
      } catch (e) {
        print('Remote save failed: $e');
      }
      await localDataSource.saveProfile(name, gender, email: email, phone: phone, location: location, isTeacher: isTeacher);
      return Right(isExisting);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getProfile() async {
    try {
      final result = await localDataSource.getProfile();
      if (result != null) {
        // Background sync to update role
        _syncRemoteProfile(result);
        return Right(result);
      } else {
        return Left(ServerFailure(errorMessage: 'Profile not found'));
      }
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _syncRemoteProfile(Map<String, String> localProfile) async {
    try {
      final result = await remoteDataSource.saveUserProfile(
        localProfile['name'] ?? '', 
        localProfile['gender'] ?? 'male',
        email: localProfile['email'],
        phone: localProfile['phone'],
        location: localProfile['location'],
      );
      final isTeacher = result['isTeacher'] ?? false;
      
      await localDataSource.saveProfile(
        localProfile['name'] ?? '', 
        localProfile['gender'] ?? 'male',
        email: localProfile['email'],
        phone: localProfile['phone'],
        location: localProfile['location'],
        isTeacher: isTeacher
      );
    } catch (e) {
      print('Background profile sync failed: $e');
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUsersStatistics() async {
    try {
      final result = await remoteDataSource.getUsersStatistics();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearProfile() async {
    try {
      await localDataSource.clearProfile();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }
}
