import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';

class PlantDetailScreen extends ConsumerStatefulWidget {
  final Plant plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  bool _isAnalyzing = false;
  String? _analysisStatus;

  Future<void> _analizarConCamara() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisStatus = 'Escaneando follaje con Gemini...';
    });

    final geminiService = ref.read(geminiApiServiceProvider);
    final report = await geminiService.analyzePlantHealth(photo.path);

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _analysisStatus = null;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: Row(
          children: [
            const Icon(Icons.verified, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(report.estadoSalud, style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(report.descripcion, style: const TextStyle(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
            child: const Text('Aceptar', style: TextStyle(color: AppColors.primary)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(plantListProvider);
    final currentPlant = plantsAsync.value?.firstWhere(
          (p) => p.id == widget.plant.id,
          orElse: () => widget.plant,
        ) ??
        widget.plant;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite, color: AppColors.primary),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    currentPlant.localImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainerHigh),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.surface.withOpacity(0.6),
                          AppColors.surface,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                currentPlant.ubicacion,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text(
                                'SALUDABLE',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentPlant.nombre,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        Text(
                          currentPlant.especie,
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Botones Táctiles de Acción Rápida: Regar hoy & Abonar hoy
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            ref.read(plantListProvider.notifier).regarHoy(currentPlant.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('¡Riego registrado con éxito! 💧')),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.water_drop, color: AppColors.tertiary, size: 22),
                                ),
                                const SizedBox(height: 12),
                                const Text('Regar hoy',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                const Text('Toca para registrar',
                                    style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            ref.read(plantListProvider.notifier).abonarHoy(currentPlant.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('¡Nutrición mensual registrada! 🌱')),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.eco, color: AppColors.secondary, size: 22),
                                ),
                                const SizedBox(height: 12),
                                const Text('Abonar hoy',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                const Text('Nutrición mensual',
                                    style: TextStyle(fontSize: 11, color: AppColors.secondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Historial y Condiciones
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('HISTORIAL Y CONDICIONES',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                            Row(
                              children: [
                                Icon(Icons.sync, size: 14, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text('Al día', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildHistoryRow(
                          icon: Icons.water_drop,
                          iconColor: AppColors.tertiary,
                          title: 'Última fecha de riego',
                          subtitle: 'Hace ${currentPlant.diasPasadosRiego} días',
                          note: 'Próximo riego recomendado: en ${currentPlant.diasRestantesRiego} días',
                        ),
                        const SizedBox(height: 10),
                        _buildHistoryRow(
                          icon: Icons.compost,
                          iconColor: AppColors.secondary,
                          title: 'Última fecha de abono',
                          subtitle: 'Hace ${currentPlant.diasPasadosAbono} días',
                          note: 'Frecuencia: biofertilizante cada ${currentPlant.frecuenciaAbonoDias} días',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recomendaciones de la IA
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text('Recomendaciones de la IA',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text('Diagnóstico IA',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onPrimaryContainer)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.health_and_safety, color: AppColors.primary, size: 18),
                                  SizedBox(width: 6),
                                  Text('Estado de salud', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Excelente vigor foliar. No se detectan plagas ni manchas cloróticas. Las hojas jóvenes muestran crecimiento activo y buena turgencia.',
                                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                            ),
                            icon: _isAnalyzing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                                  )
                                : const Icon(Icons.document_scanner),
                            label: Text(
                              _isAnalyzing ? _analysisStatus! : 'Analizar con cámara',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            onPressed: _isAnalyzing ? null : _analizarConCamara,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recordatorios inteligentes
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_active, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recordatorios inteligentes', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Notificaciones sincronizadas con sensor de suelo',
                                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Switch(
                          value: currentPlant.recordatorioActivo,
                          activeColor: AppColors.primaryContainer,
                          onChanged: (val) {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String note,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(note, style: TextStyle(fontSize: 12, color: iconColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
