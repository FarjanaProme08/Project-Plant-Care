import '../models/plant.dart';
import 'notification_service.dart';

class CareScheduler {
  final NotificationService _notificationService;

  CareScheduler(this._notificationService);

  // Helper to generate a unique integer ID from plant string ID for notifications
  int _generateHashId(String plantId, String type) {
    return (plantId + type).hashCode;
  }

  Future<void> scheduleAllCareForPlant(Plant plant) async {
    // Cancel existing
    await cancelAllCareForPlant(plant.id);

    // Water
    if (plant.waterIntervalDays > 0) {
      await _notificationService.scheduleNotification(
        id: _generateHashId(plant.id, 'water'),
        title: 'Watering Reminder',
        body: 'It is time to water your ${plant.name}',
        scheduledDate: plant.nextWaterDate,
      );
    }

    // Mist
    if (plant.mistIntervalDays > 0 && plant.nextMistDate != null) {
      await _notificationService.scheduleNotification(
        id: _generateHashId(plant.id, 'mist'),
        title: 'Misting Reminder',
        body: 'It is time to mist your ${plant.name}',
        scheduledDate: plant.nextMistDate!,
      );
    }

    // Fertilizer
    if (plant.fertilizerIntervalDays > 0 && plant.nextFertilizerDate != null) {
      await _notificationService.scheduleNotification(
        id: _generateHashId(plant.id, 'fertilize'),
        title: 'Fertilizing Reminder',
        body: 'It is time to fertilize your ${plant.name}',
        scheduledDate: plant.nextFertilizerDate!,
      );
    }
  }

  Future<void> cancelAllCareForPlant(String plantId) async {
    await _notificationService.cancelNotification(
      _generateHashId(plantId, 'water'),
    );
    await _notificationService.cancelNotification(
      _generateHashId(plantId, 'mist'),
    );
    await _notificationService.cancelNotification(
      _generateHashId(plantId, 'fertilize'),
    );
  }

  // Determine next date when user completes a task
  DateTime calculateNextDate(DateTime fromDate, int intervalDays) {
    if (intervalDays == 0) return fromDate;
    return fromDate.add(Duration(days: intervalDays));
  }
}
