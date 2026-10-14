import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import '../services/gemini_api_service.dart';

class DiagnosisScreen extends ConsumerStatefulWidget {
  final List<Plant> plants;
  const DiagnosisScreen({super.key, required this.plants});

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen> {
  late Plant _selectedPlant;
  bool _isAnalyzingHealth = false;
  GeminiDiagnosticReport? _healthReport;
  String _selectedCategory = 'todos';

  @override
  void initState() {
    super.initState();
    _selectedPlant = widget.plants.isNotEmpty ? widget.plants.first : _dummyPlant();
  }

  Plant _dummyPlant() {
    return Plant(
      id: 'default',
      nombre: 'Ficus Lyrata',
      especie: 'Ficus Lyrata',
      fechaUltimoRiego: DateTime.now().subtract(const Duration(days: 3)),
      fechaUltimoAbono: DateTime.now().subtract(const Duration(days: 15)),
      frecuenciaRiegoDias: 7,
      frecuenciaAbonoDias: 30,
      localImagePath: '',
    );
  }

  Future<void> _scanHealth() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() => _isAnalyzingHealth = true);
    final gemini = ref.read(geminiApiServiceProvider);
    final report = await gemini.analyzePlantHealth(photo.path);

    if (!mounted) return;
    setState(() {
      _healthReport = report;
      _isAnalyzingHealth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Al abrir la pantalla o cambiar _selectedPlant, Riverpod genera automáticamente los tips con Gemini
    final tipsAsync = ref.watch(personalizedCareTipsProvider(_selectedPlant));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.85),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laboratorio de Diagnóstico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('IA MULTIMODAL GEMINI', style: TextStyle(fontSize: 10, color: AppColors.primary, letterSpacing: 1.1)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Selector horizontal de plantas
          const Text('SELECCIONAR PLANTA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.plants.map((plant) {
                final isSelected = plant.id == _selectedPlant.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPlant = plant),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceContainer : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            plant.localImagePath,
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 20, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plant.nombre, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(plant.especie, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // SECCIÓN: TIPS DE CUIDADO PERSONALIZADOS GENERADOS AUTOMÁTICAMENTE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.psychiatry, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tips Personalizados IA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Generados en tiempo real', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                      onPressed: () => ref.refresh(personalizedCareTipsProvider(_selectedPlant)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Manejo de estado asíncrono con Riverpod
                tipsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 10),
                          Text('Generando tips con Gemini IA...', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  error: (e, _) => Text('Error al generar tips: $e', style: const TextStyle(color: AppColors.error)),
                  data: (tips) {
                    return Column(
                      children: tips.map((tip) => _buildTipCard(tip)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SECCIÓN: ESCANEO DE SALUD DE FOLLAJE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                    ),
                    icon: _isAnalyzingHealth
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
                        : const Icon(Icons.document_scanner),
                    label: Text(_isAnalyzingHealth ? 'Analizando con visión...' : 'Escanear Salud Foliar'),
                    onPressed: _isAnalyzingHealth ? null : _scanHealth,
                  ),
                ),
                if (_healthReport != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_healthReport!.estadoSalud, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text(_healthReport!.descripcion, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTipCard(PersonalizedCareTip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tip.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tip.prioridad == 'alta' ? AppColors.errorContainer.withOpacity(0.3) : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(tip.prioridad.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tip.prioridad == 'alta' ? AppColors.error : AppColors.onSurfaceVariant)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(tip.descripcion, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
