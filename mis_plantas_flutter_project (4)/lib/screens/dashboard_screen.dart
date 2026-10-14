import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/plant_provider.dart';
import '../models/plant.dart';
import 'plant_detail_screen.dart';
import 'add_plant_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(plantListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Plantas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'PLANTAS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: const Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 20),
            ),
          ),
        ],
      ),
      body: plantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (plants) {
          final urgentCount = plants.where((p) => p.requiereAguaHoy).length;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              // Saludo Cálido y Resumen
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Hola, Carlos! 🌿',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tienes $urgentCount plantas que necesitan atención hoy',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Píldoras de Estadísticas Rápidas
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.yard, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('${plants.length} Plantas en total',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop, color: AppColors.tertiary, size: 18),
                          const SizedBox(width: 8),
                          Text('$urgentCount Pendiente de riego',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.tertiary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Lista de Colección de Plantas
              ...plants.map((plant) => _buildPlantCard(context, plant)).toList(),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        icon: const Icon(Icons.add, size: 24),
        label: const Text('Añadir planta', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlantScreen()),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface.withOpacity(0.9),
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.yard_outlined),
            selectedIcon: Icon(Icons.yard, color: AppColors.primary),
            label: 'Plantas',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome, color: AppColors.primary),
            label: 'Diagnóstico',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note, color: AppColors.primary),
            label: 'Historial',
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(BuildContext context, Plant plant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlantDetailScreen(plant: plant)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    plant.localImagePath,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 76,
                      height: 76,
                      color: AppColors.surfaceContainerHigh,
                      child: const Icon(Icons.eco, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(plant),
                          Text(plant.ubicacion,
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plant.nombre,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                      Text(
                        plant.especie,
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Medidores Duales (Agua / Abono)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: plant.requiereAguaHoy
                          ? AppColors.tertiaryContainer.withOpacity(0.15)
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.water_drop, size: 14, color: AppColors.tertiary),
                                SizedBox(width: 4),
                                Text('Humedad', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                              ],
                            ),
                            Text(plant.requiereAguaHoy ? 'Hoy' : '${(plant.porcentajeRiego * 100).toInt()}%',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.tertiary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: plant.porcentajeRiego,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation(AppColors.tertiary),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 6),
                        Text(plant.etiquetaRiego,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: plant.requiereAguaHoy ? AppColors.tertiary : AppColors.onSurfaceVariant,
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.psychiatry, size: 14, color: AppColors.secondary),
                                SizedBox(width: 4),
                                Text('Nutrientes', style: TextStyle(fontSize: 11, color: AppColors.secondary)),
                              ],
                            ),
                            Text('${(plant.porcentajeAbono * 100).toInt()}%',
                                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: plant.porcentajeAbono,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 6),
                        Text(plant.etiquetaAbono,
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (plant.requiereAguaHoy) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.tertiary.withOpacity(0.15),
                    foregroundColor: AppColors.tertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.done, size: 18),
                  label: const Text('Registrar riego completado', style: TextStyle(fontWeight: FontWeight.w600)),
                  onPressed: () {
                    ref.read(plantListProvider.notifier).regarHoy(plant.id);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Plant plant) {
    if (plant.requiereAguaHoy) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.errorContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Text('• REQUIERE AGUA',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
      );
    } else if (plant.diasRestantesRiego == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Text('ATENCIÓN PRONTO',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text('SALUDABLE',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }
}
