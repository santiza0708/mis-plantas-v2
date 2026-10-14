import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/gemini_api_service.dart';

final databaseHelperProvider = Provider((ref) => DatabaseHelper());
final notificationServiceProvider = Provider((ref) => NotificationService());
final geminiApiServiceProvider = Provider((ref) => GeminiApiService());

/// Provider que genera automáticamente los tips personalizados al abrir la pantalla de diagnóstico
final personalizedCareTipsProvider = FutureProvider.family<List<PersonalizedCareTip>, Plant>((ref, plant) async {
  final geminiService = ref.watch(geminiApiServiceProvider);
  return await geminiService.generatePersonalizedCareTips(plant);
});

final plantListProvider = StateNotifierProvider<PlantListNotifier, AsyncValue<List<Plant>>>((ref) {
  final db = ref.watch(databaseHelperProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return PlantListNotifier(db, notifications);
});

class PlantListNotifier extends StateNotifier<AsyncValue<List<Plant>>> {
  final DatabaseHelper _db;
  final NotificationService _notifications;

  PlantListNotifier(this._db, this._notifications) : super(const AsyncValue.loading()) {
    loadPlants();
  }

  Future<void> loadPlants() async {
    try {
      final plants = await _db.getAllPlants();
      state = AsyncValue.data(plants);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Acción Rápida: Regar Hoy ("💧 Regar hoy")
  Future<void> regarHoy(String plantId) async {
    await _db.registrarRiego(plantId);
    
    // Reprogramar notificación local
    final currentPlants = state.value ?? [];
    final plant = currentPlants.firstWhere((p) => p.id == plantId);
    final proximaFecha = DateTime.now().add(Duration(days: plant.frecuenciaRiegoDias));
    await _notifications.schedulePlantWatering(
      plantId: plantId,
      plantName: plant.nombre,
      scheduledDate: proximaFecha,
    );

    await loadPlants();
  }

  /// Acción Rápida: Abonar Hoy ("🌱 Abonar hoy")
  Future<void> abonarHoy(String plantId) async {
    await _db.registrarAbono(plantId);
    await loadPlants();
  }

  Future<void> addPlant(Plant newPlant) async {
    await _db.insertPlant(newPlant);
    
    // Programar notificación para la nueva planta
    final proximaFecha = newPlant.fechaUltimoRiego.add(Duration(days: newPlant.frecuenciaRiegoDias));
    await _notifications.schedulePlantWatering(
      plantId: newPlant.id,
      plantName: newPlant.nombre,
      scheduledDate: proximaFecha,
    );

    await loadPlants();
  }
}
