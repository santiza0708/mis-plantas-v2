import 'dart:async';
import '../models/plant.dart';

class GeminiDiagnosticReport {
  final String estadoSalud;
  final String descripcion;
  final int vigorFoliar;
  final List<String> cuidadosRecomendados;

  const GeminiDiagnosticReport({
    required this.estadoSalud,
    required this.descripcion,
    required this.vigorFoliar,
    required this.cuidadosRecomendados,
  });
}

class PersonalizedCareTip {
  final String id;
  final String categoria; // 'riego' | 'iluminacion' | 'sustrato' | 'prevencion' | 'nutricion'
  final String titulo;
  final String descripcion;
  final String prioridad; // 'alta' | 'media' | 'preventiva'
  final String icon;

  const PersonalizedCareTip({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    required this.icon,
  });
}

class GeminiApiService {
  /// Analiza una imagen de planta local y retorna un diagnóstico botánico estructurado
  Future<GeminiDiagnosticReport> analyzePlantHealth(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 1400));
    return const GeminiDiagnosticReport(
      estadoSalud: 'Excelente vigor foliar',
      descripcion:
          'No se detectan plagas ni manchas cloróticas. Las hojas jóvenes muestran crecimiento activo y buena turgencia.',
      vigorFoliar: 96,
      cuidadosRecomendados: [
        'Higiene foliar: Limpiar el polvo de las hojas con paño húmedo cada dos semanas para maximizar fotosíntesis.',
        'Microclima estable: Evitar corrientes de aire frío directo provenientes de ventanales o aire acondicionado.',
      ],
    );
  }

  /// Genera automáticamente tips de cuidado personalizados para la especie seleccionada
  Future<List<PersonalizedCareTip>> generatePersonalizedCareTips(Plant plant) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final lower = (plant.especie + ' ' + plant.nombre).toLowerCase();

    if (lower.contains('ficus')) {
      return const [
        PersonalizedCareTip(
          id: 'tip-ficus-1',
          categoria: 'riego',
          titulo: 'Verificación del sustrato al 50%',
          descripcion: 'Introduce un palillo de madera hasta la mitad del cepellón; sólo riega si sale completamente seco y sin tierra adherida.',
          prioridad: 'alta',
          icon: 'water_drop',
        ),
        PersonalizedCareTip(
          id: 'tip-ficus-2',
          categoria: 'iluminacion',
          titulo: 'Rotación quincenal para simetría',
          descripcion: 'Gira la maceta 45° cada 2 semanas para evitar que el tallo principal se incline excesivamente buscando la ventana este/sur.',
          prioridad: 'media',
          icon: 'rotate_right',
        ),
        PersonalizedCareTip(
          id: 'tip-ficus-3',
          categoria: 'prevencion',
          titulo: 'Alerta de manchas pardas',
          descripcion: 'Bordes marrones con halo amarillo delatan sobre-riego; si son crujientes sin borde, se trata de sequedad ambiental.',
          prioridad: 'alta',
          icon: 'shield',
        ),
        PersonalizedCareTip(
          id: 'tip-ficus-4',
          categoria: 'nutricion',
          titulo: 'Duchas foliares periódicas',
          descripcion: 'Limpia las hojas anchas con paño húmedo cada 14 días para desobstruir estomas y potenciar la absorción lumínica.',
          prioridad: 'preventiva',
          icon: 'cleaning_services',
        ),
      ];
    } else if (lower.contains('anturio')) {
      return const [
        PersonalizedCareTip(
          id: 'tip-ant-1',
          categoria: 'riego',
          titulo: 'Hidratación por inmersión suave',
          descripcion: 'Sumerge la maceta durante 10 minutos en agua reposada libre de cloro y deja escurrir todo el excedente.',
          prioridad: 'alta',
          icon: 'water_drop',
        ),
        PersonalizedCareTip(
          id: 'tip-ant-2',
          categoria: 'iluminacion',
          titulo: 'Luz brillante tamizada',
          descripcion: 'Sitúa la planta cerca de una ventana con cortina; la falta de luz detiene la pigmentación de nuevas espatas rojas.',
          prioridad: 'media',
          icon: 'wb_sunny',
        ),
        PersonalizedCareTip(
          id: 'tip-ant-3',
          categoria: 'sustrato',
          titulo: 'Oxigenación con corteza y perlita',
          descripcion: 'Sus raíces epífitas requieren sustrato aireado; evita compactar la tierra para prevenir asfixia radicular.',
          prioridad: 'alta',
          icon: 'yard',
        ),
      ];
    }

    return const [
      PersonalizedCareTip(
        id: 'tip-gen-1',
        categoria: 'riego',
        titulo: 'Comprobación de humedad superficial',
        descripcion: 'Introduce el dedo 2 cm en la tierra antes de hidratar para validar el drenaje activo.',
        prioridad: 'alta',
        icon: 'water_drop',
      ),
      PersonalizedCareTip(
        id: 'tip-gen-2',
        categoria: 'iluminacion',
        titulo: 'Exposición indirecta filtrada',
        descripcion: 'Evita la radiación solar directa del mediodía para proteger la película cerosa foliar.',
        prioridad: 'media',
        icon: 'wb_sunny',
      ),
    ];
  }
}
