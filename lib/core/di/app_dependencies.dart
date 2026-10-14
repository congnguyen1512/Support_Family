import 'dart:async';

import 'package:family_guard/core/network/api_client.dart';
import 'package:family_guard/core/network/api_base_url_resolver.dart';
import 'package:family_guard/core/notifications/notification_badge_controller.dart';
import 'package:family_guard/core/realtime/supabase_realtime_client.dart';
import 'package:family_guard/core/services/location_tracking_service.dart';
import 'package:family_guard/core/storage/session_storage.dart';
import 'package:family_guard/features/chat/data/chat_remote_data_source.dart';
import 'package:family_guard/features/chat/data/chat_service.dart';
import 'package:family_guard/features/login/data/datasources/auth_local_data_source.dart';
import 'package:family_guard/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:family_guard/features/login/data/repositories_impl/auth_repository_impl.dart';
import 'package:family_guard/features/login/domain/repositories/auth_repository.dart';
import 'package:family_guard/features/login/domain/usecases/get_current_token_usecase.dart';
import 'package:family_guard/features/login/domain/usecases/get_current_user_usecase.dart';
import 'package:family_guard/features/login/domain/usecases/get_saved_session_usecase.dart';
import 'package:family_guard/features/login/domain/usecases/load_current_session_usecase.dart';
import 'package:family_guard/features/login/domain/usecases/login_usecase.dart';
import 'package:family_guard/features/login/domain/usecases/logout_usecase.dart';
import 'package:family_guard/features/member_management/data/datasources/member_management_remote_data_source.dart';
import 'package:family_guard/features/member_management/data/repositories_impl/member_management_repository_impl.dart';
import 'package:family_guard/features/member_management/domain/repositories/member_management_repository.dart';
import 'package:family_guard/features/member_management/domain/usecases/delete_relationship_usecase.dart';
import 'package:family_guard/features/member_management/domain/usecases/get_relationships_usecase.dart';
import 'package:family_guard/features/member_management/domain/usecases/invite_relationship_usecase.dart';
import 'package:family_guard/features/member_management/domain/usecases/search_users_usecase.dart';
import 'package:family_guard/features/member_management/domain/usecases/update_relationship_usecase.dart';
import 'package:family_guard/features/location_tracking/data/datasources/location_remote_datasource.dart';
import 'package:family_guard/features/location_tracking/data/repository/location_repository_impl.dart';
import 'package:family_guard/features/location_tracking/domain/repository/location_repository.dart';
import 'package:family_guard/features/location_tracking/domain/usecases/get_family_locations_usecase.dart';
import 'package:family_guard/features/location_tracking/domain/usecases/get_my_location_usecase.dart';
import 'package:family_guard/features/location_tracking/domain/usecases/update_my_location_usecase.dart';
import 'package:family_guard/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:family_guard/features/notification/data/repositories_impl/notification_repository_impl.dart';
import 'package:family_guard/features/notification/domain/repositories/notification_repository.dart';
import 'package:family_guard/features/notification/domain/usecases/create_fall_notification_usecase.dart';
import 'package:family_guard/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:family_guard/features/notification/domain/usecases/respond_notification_usecase.dart';
import 'package:family_guard/features/profile_security/data/datasources/profile_remote_data_source.dart';
import 'package:family_guard/features/profile_security/data/repositories_impl/profile_repository_impl.dart';
import 'package:family_guard/features/profile_security/domain/repositories/profile_repository.dart';
import 'package:family_guard/features/profile_security/domain/usecases/get_profile_usecase.dart';
import 'package:family_guard/features/profile_security/domain/usecases/upload_avatar_usecase.dart';
import 'package:family_guard/features/profile_security/domain/usecases/update_profile_usecase.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_remote_data_source.dart';
import 'package:family_guard/features/safe_zone/data/datasources/safe_zone_service.dart';
import 'package:family_guard/features/safe_zone/data/repositories_impl/safe_zone_repository_impl.dart';
import 'package:family_guard/features/safe_zone/domain/repositories/safe_zone_repository.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/create_safe_zone_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/delete_safe_zone_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/get_safe_zones_usecase.dart';
import 'package:family_guard/features/safe_zone/domain/usecases/update_safe_zone_usecase.dart';

class AppDependencies {
  AppDependencies._();

  static final AppDependencies instance = AppDependencies._();

  bool _initialized = false;
  bool get isInitializedForSafeZoneFallback => _initialized;

  late final SessionStorage sessionStorage;
  late final AuthLocalDataSource authLocalDataSource;
  late final ApiClient apiClient;
  late final String apiBaseUrl;
  late final SupabaseRealtimeClient realtimeClient;
  late final NotificationBadgeController notificationBadgeController;
  late final LocationTrackingService locationTrackingService;

  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository authRepository;
  late final LoginUseCase loginUseCase;
  late final LogoutUseCase logoutUseCase;
  late final GetCurrentUserUseCase getCurrentUserUseCase;
  late final GetSavedSessionUseCase getSavedSessionUseCase;
  late final LoadCurrentSessionUseCase loadCurrentSessionUseCase;
  late final GetCurrentTokenUseCase getCurrentTokenUseCase;

  late final ProfileRemoteDataSource profileRemoteDataSource;
  late final ProfileRepository profileRepository;
  late final GetProfileUseCase getProfileUseCase;
  late final UpdateProfileUseCase updateProfileUseCase;
  late final UploadAvatarUseCase uploadAvatarUseCase;

  late final MemberManagementRemoteDataSource memberManagementRemoteDataSource;
  late final MemberManagementRepository memberManagementRepository;
  late final GetRelationshipsUseCase getRelationshipsUseCase;
  late final SearchUsersUseCase searchUsersUseCase;
  late final InviteRelationshipUseCase inviteRelationshipUseCase;
  late final UpdateRelationshipUseCase updateRelationshipUseCase;
  late final DeleteRelationshipUseCase deleteRelationshipUseCase;

  late final NotificationRemoteDataSource notificationRemoteDataSource;
  late final NotificationRepository notificationRepository;
  late final GetNotificationsUseCase getNotificationsUseCase;
  late final RespondNotificationUseCase respondNotificationUseCase;
  late final CreateFallNotificationUseCase createFallNotificationUseCase;

  late final LocationRemoteDataSource locationRemoteDataSource;
  late final LocationRepository locationRepository;
  late final UpdateMyLocationUseCase updateMyLocationUseCase;
  late final GetMyLocationUseCase getMyLocationUseCase;
  late final GetFamilyLocationsUseCase getFamilyLocationsUseCase;

  late final SafeZoneRemoteDataSource safeZoneRemoteDataSource;
  late final SafeZoneRepository safeZoneRepository;
  late final CreateSafeZoneUseCase createSafeZoneUseCase;
  late final GetSafeZonesUseCase getSafeZonesUseCase;
  late final UpdateSafeZoneUseCase updateSafeZoneUseCase;
  late final DeleteSafeZoneUseCase deleteSafeZoneUseCase;
  late final SafeZoneService safeZoneService;
  late final ChatRemoteDataSource chatRemoteDataSource;
  late final ChatService chatService;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    sessionStorage = SessionStorage();
    authLocalDataSource = AuthLocalDataSourceImpl(sessionStorage);
    apiBaseUrl = await const ApiBaseUrlResolver().resolve();
    apiClient = ApiClient(
      tokenProvider: authLocalDataSource,
      baseUrl: apiBaseUrl,
    );
    realtimeClient = SupabaseRealtimeClient(
      authLocalDataSource: authLocalDataSource,
    );

    authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
    authRepository = AuthRepositoryImpl(
      remote: authRemoteDataSource,
      local: authLocalDataSource,
    );
    loginUseCase = LoginUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
    getSavedSessionUseCase = GetSavedSessionUseCase(authRepository);
    loadCurrentSessionUseCase = LoadCurrentSessionUseCase(authRepository);
    getCurrentTokenUseCase = GetCurrentTokenUseCase(authRepository);

    profileRemoteDataSource = ProfileRemoteDataSourceImpl(apiClient: apiClient);
    profileRepository = ProfileRepositoryImpl(
      remote: profileRemoteDataSource,
      authLocalDataSource: authLocalDataSource,
    );
    getProfileUseCase = GetProfileUseCase(profileRepository);
    updateProfileUseCase = UpdateProfileUseCase(profileRepository);
    uploadAvatarUseCase = UploadAvatarUseCase(profileRepository);

    memberManagementRemoteDataSource = MemberManagementRemoteDataSourceImpl(
      apiClient: apiClient,
    );
    memberManagementRepository = MemberManagementRepositoryImpl(
      remote: memberManagementRemoteDataSource,
    );
    getRelationshipsUseCase = GetRelationshipsUseCase(
      memberManagementRepository,
    );
    searchUsersUseCase = SearchUsersUseCase(memberManagementRepository);
    inviteRelationshipUseCase = InviteRelationshipUseCase(
      memberManagementRepository,
    );
    updateRelationshipUseCase = UpdateRelationshipUseCase(
      memberManagementRepository,
    );
    deleteRelationshipUseCase = DeleteRelationshipUseCase(
      memberManagementRepository,
    );

    notificationRemoteDataSource = NotificationRemoteDataSourceImpl(
      apiClient: apiClient,
    );
    notificationRepository = NotificationRepositoryImpl(
      remote: notificationRemoteDataSource,
    );
    getNotificationsUseCase = GetNotificationsUseCase(notificationRepository);
    respondNotificationUseCase = RespondNotificationUseCase(
      notificationRepository,
    );
    createFallNotificationUseCase = CreateFallNotificationUseCase(
      notificationRepository,
    );

    locationRemoteDataSource = LocationRemoteDataSourceImpl(
      apiClient: apiClient,
    );
    locationRepository = LocationRepositoryImpl(
      remote: locationRemoteDataSource,
    );
    updateMyLocationUseCase = UpdateMyLocationUseCase(locationRepository);
    getMyLocationUseCase = GetMyLocationUseCase(locationRepository);
    getFamilyLocationsUseCase = GetFamilyLocationsUseCase(locationRepository);
    locationTrackingService = LocationTrackingService(
      updateMyLocationUseCase: updateMyLocationUseCase,
    );

    safeZoneRemoteDataSource = SafeZoneRemoteDataSourceImpl(
      apiClient: apiClient,
    );
    safeZoneRepository = SafeZoneRepositoryImpl(
      remote: safeZoneRemoteDataSource,
    );
    createSafeZoneUseCase = CreateSafeZoneUseCase(safeZoneRepository);
    getSafeZonesUseCase = GetSafeZonesUseCase(safeZoneRepository);
    updateSafeZoneUseCase = UpdateSafeZoneUseCase(safeZoneRepository);
    deleteSafeZoneUseCase = DeleteSafeZoneUseCase(safeZoneRepository);
    safeZoneService = SafeZoneService(
      getSafeZonesUseCase: getSafeZonesUseCase,
      createSafeZoneUseCase: createSafeZoneUseCase,
      updateSafeZoneUseCase: updateSafeZoneUseCase,
      deleteSafeZoneUseCase: deleteSafeZoneUseCase,
      getRelationshipsUseCase: getRelationshipsUseCase,
    );
    chatRemoteDataSource = ChatRemoteDataSource(apiClient: apiClient);
    chatService = ChatService(remoteDataSource: chatRemoteDataSource);

    notificationBadgeController = NotificationBadgeController(
      getNotificationsUseCase: getNotificationsUseCase,
      realtimeClient: realtimeClient,
    );

    final savedSession = await authLocalDataSource.getSavedSession();
    if (savedSession != null) {
      await safeZoneService.initialize(force: true);
      unawaited(locationTrackingService.start());
    }

    _initialized = true;
  }
}
