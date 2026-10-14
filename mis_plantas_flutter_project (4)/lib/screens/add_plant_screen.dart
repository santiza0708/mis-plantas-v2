import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';

class AddPlantScreen extends ConsumerStatefulWidget {
  const AddPlantScreen({super.key});

  @override
  ConsumerState<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();

  String? _imagePath;
  DateTime _lastWater = DateTime.now();
  DateTime _lastFertilize = DateTime.now().subtract(const Duration(days: 10));
  int _waterFreq = 5;
  String _location = 'Interior';

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
    }
  }

  void _selectChip(String species, int freq) {
    setState(() {
      _speciesController.text = species;
      _waterFreq = freq;
    });
  }

  void _savePlant() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el nombre de la planta')),
      );
      return;
    }

    final newPlant = Plant(
      id: 'planta-${DateTime.now().millisecondsSinceEpoch}',
      nombre: _nameController.text.trim(),
      especie: _speciesController.text.trim().isEmpty
          ? 'Especie botánica'
          : _speciesController.text.trim(),
      fechaUltimoRiego: _lastWater,
      fechaUltimoAbono: _lastFertilize,
      frecuenciaRiegoDias: _waterFreq,
      frecuenciaAbonoDias: 30,
      localImagePath: _imagePath ??
          'https://images.unsplash.com/photo-1545241047-6083a3684587?w=500&auto=format&fit=crop',
      ubicacion: _location,
    );

    ref.read(plantListProvider.notifier).addPlant(newPlant);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Registrar Cuidado'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Registrar Nueva Planta',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Añade tu compañera verde a tu santuario botánico.',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),

          // Contenedor de Foto con borde discontinuo
          InkWell(
            onTap: () => _pickImage(ImageSource.camera),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
              ),
              child: _imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: Icon(Icons.add_a_photo, color: AppColors.primary, size: 28),
                        ),
                        SizedBox(height: 12),
                        Text('Tomar o subir foto de la planta',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Toca para abrir la cámara o seleccionar de tu galería',
                            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Nombre de la planta
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre de la planta *',
              hintText: 'Ej. Mi Ficus consentido, Monstera de la sala',
              prefixIcon: const Icon(Icons.yard, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),

          // Especie
          TextField(
            controller: _speciesController,
            decoration: InputDecoration(
              labelText: 'Tipo / Especie botánica',
              hintText: 'Ej. Ficus Lyrata, Monstera Deliciosa, Suculenta',
              prefixIcon: const Icon(Icons.eco, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 10),

          // Chips de sugerencia rápida
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('SUGERENCIAS: ', style: TextStyle(fontSize: 11, color: AppColors.outline)),
                ActionChip(label: const Text('Monstera'), onPressed: () => _selectChip('Monstera Deliciosa', 6)),
                const SizedBox(width: 6),
                ActionChip(label: const Text('Ficus'), onPressed: () => _selectChip('Ficus Lyrata', 7)),
                const SizedBox(width: 6),
                ActionChip(label: const Text('Suculenta'), onPressed: () => _selectChip('Echeveria Elegans', 12)),
                const SizedBox(width: 6),
                ActionChip(label: const Text('Pothos'), onPressed: () => _selectChip('Epipremnum Aureum', 7)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Frecuencia de Riego
          DropdownButtonFormField<int>(
            value: _waterFreq,
            decoration: InputDecoration(
              labelText: 'Frecuencia de riego',
              prefixIcon: const Icon(Icons.water_drop, color: AppColors.tertiary),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            items: const [
              DropdownMenuItem(value: 3, child: Text('Cada 3 días')),
              DropdownMenuItem(value: 5, child: Text('Cada 5 días')),
              DropdownMenuItem(value: 7, child: Text('Cada 7 días')),
              DropdownMenuItem(value: 10, child: Text('Cada 10 días')),
              DropdownMenuItem(value: 14, child: Text('Cada 14 días')),
            ],
            onChanged: (val) => setState(() => _waterFreq = val!),
          ),
          const SizedBox(height: 24),

          // Botón Primario Guardar
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text('Guardar Planta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _savePlant,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: AppColors.onSurfaceVariant)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
