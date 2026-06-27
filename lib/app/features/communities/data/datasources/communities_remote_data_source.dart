import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:muslimdaily/app/features/communities/data/models/community_model.dart';
import 'package:muslimdaily/app/features/communities/data/models/post_model.dart';
import 'package:muslimdaily/app/features/communities/data/models/meeting_model.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/community.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/post.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/meeting.dart';

abstract class CommunitiesRemoteDataSource {
  Future<List<CommunityModel>> getUserCommunities();
  Future<CommunityModel> createCommunity(Community community);
  Future<CommunityModel> joinCommunity(String inviteCode);
  Future<CommunityModel> joinCommunityById(String communityId);
  Future<List<CommunityModel>> getAvailableCommunities(String gender);
  
  Future<List<PostModel>> getCommunityPosts(String communityId);
  Future<PostModel> createPost(Post post);
  
  Future<List<MeetingModel>> getCommunityMeetings(String communityId);
  Future<MeetingModel> createMeeting(Meeting meeting);

  Future<Map<String, bool>> saveUserProfile(String name, String gender, {String? email, String? phone, String? location});
  Future<Map<String, dynamic>> getUsersStatistics();
}

class CommunitiesRemoteDataSourceImpl implements CommunitiesRemoteDataSource {
  final SupabaseClient supabase;

  CommunitiesRemoteDataSourceImpl({required this.supabase});

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('communities_user_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('communities_user_id', deviceId);
    }
    return deviceId;
  }

  @override
  Future<List<CommunityModel>> getUserCommunities() async {
    final userId = await _getUserId();

    final response = await supabase
        .from('community_members')
        .select('communities(*)')
        .eq('user_id', userId);

    final List<CommunityModel> communities = [];
    for (var row in response) {
      if (row['communities'] != null) {
        communities.add(CommunityModel.fromJson(row['communities']));
      }
    }
    return communities;
  }

  @override
  Future<CommunityModel> createCommunity(Community community) async {
    final userId = await _getUserId();

    final model = CommunityModel(
      id: community.id,
      name: community.name,
      description: community.description,
      image: community.image,
      inviteCode: community.inviteCode,
      communityType: community.communityType,
      targetGender: community.targetGender,
      createdBy: userId,
      createdAt: community.createdAt,
    );

    final response = await supabase.from('communities').insert(model.toJson()).select().single();
    final createdCommunity = CommunityModel.fromJson(response);

    // Add creator as admin member
    await supabase.from('community_members').insert({
      'community_id': createdCommunity.id,
      'user_id': userId,
      'role': 'admin',
    });

    return createdCommunity;
  }

  @override
  Future<CommunityModel> joinCommunity(String inviteCode) async {
    final userId = await _getUserId();

    // Find community by invite code
    final communityResponse = await supabase
        .from('communities')
        .select()
        .eq('invite_code', inviteCode)
        .single();
    
    final community = CommunityModel.fromJson(communityResponse);

    // Check if user already joined to avoid duplicate errors
    final existingMember = await supabase
        .from('community_members')
        .select()
        .eq('community_id', community.id)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingMember == null) {
      // Add user as member
      await supabase.from('community_members').insert({
        'community_id': community.id,
        'user_id': userId,
        'role': 'member',
      });
    }

    return community;
  }

  @override
  Future<CommunityModel> joinCommunityById(String communityId) async {
    final userId = await _getUserId();

    final communityResponse = await supabase
        .from('communities')
        .select()
        .eq('id', communityId)
        .single();
    
    final community = CommunityModel.fromJson(communityResponse);

    final existingMember = await supabase
        .from('community_members')
        .select()
        .eq('community_id', community.id)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingMember == null) {
      await supabase.from('community_members').insert({
        'community_id': community.id,
        'user_id': userId,
        'role': 'member',
      });
    }

    return community;
  }

  @override
  Future<List<CommunityModel>> getAvailableCommunities(String gender) async {
    final response = await supabase
        .from('communities')
        .select()
        .or('target_gender.eq.both,target_gender.eq.$gender')
        .order('created_at', ascending: false);

    return (response as List).map((e) => CommunityModel.fromJson(e)).toList();
  }

  @override
  Future<List<PostModel>> getCommunityPosts(String communityId) async {
    final response = await supabase
        .from('posts')
        .select()
        .eq('community_id', communityId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => PostModel.fromJson(e)).toList();
  }

  @override
  Future<PostModel> createPost(Post post) async {
    final userId = await _getUserId();

    final model = PostModel(
      id: post.id,
      communityId: post.communityId,
      title: post.title,
      content: post.content,
      createdBy: userId,
      createdAt: post.createdAt,
    );

    final response = await supabase.from('posts').insert(model.toJson()).select().single();
    return PostModel.fromJson(response);
  }

  @override
  Future<List<MeetingModel>> getCommunityMeetings(String communityId) async {
    final response = await supabase
        .from('meetings')
        .select()
        .eq('community_id', communityId)
        .order('meeting_date', ascending: false);

    return (response as List).map((e) => MeetingModel.fromJson(e)).toList();
  }

  @override
  Future<MeetingModel> createMeeting(Meeting meeting) async {
    final userId = await _getUserId();

    final model = MeetingModel(
      id: meeting.id,
      communityId: meeting.communityId,
      title: meeting.title,
      meetUrl: meeting.meetUrl,
      meetingDate: meeting.meetingDate,
      durationMinutes: meeting.durationMinutes,
      createdBy: userId,
      createdAt: meeting.createdAt,
    );

    final response = await supabase.from('meetings').insert(model.toJson()).select().single();
    return MeetingModel.fromJson(response);
  }

  @override
  Future<Map<String, bool>> saveUserProfile(String name, String gender, {String? email, String? phone, String? location}) async {
    Map<String, dynamic>? existingUser;
    
    if (email != null && email.isNotEmpty) {
      existingUser = await supabase.from('community_users').select().eq('email', email).maybeSingle();
    }
    
    String userId;
    if (existingUser != null) {
      // User exists with this email! Retrieve their ID.
      userId = existingUser['id'];
      // Update local storage to use this retrieved ID!
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('communities_user_id', userId);
    } else {
      userId = await _getUserId();
      existingUser = await supabase.from('community_users').select().eq('id', userId).maybeSingle();
    }

    final data = {
      'id': userId,
      'name': name,
      'gender': gender,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (location != null) 'location': location,
      'updated_at': DateTime.now().toIso8601String(),
    };

    bool isTeacher = false;

    if (existingUser != null) {
      isTeacher = existingUser['is_teacher'] == true;
      await supabase.from('community_users').update(data).eq('id', userId);
    } else {
      data['created_at'] = DateTime.now().toIso8601String();
      await supabase.from('community_users').insert(data);
    }

    return {
      'isTeacher': isTeacher,
      'isExisting': existingUser != null,
    };
  }

  @override
  Future<Map<String, dynamic>> getUsersStatistics() async {
    // We can fetch aggregates or just fetch all and calculate.
    // For small apps, fetching all is fine. For larger, we'd use RPC.
    // Let's fetch the needed fields directly to do calculations.
    final response = await supabase.from('community_users').select('gender, location');
    
    int maleCount = 0;
    int femaleCount = 0;
    Map<String, int> locationCounts = {};

    for (var row in (response as List)) {
      final gender = row['gender'];
      final location = row['location'];

      if (gender == 'male') {
        maleCount++;
      } else if (gender == 'female') {
        femaleCount++;
      }

      if (location != null && location.toString().trim().isNotEmpty) {
        final locStr = location.toString().trim();
        locationCounts[locStr] = (locationCounts[locStr] ?? 0) + 1;
      }
    }

    return {
      'total': response.length,
      'male': maleCount,
      'female': femaleCount,
      'locations': locationCounts,
    };
  }
}
