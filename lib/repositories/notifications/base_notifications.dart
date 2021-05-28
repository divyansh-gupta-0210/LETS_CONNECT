import 'package:lets_connect/models/models.dart';

abstract class BaseNotificationRepository {
  Stream<List<Future<Notif>>> getUserNotifications({String userId});
}