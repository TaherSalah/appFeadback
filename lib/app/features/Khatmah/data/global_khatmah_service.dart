import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../../../../main.dart';

class GlobalKhatmahService {
  static final GlobalKhatmahService _instance = GlobalKhatmahService._internal();
  factory GlobalKhatmahService() => _instance;
  GlobalKhatmahService._internal();

  final _supabase = Supabase.instance.client;

  /// Fetch recent community campaigns
  Future<List<Map<String, dynamic>>> getActiveCampaigns() async {
    try {
      final response = await _supabase
          .from('community_campaigns')
          .select('*')
          .order('created_at', ascending: false)
          .limit(10);
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      logger.e('Error fetching active campaigns: $e');
    }
    return [];
  }

  /// Fetch all progress items for a specific campaign
  Future<List<Map<String, dynamic>>> getCampaignProgress(String campaignId) async {
    try {
      final response = await _supabase
          .from('community_progress')
          .select('*')
          .eq('campaign_id', campaignId)
          .order('item_index', ascending: true);
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      logger.e('Error fetching campaign progress: $e');
    }
    return [];
  }

  /// Claims or completes an item (Juz/Surah/Page)
  Future<bool> updateItemStatus(String campaignId, int index, String status, {String? userName}) async {
    try {
      // First, check if there's already an entry for this index in this campaign
      final existing = await _supabase
          .from('community_progress')
          .select('id')
          .eq('campaign_id', campaignId)
          .eq('item_index', index)
          .maybeSingle();

      final data = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
        if (userName != null) 'user_name': userName,
      };

      if (existing != null) {
        // Update existing
        await _supabase
            .from('community_progress')
            .update(data)
            .eq('id', existing['id']);
      } else {
        // Create new
        await _supabase.from('community_progress').insert({
          'campaign_id': campaignId,
          'item_index': index,
          ...data,
        });
      }

      // If status is 'completed', we check if all items in the campaign are done
      // (This logic could also be handled by a DB trigger, but we can do a simple check or just rely on total_total)
      
      return true;
    } catch (e) {
      print('Error updating item status: $e');
      return false;
    }
  }

  /// Subscribe to real-time changes for progress
  RealtimeChannel subscribeToProgress(String campaignId, Function(PostgresChangePayload) onEvent) {
    final channel = _supabase.channel('public:community_progress:campaign_id=eq.$campaignId');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'community_progress',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'campaign_id',
        value: campaignId,
      ),
      callback: onEvent,
    ).subscribe();

    return channel;
  }

  /// Automatically release claims that have been in 'reading' status for more than 24 hours
  Future<void> autoReleaseExpiredClaims(String campaignId) async {
    try {
      final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
      
      // Update items that are older than 24 hours and still in 'reading' status
      await _supabase
          .from('community_progress')
          .update({
            'status': 'available',
            'user_name': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('campaign_id', campaignId)
          .eq('status', 'reading')
          .lt('updated_at', twentyFourHoursAgo);
          
    } catch (e) {
      logger.e('Error in autoReleaseExpiredClaims: $e');
    }
  }

  /// Fetch stats for a specific user nickname, optionally filtered by campaign
  Future<Map<String, dynamic>> getUserKhatmahStats(String userName, {String? campaignId}) async {
    try {
      // 1. Fetch user completions
      var query = _supabase
          .from('community_progress')
          .select('id, status, updated_at, item_index, campaign_id')
          .eq('user_name', userName)
          .eq('status', 'completed');
      
      if (campaignId != null) {
        query = query.eq('campaign_id', campaignId);
      }
      
      final response = await query;
      final List data = response as List;
      
      // 2. Calculate total community completions (context-aware)
      var totalQuery = _supabase
          .from('community_progress')
          .select('id')
          .eq('status', 'completed');
          
      if (campaignId != null) {
        totalQuery = totalQuery.eq('campaign_id', campaignId);
      }
      
      final totalCompletionsResp = await totalQuery;
      final totalCompletions = (totalCompletionsResp as List).length;

      return {
        'total_completed': data.length,
        'community_percent': totalCompletions > 0 ? (data.length / totalCompletions * 100).toStringAsFixed(1) : '0',
        'history': data,
      };
    } catch (e) {
      logger.e('Error fetching user stats: $e');
      return {'total_completed': 0, 'community_percent': '0', 'history': []};
    }
  }

  /// Fetch top participants across all campaigns
  Future<List<Map<String, dynamic>>> getGlobalLeaderboard() async {
    try {
      final response = await _supabase
          .from('community_progress')
          .select('user_name')
          .eq('status', 'completed');
      
      final List data = response as List;
      final Map<String, int> counts = {};
      
      for (var row in data) {
        final name = row['user_name'] as String?;
        if (name != null) {
          counts[name] = (counts[name] ?? 0) + 1;
        }
      }

      final sortedList = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
        
      return sortedList.take(5).map((e) => {
        'user_name': e.key,
        'completed_count': e.value,
      }).toList();
    } catch (e) {
      print('Error fetching global leaderboard: $e');
      return [];
    }
  }

  /// Fetch the very latest activity across all campaigns
  Future<List<Map<String, dynamic>>> getRecentGlobalActivity() async {
    try {
      final response = await _supabase
          .from('community_progress')
          .select('user_name, item_index, updated_at, campaign_id, community_campaigns(title, target_type)')
          .eq('status', 'completed')
          .order('updated_at', ascending: false)
          .limit(10);
          
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      logger.e('Error fetching recent global activity: $e');
      return [];
    }
  }

  /// Fetch broad community statistics
  Future<Map<String, dynamic>> getCommunityGlobalStats() async {
    try {
      final today = DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
      
      // 1. Total completions all time
      final totalCompletedResp = await _supabase
          .from('community_progress')
          .select('id')
          .eq('status', 'completed');
          
      // 2. Active readers right now
      final activeReadersResp = await _supabase
          .from('community_progress')
          .select('id')
          .eq('status', 'reading');
          
      // 3. Today's completions
      final todayCompletionsResp = await _supabase
          .from('community_progress')
          .select('id')
          .eq('status', 'completed')
          .gt('updated_at', today);

      return {
        'total_completed': (totalCompletedResp as List).length,
        'active_readers': (activeReadersResp as List).length,
        'today_completions': (todayCompletionsResp as List).length,
      };
    } catch (e) {
      logger.e('Error fetching global stats: $e');
      return {'total_completed': 0, 'active_readers': 0, 'today_completions': 0};
    }
  }
}
