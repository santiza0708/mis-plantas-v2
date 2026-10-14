import 'dart:async';

class BotanicalCareProfile {
  final String especie;
  final int frecuenciaRiegoDias;
  final int frecuenciaAbonoDias;
  final String exposicionSolar;
  final String humedadOptima;

  const BotanicalCareProfile({
    required this.especie,
    required this.frecuenciaRiegoDias,
    required this.frecuenciaAbonoDias,
    required this.exposicionSolar,
    required this.humedadOptima,
  });
}

class BotanicalApiService {
  Future<BotanicalCareProfile> getCareProfile(String speciesQuery) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final normalized = speciesQuery.toLowerCase();

    if (normalized.contains('ficus')) {
      return const BotanicalCareProfile(
        especie: 'Ficus Lyrata',
        frecuenciaRiegoDias: 7,
        frecuenciaAbonoDias: 30,
        exposicionSolar: 'Luz indirecta brillante',
        humedadOptima: 'Media-alta (60%)',
      );
    } else if (normalized.contains('suculenta')) {
      return const BotanicalCareProfile(
        especie: 'Echeveria Elegans',
        frecuenciaRiegoDias: 12,
        frecuenciaAbonoDias: 45,
        exposicionSolar: 'Sol directo moderado',
        humedadOptima: 'Baja (35%)',
      );
    } else if (normalized.contains('monstera')) {
      return const BotanicalCareProfile(
        especie: 'Monstera Deliciosa',
        frecuenciaRiegoDias: 6,
        frecuenciaAbonoDias: 25,
        exposicionSolar: 'Luz indirecta brillante',
        humedadOptima: 'Media-alta (65%)',
      );
    }

    return const BotanicalCareProfile(
      especie: 'Planta doméstica',
      frecuenciaRiegoDias: 5,
      frecuenciaAbonoDias: 30,
      exposicionSolar: 'Luz indirecta',
      humedadOptima: 'Media (50%)',
    );
  }
}
