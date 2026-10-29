import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_it/get_it.dart';
import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';
import 'package:hive_ce/hive.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/app_info_service.dart';
import 'package:voiceclub_partner/core/services/auth_service.dart';
import 'package:voiceclub_partner/core/services/call_entry_service.dart';
import 'package:voiceclub_partner/core/services/call_handling_service.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/core/services/intro_script_service.dart';
import 'package:voiceclub_partner/core/services/location_service.dart';
import 'package:voiceclub_partner/core/services/logging_interceptor.dart';
import 'package:voiceclub_partner/core/services/payout_service.dart';
import 'package:voiceclub_partner/core/services/probation_course_service.dart';
import 'package:voiceclub_partner/core/services/signed_url_service.dart';
import 'package:voiceclub_partner/core/services/survey_service.dart';
import 'package:voiceclub_partner/core/services/app_preferences.dart';
import 'package:voiceclub_partner/core/services/token_service.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/data/data_sources/local/arb_cache_store.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/arb_file_client.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/mock_ui_language_api.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/remote_ui_language_api.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/ui_language_api.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/ui_language_api_service.dart';
import 'package:voiceclub_partner/data/repository/ui_localization_repository_impl.dart';
import 'package:voiceclub_partner/domain/repository/ui_localization_repository.dart';
import 'package:voiceclub_partner/domain/usecases/localization/get_ui_languages.dart';
import 'package:voiceclub_partner/domain/usecases/localization/sync_ui_language.dart';
import 'package:voiceclub_partner/core/services/tutorials_video_service.dart';
import 'package:voiceclub_partner/core/services/updates_service.dart';
import 'package:voiceclub_partner/data/data_sources/local/chat/chat_database_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/account/account_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/agreement/agreement_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/auth/auth_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/blocking/blocking_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/call_logs/call_logs_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/calling/calling_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/calling/calling_firebase_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/chat/chat_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/chat/chat_firebase_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/cleanvoice/cleanvoice_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/config/config_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/events/events_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/fcm/fcm_config_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/feature/feature_firebase_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/file/file_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/file/file_url_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/gifts/gifts_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/hyperverge/hyperverge_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/krutrim_maps/krutrim_maps_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/kyc_file/kyc_file_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/kyc_transaction/kyc_transaction_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/managers_feedback/managers_feedback_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/metrics/metrics_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/notifications/notifications_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/open_ai/openai_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/query/no_auth_query_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/query/query_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/query/query_firebase_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/rating/rating_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/rewards/rewards_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/social/social_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/stories/stories_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/survey/survey_firebase_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/tier/tier_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/unsplash/unsplash_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/wallet/wallet_api_service.dart';
import 'package:voiceclub_partner/data/repository/account_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/agreement_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/auth_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/blocking_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/call_logs_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/calling_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/chat_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/cleanvoice_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/config_repostiory_impl.dart';
import 'package:voiceclub_partner/data/repository/events_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/fcm_config_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/feature_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/file_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/file_url_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/gifts_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/hyperverge_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/krutrim_maps_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/kyc_file_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/kyc_transaction_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/managers_feedback_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/metrics_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/notifications_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/openai_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/no_auth_query_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/query_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/rating_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/rewards_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/social_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/stories_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/survey_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/tier_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/unsplash_repository_impl.dart';
import 'package:voiceclub_partner/data/repository/wallet_repository_impl.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';
import 'package:voiceclub_partner/domain/repository/agreement_repository.dart';
import 'package:voiceclub_partner/domain/repository/auth_repository.dart';
import 'package:voiceclub_partner/domain/repository/blocking_repository.dart';
import 'package:voiceclub_partner/domain/repository/call_logs_repository.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';
import 'package:voiceclub_partner/domain/repository/cleanvoice_repository.dart';
import 'package:voiceclub_partner/domain/repository/config_repository.dart';
import 'package:voiceclub_partner/domain/repository/events_repository.dart';
import 'package:voiceclub_partner/domain/repository/fcm_config_repository.dart';
import 'package:voiceclub_partner/domain/repository/feature_repository.dart';
import 'package:voiceclub_partner/domain/repository/file_repository.dart';
import 'package:voiceclub_partner/domain/repository/file_url_repository.dart';
import 'package:voiceclub_partner/domain/repository/gifts_repository.dart';
import 'package:voiceclub_partner/domain/repository/hyperverge_repository.dart';
import 'package:voiceclub_partner/domain/repository/krutrim_maps_repository.dart';
import 'package:voiceclub_partner/domain/repository/kyc_file_repository.dart';
import 'package:voiceclub_partner/domain/repository/kyc_transaction_repository.dart';
import 'package:voiceclub_partner/domain/repository/managers_feedback_repository.dart';
import 'package:voiceclub_partner/domain/repository/notifications_repository.dart';
import 'package:voiceclub_partner/domain/repository/openai_repository.dart';
import 'package:voiceclub_partner/domain/repository/no_auth_query_repository.dart';
import 'package:voiceclub_partner/domain/repository/probation_repository.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';
import 'package:voiceclub_partner/domain/repository/rating_repository.dart';
import 'package:voiceclub_partner/domain/repository/rewards_repository.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';
import 'package:voiceclub_partner/domain/repository/stories_repository.dart';
import 'package:voiceclub_partner/domain/repository/survey_repository.dart';
import 'package:voiceclub_partner/domain/repository/tier_repository.dart';
import 'package:voiceclub_partner/domain/repository/unsplash_repository.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_account_preference.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_audio_status.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_criteria_users.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_current_online_duration.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_kyc.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_meeting_schedule.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_onboarding_details.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_onboarding_selfie.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_profile.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_reverse_calls.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_rewards_stats.dart';
import 'package:voiceclub_partner/domain/usecases/account/mark_onboarding_completed.dart';
import 'package:voiceclub_partner/domain/usecases/account/mark_onboarding_stage_course_completed.dart';
import 'package:voiceclub_partner/domain/usecases/account/search_criteria_users.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_account_preference.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_esign.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_kyc.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_language.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_location.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_notification_preference.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_onboarding_stage.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_recording.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_status.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_supply_profile.dart';
import 'package:voiceclub_partner/domain/usecases/agreement/get_file_url.dart';
import 'package:voiceclub_partner/domain/usecases/agreement/update_sign_document.dart';
import 'package:voiceclub_partner/domain/usecases/auth/logout.dart';
import 'package:voiceclub_partner/domain/usecases/blocking/block_user.dart';
import 'package:voiceclub_partner/domain/usecases/blocking/get_blocked_users.dart';
import 'package:voiceclub_partner/domain/usecases/blocking/report_user.dart';
import 'package:voiceclub_partner/domain/usecases/call_logs/fetch_call_logs_for_pair.dart';
import 'package:voiceclub_partner/domain/usecases/call_logs/fetch_log_recording_url.dart';
import 'package:voiceclub_partner/domain/usecases/calling/accept_call.dart';
import 'package:voiceclub_partner/domain/usecases/calling/end_call.dart';
import 'package:voiceclub_partner/domain/usecases/calling/end_hung_call.dart';
import 'package:voiceclub_partner/domain/usecases/calling/fetch_call_entry_stream.dart';
import 'package:voiceclub_partner/domain/usecases/calling/fetch_call_state_stream.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_call_details.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_current_call.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_hung_call.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_logs_grouped.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_reverse_calling_stats.dart';
import 'package:voiceclub_partner/domain/usecases/calling/ping_call.dart';
import 'package:voiceclub_partner/domain/usecases/calling/place_call.dart';
import 'package:voiceclub_partner/domain/usecases/calling/set_ring.dart';
import 'package:voiceclub_partner/domain/usecases/chat/add_chat_note.dart';
import 'package:voiceclub_partner/domain/usecases/chat/delete_chat_groups_from_database.dart';
import 'package:voiceclub_partner/domain/usecases/chat/delete_chat_message.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_chat_features_unlock_criteria.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_chat_messages.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_init_messages_stream.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_last_seen_timestamp_stream.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_total_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_unseen_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_active_users.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_call_recording.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_filter_options.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_group_by_account_id.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_group_by_id.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_groups.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_attachment_url.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_groups_from_database.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_notes.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_filtered_chat_groups.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_local_fetched_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_local_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_pending_audios.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_scroll_position.dart';
import 'package:voiceclub_partner/domain/usecases/chat/report_chat_message.dart';
import 'package:voiceclub_partner/domain/usecases/chat/save_chat_groups_to_database.dart';
import 'package:voiceclub_partner/domain/usecases/chat/save_local_fetched_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/save_local_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/save_scroll_position.dart';
import 'package:voiceclub_partner/domain/usecases/chat/search_chat_groups.dart';
import 'package:voiceclub_partner/domain/usecases/chat/send_audio_greeting.dart';
import 'package:voiceclub_partner/domain/usecases/chat/send_broadcast_message.dart';
import 'package:voiceclub_partner/domain/usecases/chat/send_chat_message.dart';
import 'package:voiceclub_partner/domain/usecases/chat/update_custom_name.dart';
import 'package:voiceclub_partner/domain/usecases/chat/update_reaction.dart';
import 'package:voiceclub_partner/domain/usecases/chat/update_reply.dart';
import 'package:voiceclub_partner/domain/usecases/chat/upload_chat_attachment.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/clean_audio_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/create_edit_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/delete_edit_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/get_edit_status_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/get_signed_url_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/poll_edit_status_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/upload_file_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/config/get_app_config_status.dart';
import 'package:voiceclub_partner/domain/usecases/config/get_intro_audio_settings.dart';
import 'package:voiceclub_partner/domain/usecases/config/get_languages.dart';

import 'package:voiceclub_partner/domain/usecases/config/get_support_questions_config.dart';
import 'package:voiceclub_partner/domain/usecases/events/get_event_data.dart';
import 'package:voiceclub_partner/domain/usecases/events/get_pending_events_list.dart';
import 'package:voiceclub_partner/domain/usecases/events/mark_event.dart';
import 'package:voiceclub_partner/domain/usecases/fcm_config/update_supply_fcm.dart';
import 'package:voiceclub_partner/domain/usecases/feature/get_last_seen_time.dart';
import 'package:voiceclub_partner/domain/usecases/feature/has_seen_whatsapp_group.dart';
import 'package:voiceclub_partner/domain/usecases/feature/mark_whatsapp_group_as_seen.dart';
import 'package:voiceclub_partner/domain/usecases/feature/update_last_time.dart';
import 'package:voiceclub_partner/domain/usecases/file/get_signed_file_url.dart';
import 'package:voiceclub_partner/domain/usecases/file/upload_file.dart';
import 'package:voiceclub_partner/domain/usecases/gifts/can_receive_gifts.dart';
import 'package:voiceclub_partner/domain/usecases/hyperverge/get_esign_output.dart';
import 'package:voiceclub_partner/domain/usecases/hyperverge/get_kyc_output.dart';
import 'package:voiceclub_partner/domain/usecases/krutrim_maps/get_address.dart';
import 'package:voiceclub_partner/domain/usecases/kyc_file/upload_kyc_file.dart';
import 'package:voiceclub_partner/domain/usecases/managers_feedback/get_managers_feedback.dart';
import 'package:voiceclub_partner/domain/usecases/managers_feedback/update_managers_feedback_status.dart';
import 'package:voiceclub_partner/domain/usecases/metrics/get_metrics_score.dart';
import 'package:voiceclub_partner/domain/usecases/metrics/get_probation_details.dart';
import 'package:voiceclub_partner/domain/usecases/metrics/mark_probation_course_completed.dart';
import 'package:voiceclub_partner/domain/usecases/notifications/add_notification.dart';
import 'package:voiceclub_partner/domain/usecases/notifications/test_notification.dart';
import 'package:voiceclub_partner/domain/usecases/openai/analyze_audio.dart';
import 'package:voiceclub_partner/domain/usecases/query/end_no_auth_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/end_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/fetch_query_chat_messages_stream.dart';
import 'package:voiceclub_partner/domain/usecases/query/get_daily_query_raised_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/query/get_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/get_unseen_kam_query_chat_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/query/list_query_sessions.dart';
import 'package:voiceclub_partner/domain/usecases/query/send_no_auth_query_message.dart';
import 'package:voiceclub_partner/domain/usecases/query/send_query_message.dart';
import 'package:voiceclub_partner/domain/usecases/query/start_no_auth_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/start_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/watch_no_auth_query_messages.dart';
import 'package:voiceclub_partner/domain/usecases/query/update_ai_call_count_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/rating/add_rating.dart';
import 'package:voiceclub_partner/domain/usecases/rating/get_all_ratings.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/claim_gift.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_active_rewards.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_gifts.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_rewards_config_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_rewards_cutoff.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_rewards_leaderboard.dart';
import 'package:voiceclub_partner/domain/usecases/social/create_comment.dart';
import 'package:voiceclub_partner/domain/usecases/social/create_post.dart';
import 'package:voiceclub_partner/domain/usecases/social/create_reply.dart';
import 'package:voiceclub_partner/domain/usecases/social/delete_comment.dart';
import 'package:voiceclub_partner/domain/usecases/social/get_all_reactions.dart';
import 'package:voiceclub_partner/domain/usecases/social/get_pending_post_status.dart';
import 'package:voiceclub_partner/domain/usecases/social/get_post_by_id.dart';
import 'package:voiceclub_partner/domain/usecases/social/get_post_reactions.dart';
import 'package:voiceclub_partner/domain/usecases/social/like_comment.dart';
import 'package:voiceclub_partner/domain/usecases/social/like_post.dart';
import 'package:voiceclub_partner/domain/usecases/social/like_reply.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_comments.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_my_posts.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_my_user_posts.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_posts.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_replies.dart';
import 'package:voiceclub_partner/domain/usecases/social/react_post.dart';
import 'package:voiceclub_partner/domain/usecases/social/unlike_comment.dart';
import 'package:voiceclub_partner/domain/usecases/social/unlike_post.dart';
import 'package:voiceclub_partner/domain/usecases/social/unlike_reply.dart';
import 'package:voiceclub_partner/domain/usecases/social/unreact_post.dart';
import 'package:voiceclub_partner/domain/usecases/stories/delete_story.dart';
import 'package:voiceclub_partner/domain/usecases/stories/get_my_story.dart';
import 'package:voiceclub_partner/domain/usecases/stories/upload_other_file_types.dart';
import 'package:voiceclub_partner/domain/usecases/stories/upload_story.dart';
import 'package:voiceclub_partner/domain/usecases/stories/upload_story_audio_file.dart';
import 'package:voiceclub_partner/domain/usecases/survey/check_survey_submission.dart';
import 'package:voiceclub_partner/domain/usecases/survey/get_user_submitted_surveys.dart';
import 'package:voiceclub_partner/domain/usecases/survey/mark_survey_submitted.dart';
import 'package:voiceclub_partner/domain/usecases/tier/get_weekly_online_duration.dart';
import 'package:voiceclub_partner/domain/usecases/transaction/get_kyc_transaction_id.dart';
import 'package:voiceclub_partner/domain/usecases/transaction/mark_kyc_failed.dart';
import 'package:voiceclub_partner/domain/usecases/unsplash/search_photos.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/fetch_transcations.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_coin_balance.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_coins_transactions.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_milestone_earnings.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_overview.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_payout_breakdown.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_payout_count.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_recent_payout.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_transaction_details.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_wallet_detail.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/withdraw_payout.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ==========================================
  // Dio
  // ==========================================

  final appInfo = await AppInfoService().getAppInfo();
  final appHeaders = <String, dynamic>{
    if (appInfo.version != null) 'X-App-Version': appInfo.version!,
    if (appInfo.buildNumber != null)
      'X-App-Build': appInfo.buildNumber.toString(),
    'Operating-System': Platform.operatingSystem,
  };

  sl.registerSingleton<AppPreferences>(AppPreferences());
  await sl<AppPreferences>().migrateLegacyStorageIfNeeded();

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<ArbCacheStore>(ArbCacheStore(prefs));

  sl.registerSingleton<TokenService>(TokenService(sl()));

  sl.registerSingleton<Dio>(
    Dio(BaseOptions(baseUrl: APIConstants.baseProdURL, headers: appHeaders)),
  );
  sl<TokenService>().registerDio(sl<Dio>());

  final noAuthDio = Dio(
    BaseOptions(baseUrl: APIConstants.baseProdURL, headers: appHeaders),
  )..interceptors.add(IsolateLoggingInterceptor());

  sl.registerSingleton<UiLanguageApiService>(UiLanguageApiService(noAuthDio));
  sl.registerSingleton<UiLanguageApi>(
    RemoteUiLanguageApi(
      sl<UiLanguageApiService>(),
      fallback: MockUiLanguageApi(),
    ),
  );
  sl.registerSingleton<ArbFileClient>(HttpArbFileClient(Dio()));
  sl.registerSingleton<UiLocalizationRepository>(
    UiLocalizationRepositoryImpl(
      sl<UiLanguageApi>(),
      sl<ArbCacheStore>(),
      sl<ArbFileClient>(),
    ),
  );
  sl.registerSingleton<GetUiLanguagesUseCase>(GetUiLanguagesUseCase(sl()));
  sl.registerSingleton<SyncUiLanguageUseCase>(SyncUiLanguageUseCase(sl()));
  sl.registerSingleton<UiLocalizationService>(
    UiLocalizationService(
      sl<GetUiLanguagesUseCase>(),
      sl<SyncUiLanguageUseCase>(),
      sl<UiLocalizationRepository>(),
    ),
  );

  final generateProfileImageDio = Dio(
    BaseOptions(baseUrl: APIConstants.generateProfileImageBaseURL),
  );

  sl<TokenService>().registerDio(generateProfileImageDio);

  // ==========================================
  // Services
  // ==========================================
  sl.registerSingleton<AuthService>(AuthService(sl(), sl(), sl()));
  sl.registerSingleton<AnalyticsService>(
    AnalyticsService(
      mixpanel: await Mixpanel.init(
        StringConstants.mixpanelToken,
        trackAutomaticEvents: true,
      ),
      firebaseAnalytics: FirebaseAnalytics.instance,
    ),
  );
  sl.registerSingleton<GrowthBookService>(
    GrowthBookService(
      await GBSDKBuilderApp(
        hostURL: StringConstants.growthBookHostURL,
        apiKey: StringConstants.growthBookAPIKey,
        backgroundSync: true,
        growthBookTrackingCallBack: (_) {},
      ).initialize(),
    ),
  );

  // GrowthBook is ready after Dio — attach X-App-Key from the `xappkey` flag.
  final xAppKey = sl<GrowthBookService>().getXAppKey();
  if (xAppKey != null) {
    sl<Dio>().options.headers['X-App-Key'] = xAppKey;
    noAuthDio.options.headers['X-App-Key'] = xAppKey;
  }
  sl.registerSingleton<UpdatesService>(UpdatesService());
  sl.registerSingleton<ProbationCourseService>(ProbationCourseService());
  sl.registerSingleton<LocationService>(LocationService());
  sl.registerSingleton<AlertService>(AlertService());
  sl.registerSingleton<TutorialLessonService>(TutorialLessonService());
  sl.registerLazySingleton(() => CallHandlingService());
  sl.registerLazySingleton(() => CallEntryService());
  sl.registerLazySingleton(() => SurveyService());
  sl.registerLazySingleton(() => IntroScriptService());
  sl.registerLazySingleton(() => PayoutService());

  // ==========================================
  // APIs
  // ==========================================

  sl.registerSingleton<AuthApiService>(AuthApiService(sl()));
  sl.registerSingleton<FileApiService>(FileApiService(sl()));
  sl.registerSingleton<FileUrlApiService>(FileUrlApiService(sl()));
  sl.registerSingleton<BlockingApiService>(BlockingApiService(sl()));
  sl.registerSingleton<ChatApiService>(ChatApiService(sl()));
  sl.registerSingleton<ChatFirebaseService>(ChatFirebaseService());
  sl.registerSingleton<QueryFirebaseService>(QueryFirebaseService());
  sl.registerSingleton<QueryApiService>(QueryApiService(sl()));
  sl.registerSingleton<NoAuthQueryApiService>(NoAuthQueryApiService(noAuthDio));
  sl.registerSingleton<ChatDatabaseService>(
    ChatDatabaseService(
      Hive.box<List>(StringConstants.chatGroupsBoxName),
      Hive.box<int>(StringConstants.messageCountBoxName),
      Hive.box<double>(StringConstants.scrollPostionBoxName),
      Hive.box<int>(StringConstants.fetchedMessageCountBoxName),
    ),
  );
  sl.registerSingleton<CallingFirebaseService>(CallingFirebaseService());
  sl.registerSingleton<KrutrimMapsApiService>(KrutrimMapsApiService(sl()));
  sl.registerSingleton<ConfigApiService>(ConfigApiService(sl()));
  sl.registerSingleton<FCMConfigApiService>(FCMConfigApiService(sl()));
  sl.registerSingleton<CallingApiService>(CallingApiService(sl()));
  sl.registerSingleton<CallLogsApiService>(CallLogsApiService(sl()));
  sl.registerSingleton<RatingApiService>(RatingApiService(sl()));
  sl.registerSingleton<AccountApiService>(AccountApiService(sl()));
  sl.registerSingleton<NotificationsApiService>(NotificationsApiService(sl()));
  sl.registerSingleton<WalletApiService>(WalletApiService(sl()));
  sl.registerSingleton<StoriesApiService>(StoriesApiService(sl()));
  sl.registerSingleton<TierApiService>(TierApiService(sl()));
  sl.registerSingleton<EventsApiService>(EventsApiService(sl()));
  sl.registerSingleton<GiftsApiService>(GiftsApiService(sl()));
  sl.registerSingleton<HypervergeApiService>(HypervergeApiService(sl()));
  sl.registerSingleton<KYCFileApiService>(KYCFileApiService(sl()));
  sl.registerSingleton<ManagersFeedbackApiService>(
    ManagersFeedbackApiService(sl()),
  );
  sl.registerSingleton<MetricsApiService>(MetricsApiService(sl()));
  sl.registerSingleton<RewardsApiService>(RewardsApiService(sl()));
  sl.registerSingleton<AgreementApiService>(AgreementApiService(sl()));
  sl.registerSingleton<FeatureFirebaseService>(FeatureFirebaseService());
  sl.registerSingleton<SocialApiService>(SocialApiService(sl()));
  sl.registerSingleton<UnsplashApiService>(UnsplashApiService(sl()));
  sl.registerSingleton<SurveyFirebaseService>(SurveyFirebaseService());
  sl.registerSingleton<KycTransactionApiService>(
    KycTransactionApiService(sl()),
  );
  sl.registerSingleton<OpenAIApiService>(OpenAIApiService(sl()));
  sl.registerSingleton<CleanVoiceApiService>(CleanVoiceApiService(sl()));

  // ==========================================
  // Repositories
  // ==========================================

  sl.registerSingleton<ConfigRepository>(ConfigRepositoryImpl(sl()));
  sl.registerSingleton<RatingRepository>(RatingRepositoryImpl(sl()));
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  sl.registerSingleton<KrutrimMapsRepository>(KrutrimMapsRepositoryImpl(sl()));
  sl.registerSingleton<BlockingRepository>(BlockingRepositoryImpl(sl()));
  sl.registerSingleton<CallLogsRepository>(CallLogsRepositoryImpl(sl()));
  sl.registerSingleton<CallingRepository>(CallingRepositoryImpl(sl(), sl()));
  sl.registerSingleton<FCMConfigRepository>(FCMConfigRepositoryImpl(sl()));
  sl.registerSingleton<ChatRepository>(ChatRepositoryImpl(sl(), sl(), sl()));
  sl.registerSingleton<QueryRepository>(QueryRepositoryImpl(sl(), sl()));
  sl.registerSingleton<NoAuthQueryRepository>(
    NoAuthQueryRepositoryImpl(sl(), sl()),
  );
  sl.registerSingleton<FileRepository>(FileRepositoryImpl(sl()));
  sl.registerSingleton<FileUrlRepository>(FileUrlRepositoryImpl(sl()));
  sl.registerSingleton<AccountRepository>(AccountRepositoryImpl(sl()));
  sl.registerSingleton<NotificationsRepository>(
    NotificationsRepositoryImpl(sl()),
  );
  sl.registerSingleton<StoriesRepository>(StoriesRepositoryImpl(sl()));
  sl.registerSingleton<WalletRepository>(WalletRepositoryImpl(sl()));
  sl.registerSingleton<TierRepository>(TierRepositoryImpl(sl()));
  sl.registerSingleton<EventsRepository>(EventsRepositoryImpl(sl()));
  sl.registerSingleton<GiftsRepository>(GiftsRepositoryImpl(sl()));
  sl.registerSingleton<HypervergeRepository>(HypervergeRepositoryImpl(sl()));
  sl.registerSingleton<KYCFileRepository>(KYCFileRepositoryImpl(sl()));
  sl.registerSingleton<ManagersFeedbackRepository>(
    ManagersFeedbackRepositoryImpl(sl()),
  );
  sl.registerSingleton<MetricsRepository>(MetricsRepositoryImpl(sl()));
  sl.registerSingleton<RewardsRepository>(RewardsRepositoryImpl(sl()));
  sl.registerSingleton<AgreementRepository>(AgreementRepositoryImpl(sl()));
  sl.registerSingleton<FeatureRepository>(FeatureRepositoryImpl(sl()));
  sl.registerSingleton<SocialRepository>(SocialRepositoryImpl(sl()));
  sl.registerSingleton<UnsplashRepository>(UnsplashRepositoryImpl(sl()));
  sl.registerSingleton<SurveyRepository>(SurveyRepositoryImpl(sl()));
  sl.registerSingleton<OpenAIRepository>(OpenAIRepositoryImpl(sl()));
  sl.registerSingleton<CleanVoiceRepository>(CleanVoiceRepositoryImpl(sl()));
  sl.registerSingleton<KycTransactionRepository>(
    KycTransactionRepositoryImpl(sl()),
  );

  // ==========================================
  // UseCases
  // ==========================================

  // Auth
  sl.registerSingleton<LogoutUsecase>(LogoutUsecase(sl()));

  // Blocking
  sl.registerSingleton<BlockUserUsecase>(BlockUserUsecase(sl()));
  sl.registerSingleton<GetBlockedUsersUseCase>(GetBlockedUsersUseCase(sl()));
  sl.registerSingleton<ReportUserUsecase>(ReportUserUsecase(sl()));

  // Call Logs
  sl.registerSingleton<FetchCallLogsForPairUsecase>(
    FetchCallLogsForPairUsecase(sl()),
  );
  sl.registerSingleton<FetchLogRecordingUrlUsecase>(
    FetchLogRecordingUrlUsecase(sl()),
  );

  // Calling
  sl.registerSingleton<PlaceCallUsecase>(PlaceCallUsecase(sl()));
  sl.registerSingleton<AcceptCallUsecase>(AcceptCallUsecase(sl()));
  sl.registerSingleton<SetRingUsecase>(SetRingUsecase(sl()));
  sl.registerSingleton<GetLogsGroupedUsecase>(GetLogsGroupedUsecase(sl()));
  sl.registerSingleton<PingCallUseCase>(PingCallUseCase(sl()));
  sl.registerSingleton<GetCallDetailsUsecase>(GetCallDetailsUsecase(sl()));
  sl.registerSingleton<EndCallUsecase>(EndCallUsecase(sl()));
  sl.registerSingleton<GetCurrentCallUsecase>(GetCurrentCallUsecase(sl()));
  sl.registerSingleton<GetReverseCallingStatsUsecase>(
    GetReverseCallingStatsUsecase(sl()),
  );
  sl.registerSingleton<GetHungCallUseCase>(GetHungCallUseCase(sl()));
  sl.registerSingleton<EndHungCallUseCase>(EndHungCallUseCase(sl()));
  sl.registerSingleton<FetchCallStateStreamUsecase>(
    FetchCallStateStreamUsecase(sl()),
  );
  sl.registerSingleton<FetchCallEntryStreamUsecase>(
    FetchCallEntryStreamUsecase(sl()),
  );

  // Config
  sl.registerSingleton<GetAppConfigStatusUsecase>(
    GetAppConfigStatusUsecase(sl()),
  );
  sl.registerSingleton<GetLanguagesUseCase>(GetLanguagesUseCase(sl()));

  sl.registerSingleton<GetSupportQuestionsConfigUsecase>(
    GetSupportQuestionsConfigUsecase(sl()),
  );
  sl.registerSingleton<GetIntroAudioSettingsUsecase>(
    GetIntroAudioSettingsUsecase(sl()),
  );
  sl.registerLazySingleton<IntroAudioPolicyService>(
    () => IntroAudioPolicyService(sl<GetIntroAudioSettingsUsecase>()),
  );

  // FCM Config
  sl.registerSingleton<UpdateSupplyFCMUsecase>(UpdateSupplyFCMUsecase(sl()));

  // Rating
  sl.registerSingleton<AddRatingUsecase>(AddRatingUsecase(sl()));
  sl.registerSingleton<GetAllRatingsUsecase>(GetAllRatingsUsecase(sl()));

  // Chat
  sl.registerSingleton<GetChatGroupsUsecase>(GetChatGroupsUsecase(sl()));
  sl.registerSingleton<SearchChatGroupsUsecase>(SearchChatGroupsUsecase(sl()));
  sl.registerSingleton<SendChatMessageUsecase>(SendChatMessageUsecase(sl()));
  sl.registerSingleton<FetchChatFeaturesUnlockCriteriaUsecase>(
    FetchChatFeaturesUnlockCriteriaUsecase(sl()),
  );
  sl.registerSingleton<FetchUnseenCountUsecase>(FetchUnseenCountUsecase(sl()));
  sl.registerSingleton<GetChatGroupByAccountIdUsecase>(
    GetChatGroupByAccountIdUsecase(sl()),
  );
  sl.registerSingleton<SendBroadcastMessageUsecase>(
    SendBroadcastMessageUsecase(sl()),
  );
  sl.registerSingleton<SendAudioGreetingUsecase>(
    SendAudioGreetingUsecase(sl()),
  );
  sl.registerSingleton<GetChatFilterOptionsUsecase>(
    GetChatFilterOptionsUsecase(sl()),
  );
  sl.registerSingleton<GetFilteredChatGroupsUsecase>(
    GetFilteredChatGroupsUsecase(sl()),
  );
  sl.registerSingleton<GetChatGroupByIdUsecase>(GetChatGroupByIdUsecase(sl()));
  sl.registerSingleton<FetchChatMessagesUsecase>(
    FetchChatMessagesUsecase(sl()),
  );
  sl.registerSingleton<FetchInitMessagesStreamUsecase>(
    FetchInitMessagesStreamUsecase(sl()),
  );
  sl.registerSingleton<FetchTotalMessageCountUsecase>(
    FetchTotalMessageCountUsecase(sl()),
  );
  sl.registerSingleton<GetPendingAudiosUseCase>(GetPendingAudiosUseCase(sl()));
  sl.registerSingleton<UpdateCustomNameUseCase>(UpdateCustomNameUseCase(sl()));
  sl.registerSingleton<GetChatGroupsFromDatabaseUsecase>(
    GetChatGroupsFromDatabaseUsecase(sl()),
  );
  sl.registerSingleton<SaveChatGroupsToDatabaseUsecase>(
    SaveChatGroupsToDatabaseUsecase(sl()),
  );
  sl.registerSingleton<DeleteChatGroupsFromDatabaseUsecase>(
    DeleteChatGroupsFromDatabaseUsecase(sl()),
  );
  sl.registerSingleton<GetLocalMessageCountUsecase>(
    GetLocalMessageCountUsecase(sl()),
  );
  sl.registerSingleton<SaveLocalMessageCountUsecase>(
    SaveLocalMessageCountUsecase(sl()),
  );
  sl.registerSingleton<GetLocalFetchedMessageCountUsecase>(
    GetLocalFetchedMessageCountUsecase(sl()),
  );
  sl.registerSingleton<SaveLocalFetchedMessageCountUsecase>(
    SaveLocalFetchedMessageCountUsecase(sl()),
  );
  sl.registerSingleton<GetScrollPositionUsecase>(
    GetScrollPositionUsecase(sl()),
  );
  sl.registerSingleton<SaveScrollPositionUsecase>(
    SaveScrollPositionUsecase(sl()),
  );
  sl.registerSingleton<ReportChatMessageUsecase>(
    ReportChatMessageUsecase(sl()),
  );
  sl.registerSingleton<DeleteChatMessageUsecase>(
    DeleteChatMessageUsecase(sl()),
  );
  sl.registerSingleton<GetActiveUsersUseCase>(GetActiveUsersUseCase(sl()));
  sl.registerSingleton<GetCallRecordingUseCase>(GetCallRecordingUseCase(sl()));
  sl.registerSingleton<GetChatNoteUseCase>(GetChatNoteUseCase(sl()));
  sl.registerSingleton<AddChatNoteUseCase>(AddChatNoteUseCase(sl()));
  sl.registerSingleton<UpdateReactionUseCase>(UpdateReactionUseCase(sl()));
  sl.registerSingleton<FetchLastSeenMessageIdStreamUseCase>(
    FetchLastSeenMessageIdStreamUseCase(sl()),
  );
  sl.registerSingleton<UpdateReplyUseCase>(UpdateReplyUseCase(sl()));
  sl.registerSingleton<UploadChatAttachmentUseCase>(
    UploadChatAttachmentUseCase(sl()),
  );
  sl.registerSingleton<GetChatAttachmentUrlUseCase>(
    GetChatAttachmentUrlUseCase(sl()),
  );
  sl.registerLazySingleton<SignedUrlService>(() => SignedUrlService(sl()));

  // Krutrim Maps
  sl.registerSingleton<GetAddressUseCase>(GetAddressUseCase(sl()));

  // File
  sl.registerSingleton<GetSignedFileUrlUsecase>(GetSignedFileUrlUsecase(sl()));
  sl.registerSingleton<UploadFileUsecase>(UploadFileUsecase(sl()));

  // Account
  sl.registerSingleton<GetProfileUsecase>(GetProfileUsecase(sl()));
  sl.registerSingleton<UpdateRecordingUsecase>(UpdateRecordingUsecase(sl()));
  sl.registerSingleton<UpdateStatusUsecase>(UpdateStatusUsecase(sl()));
  sl.registerSingleton<GetAccountPreferenceUsecase>(
    GetAccountPreferenceUsecase(sl()),
  );
  sl.registerSingleton<UpdateAccountPreferenceUsecase>(
    UpdateAccountPreferenceUsecase(sl()),
  );
  sl.registerSingleton<GetAudioStatusUsecase>(GetAudioStatusUsecase(sl()));
  sl.registerSingleton<GetCurrentOnlineDurationUseCase>(
    GetCurrentOnlineDurationUseCase(sl()),
  );
  sl.registerSingleton<GetCriteriaUsersUseCase>(GetCriteriaUsersUseCase(sl()));
  sl.registerSingleton<SearchCriteriaUsersUseCase>(
    SearchCriteriaUsersUseCase(sl()),
  );
  sl.registerSingleton<UpdateLanguageUseCase>(UpdateLanguageUseCase(sl()));
  sl.registerSingleton<UpdateNotificationPreferenceUseCase>(
    UpdateNotificationPreferenceUseCase(sl()),
  );
  sl.registerSingleton<UpdateKYCUsecase>(UpdateKYCUsecase(sl()));
  sl.registerSingleton<GetKYCUsecase>(GetKYCUsecase(sl()));
  sl.registerSingleton<UpdateLocationUseCase>(UpdateLocationUseCase(sl()));
  sl.registerSingleton<GetReverseCallsUseCase>(GetReverseCallsUseCase(sl()));
  sl.registerSingleton<UpdateOnboardingStageUseCase>(
    UpdateOnboardingStageUseCase(sl()),
  );
  sl.registerSingleton<MarkOnboardingStageCourseCompletedUseCase>(
    MarkOnboardingStageCourseCompletedUseCase(sl()),
  );
  sl.registerSingleton<UpdateSupplyProfileUseCase>(
    UpdateSupplyProfileUseCase(sl()),
  );
  sl.registerSingleton<GetOnboardingSelfieUsecase>(
    GetOnboardingSelfieUsecase(sl()),
  );
  sl.registerSingleton<GetMeetingScheduleUseCase>(
    GetMeetingScheduleUseCase(sl()),
  );
  sl.registerSingleton<MarkOnboardingCompletedUseCase>(
    MarkOnboardingCompletedUseCase(sl()),
  );
  sl.registerSingleton<GetRewardsStatsUseCase>(GetRewardsStatsUseCase(sl()));
  sl.registerSingleton<UpdateESignUsecase>(UpdateESignUsecase(sl()));
  sl.registerSingleton<GetOnboardingDetailsUseCase>(
    GetOnboardingDetailsUseCase(sl()),
  );
  // Notifications
  sl.registerSingleton<AddNotificationUsecase>(AddNotificationUsecase(sl()));
  sl.registerSingleton<TestNotificationUsecase>(TestNotificationUsecase(sl()));

  // Stories
  sl.registerSingleton<DeleteStoryUsecase>(DeleteStoryUsecase(sl()));
  sl.registerSingleton<GetMyStoryUsecase>(GetMyStoryUsecase(sl()));
  sl.registerSingleton<UploadStoryAudioFileUsecase>(
    UploadStoryAudioFileUsecase(sl()),
  );
  sl.registerSingleton<UploadOtherFileTypesUsecase>(
    UploadOtherFileTypesUsecase(sl()),
  );
  sl.registerSingleton<UploadStoryUsecase>(UploadStoryUsecase(sl()));

  // Wallet
  sl.registerSingleton<FetchTranscationsUseCase>(
    FetchTranscationsUseCase(sl()),
  );
  sl.registerSingleton<GetOverviewUsecase>(GetOverviewUsecase(sl()));
  sl.registerSingleton<GetWalletDetailUsecase>(GetWalletDetailUsecase(sl()));
  sl.registerSingleton<GetTransactionDetailsUseCase>(
    GetTransactionDetailsUseCase(sl()),
  );
  sl.registerSingleton<GetPayoutBreakdownUseCase>(
    GetPayoutBreakdownUseCase(sl()),
  );
  sl.registerSingleton<GetMilestoneEarningsUsecase>(
    GetMilestoneEarningsUsecase(sl()),
  );
  sl.registerSingleton<GetCoinBalanceUseCase>(GetCoinBalanceUseCase(sl()));
  sl.registerSingleton<GetCoinsTransactionsUseCase>(
    GetCoinsTransactionsUseCase(sl()),
  );
  sl.registerSingleton<GetPayoutCountUseCase>(GetPayoutCountUseCase(sl()));
  sl.registerSingleton<GetRecentPayoutUseCase>(GetRecentPayoutUseCase(sl()));
  sl.registerSingleton<WithdrawPayoutUseCase>(WithdrawPayoutUseCase(sl()));

  // Tier
  sl.registerSingleton<GetWeeklyOnlineDurationUsecase>(
    GetWeeklyOnlineDurationUsecase(sl()),
  );

  // Events
  sl.registerSingleton<GetEventDataUseCase>(GetEventDataUseCase(sl()));
  sl.registerSingleton<GetPendingEventsListUseCase>(
    GetPendingEventsListUseCase(sl()),
  );
  sl.registerSingleton<MarkEventUseCase>(MarkEventUseCase(sl()));

  // Managers Feedback
  sl.registerSingleton<GetManagersFeedbackUseCase>(
    GetManagersFeedbackUseCase(sl()),
  );
  sl.registerSingleton<UpdateManagersFeedbackStatusUseCase>(
    UpdateManagersFeedbackStatusUseCase(sl()),
  );

  // Gifts
  sl.registerSingleton<CanReceiveGiftsUsecase>(CanReceiveGiftsUsecase(sl()));

  // Hyperverge
  sl.registerSingleton<GetKYCOutputUsecase>(GetKYCOutputUsecase(sl()));
  sl.registerSingleton<GetESignOutputUsecase>(GetESignOutputUsecase(sl()));

  // KYC File
  sl.registerSingleton<UploadKYCFileUsecase>(UploadKYCFileUsecase(sl()));
  sl.registerSingleton<GetFileUrlUseCase>(GetFileUrlUseCase(sl()));

  // Probation
  sl.registerSingleton<GetProbationDetailsUsecase>(
    GetProbationDetailsUsecase(sl()),
  );
  sl.registerSingleton<MarkProbationCourseCompletedUsecase>(
    MarkProbationCourseCompletedUsecase(sl()),
  );
  sl.registerSingleton<GetMetricsScoreUseCase>(GetMetricsScoreUseCase(sl()));

  // Multi Rewards
  sl.registerSingleton<GetActiveRewardsUseCase>(GetActiveRewardsUseCase(sl()));
  sl.registerSingleton<GetRewardsLeaderboardUseCase>(
    GetRewardsLeaderboardUseCase(sl()),
  );
  sl.registerSingleton<GetRewardsCutoffUseCase>(GetRewardsCutoffUseCase(sl()));
  sl.registerSingleton<GetRewardsConfigUseCase>(GetRewardsConfigUseCase(sl()));
  sl.registerSingleton<GetGiftsUseCase>(GetGiftsUseCase(sl()));
  sl.registerSingleton<ClaimGiftUseCase>(ClaimGiftUseCase(sl()));

  // Query
  sl.registerSingleton<FetchQueryChatMessagesStreamUseCase>(
    FetchQueryChatMessagesStreamUseCase(sl()),
  );
  sl.registerSingleton<StartQuerySessionUseCase>(
    StartQuerySessionUseCase(sl()),
  );
  sl.registerSingleton<GetQuerySessionUseCase>(GetQuerySessionUseCase(sl()));
  sl.registerSingleton<GetUnseenKamQueryChatMessageCountUseCase>(
    GetUnseenKamQueryChatMessageCountUseCase(sl()),
  );
  sl.registerSingleton<SendQueryMessageUseCase>(SendQueryMessageUseCase(sl()));
  sl.registerSingleton<EndQuerySessionUseCase>(EndQuerySessionUseCase(sl()));
  sl.registerSingleton<ListQuerySessionsUseCase>(
    ListQuerySessionsUseCase(sl()),
  );
  sl.registerSingleton<GetDailyQueryRaisedCountUseCase>(
    GetDailyQueryRaisedCountUseCase(sl()),
  );
  sl.registerSingleton<StartNoAuthQuerySessionUseCase>(
    StartNoAuthQuerySessionUseCase(sl()),
  );
  sl.registerSingleton<SendNoAuthQueryMessageUseCase>(
    SendNoAuthQueryMessageUseCase(sl()),
  );
  sl.registerSingleton<EndNoAuthQuerySessionUseCase>(
    EndNoAuthQuerySessionUseCase(sl()),
  );
  sl.registerSingleton<WatchNoAuthQueryMessagesUseCase>(
    WatchNoAuthQueryMessagesUseCase(sl()),
  );
  sl.registerSingleton<UpdateAiCallCountUseCase>(
    UpdateAiCallCountUseCase(sl()),
  );

  // Agreement
  sl.registerSingleton<UpdateSignDocument>(UpdateSignDocument(sl()));

  // Features
  sl.registerSingleton<GetLastSeenTimeUseCase>(GetLastSeenTimeUseCase(sl()));
  sl.registerSingleton<UpdateLastSeenTimeUseCase>(
    UpdateLastSeenTimeUseCase(sl()),
  );
  sl.registerSingleton<HasSeenWhatsAppGroupUseCase>(
    HasSeenWhatsAppGroupUseCase(sl()),
  );
  sl.registerSingleton<MarkWhatsAppGroupAsSeenUseCase>(
    MarkWhatsAppGroupAsSeenUseCase(sl()),
  );

  // Social
  sl.registerSingleton<CreatePostUsecase>(CreatePostUsecase(sl(), sl()));
  sl.registerSingleton<GetPostByIdUsecase>(GetPostByIdUsecase(sl()));
  sl.registerSingleton<ListPostsUsecase>(ListPostsUsecase(sl()));
  sl.registerSingleton<ListCommentsUsecase>(ListCommentsUsecase(sl()));
  sl.registerSingleton<ListRepliesUsecase>(ListRepliesUsecase(sl()));
  sl.registerSingleton<ListMyPostsUsecase>(ListMyPostsUsecase(sl()));
  sl.registerSingleton<ListMyUserPostsUsecase>(ListMyUserPostsUsecase(sl()));
  sl.registerSingleton<LikePostUsecase>(LikePostUsecase(sl()));
  sl.registerSingleton<UnlikePostUsecase>(UnlikePostUsecase(sl()));
  sl.registerSingleton<CreateCommentUsecase>(CreateCommentUsecase(sl()));
  sl.registerSingleton<ReactPostUsecase>(ReactPostUsecase(sl()));
  sl.registerSingleton<UnReactPostUsecase>(UnReactPostUsecase(sl()));
  sl.registerSingleton<LikeCommentUsecase>(LikeCommentUsecase(sl()));
  sl.registerSingleton<UnlikeCommentUsecase>(UnlikeCommentUsecase(sl()));
  sl.registerSingleton<CreateReplyUsecase>(CreateReplyUsecase(sl()));
  sl.registerSingleton<LikeReplyUsecase>(LikeReplyUsecase(sl()));
  sl.registerSingleton<UnlikeReplyUsecase>(UnlikeReplyUsecase(sl()));
  sl.registerSingleton<GetPostReactionsUsecase>(GetPostReactionsUsecase(sl()));
  sl.registerSingleton<GetPendingPostStatusUsecase>(
    GetPendingPostStatusUsecase(sl()),
  );
  sl.registerSingleton<DeleteCommentUsecase>(DeleteCommentUsecase(sl()));
  sl.registerSingleton<GetAllReactionsUsecase>(GetAllReactionsUsecase(sl()));

  // Unsplash
  sl.registerSingleton<SearchPhotosUsecase>(SearchPhotosUsecase(sl()));

  // Survey
  sl.registerSingleton<CheckSurveySubmission>(CheckSurveySubmission(sl()));
  sl.registerSingleton<MarkSurveySubmitted>(MarkSurveySubmitted(sl()));
  sl.registerSingleton<GetUserSubmittedSurveys>(GetUserSubmittedSurveys(sl()));

  // OpenAI
  sl.registerSingleton<AnalyzeAudioUseCase>(AnalyzeAudioUseCase(sl()));

  // CleanVoice
  sl.registerSingleton<GetSignedUrlUseCase>(GetSignedUrlUseCase(sl()));
  sl.registerSingleton<UploadFileUseCase>(UploadFileUseCase(sl()));
  sl.registerSingleton<CreateEditUseCase>(CreateEditUseCase(sl()));
  sl.registerSingleton<GetEditStatusUseCase>(GetEditStatusUseCase(sl()));
  sl.registerSingleton<DeleteEditUseCase>(DeleteEditUseCase(sl()));
  sl.registerSingleton<CleanAudioUseCase>(CleanAudioUseCase(sl()));
  sl.registerSingleton<PollEditStatusUseCase>(PollEditStatusUseCase(sl()));

  // Transaction
  sl.registerSingleton<GetKycTransactionIdUseCase>(
    GetKycTransactionIdUseCase(sl()),
  );
  sl.registerSingleton<MarkKycFailedUseCase>(MarkKycFailedUseCase(sl()));

  // ==========================================
  // Controllers
  // ==========================================
  sl.registerLazySingleton(() => CallController());
  sl.registerFactory<ChatMessagesControllerFactory>(
    () => ChatMessagesControllerFactory(),
  );

  // ==========================================
  // Interceptors
  // ==========================================
  generateProfileImageDio.interceptors.add(LoggingInterceptor());
}
