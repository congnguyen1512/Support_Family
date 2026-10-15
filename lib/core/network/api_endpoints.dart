class ApiEndpoints {
  const ApiEndpoints._();

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

  static const String me = '/me';
  static const String meAvatar = '/me/avatar';
  static const String usersSearch = '/users/search';

  static const String relationships = '/relationships';
  static const String relationshipsInvite = '/relationships/invite';

  static const String notifications = '/notifications';
  static const String notificationsFall = '/notifications/fall';
  static const String devicesFcmToken = '/devices/fcm-token';
  static const String chatThreads = '/messages/threads';
  static const String chatPresence = '/messages/presence';
  static const String locationsMe = '/locations/me';
  static const String locationsFamily = '/locations/family';
  static const String safeZones = '/safe-zones';
  static const String safeZoneEvents = '/safe-zones/events';
  static const String kidReminders = '/kid-reminders';
  static const String reminders = '/reminders';
  static const String remindersBulkDelete = '/reminders/bulk-delete';
  static const String quickContacts = '/quick-contacts';

  static const String medicalAppointments = '/medical-appointments';
  static String medicalAppointmentById(int id) => '$medicalAppointments/$id';

  static const String physicalActivities = '/physical-activities';
  static String physicalActivityById(int id) => '$physicalActivities/$id';
  static String physicalActivityToggle(int id) => '$physicalActivities/$id/toggle';
  static const String physicalMetrics = '/physical-activities/metrics';

  static const String healthReport = '/health-tracking/report';
  static const String healthLogs = '/health-tracking/logs';
  static String healthLogById(int id) => '$healthLogs/$id';

  static String relationshipById(int id) => '$relationships/$id';

  static String notificationRespond(int id) => '$notifications/$id/respond';
  static String chatByPeer(String peerUid) => '/messages/$peerUid';
  static String safeZoneById(String id) => '$safeZones/$id';
  static String kidReminderById(int id) => '$kidReminders/$id';
  static String reminderById(int id) => '$reminders/$id';
}
