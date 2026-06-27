import 'package:dartz/dartz.dart';
import 'package:muslimdaily/app/core/errors/failure.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/community.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/post.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/meeting.dart';

abstract class CommunitiesRepository {
  Future<Either<Failure, List<Community>>> getUserCommunities();
  Future<Either<Failure, Community>> createCommunity(Community community);
  Future<Either<Failure, Community>> joinCommunity(String inviteCode);
  Future<Either<Failure, Community>> joinCommunityById(String communityId);
  Future<Either<Failure, List<Community>>> getAvailableCommunities(String gender);
  
  Future<Either<Failure, List<Post>>> getCommunityPosts(String communityId);
  Future<Either<Failure, Post>> createPost(Post post);
  
  Future<Either<Failure, List<Meeting>>> getCommunityMeetings(String communityId);
  Future<Either<Failure, Meeting>> createMeeting(Meeting meeting);

  Future<Either<Failure, bool>> hasProfile();
  Future<Either<Failure, bool>> saveProfile(String name, String gender, {String? email, String? phone, String? location});
  Future<Either<Failure, Map<String, String>>> getProfile();
  Future<Either<Failure, Map<String, dynamic>>> getUsersStatistics();
  Future<Either<Failure, void>> clearProfile();
}
