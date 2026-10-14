class Plant {
  final String id;
  final String nombre;
  final String especie;
  final DateTime fechaUltimoRiego;
  final DateTime fechaUltimoAbono;
  final int frecuenciaRiegoDias;
  final int frecuenciaAbonoDias;
  final String localImagePath;
  final String ubicacion;
  final String estadoSalud; // 'urgente' | 'atencion' | 'saludable'
  final String exposicionSolar;
  final String humedadOptima;
  final bool recordatorioActivo;

  const Plant({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.fechaUltimoRiego,
    required this.fechaUltimoAbono,
    required this.frecuenciaRiegoDias,
    required this.frecuenciaAbonoDias,
    required this.localImagePath,
    this.ubicacion = 'Interior',
    this.estadoSalud = 'saludable',
    this.exposicionSolar = 'Luz indirecta brillante',
    this.humedadOptima = 'Media (50%)',
    this.recordatorioActivo = true,
  });

  /// Días transcurridos desde el último riego
  int get diasPasadosRiego {
    final now = DateTime.now();
    final difference = now.difference(fechaUltimoRiego);
    return difference.inDays.clamp(0, 999);
  }

  /// Días restantes antes del próximo riego
  int get diasRestantesRiego {
    return frecuenciaRiegoDias - diasPasadosRiego;
  }

  /// Determina si la planta necesita riego hoy o está retrasada
  bool get requiereAguaHoy => diasRestantesRiego <= 0;

  /// Texto amigable para el dashboard ("Riego hoy 💧", "Riego en 2 días")
  String get etiquetaRiego {
    if (diasRestantesRiego <= 0) return 'Riego hoy 💧';
    if (diasRestantesRiego == 1) return 'Riego en 1 día';
    return 'Riego en $diasRestantesRiego días';
  }

  /// Porcentaje de humedad restante para la barra de progreso (0.0 a 1.0)
  double get porcentajeRiego {
    if (diasRestantesRiego <= 0) return 1.0; // Estado alerta lleno en diseño
    final pct = (diasRestantesRiego / frecuenciaRiegoDias).clamp(0.1, 1.0);
    return pct;
  }

  /// Días transcurridos desde el último abono
  int get diasPasadosAbono {
    final now = DateTime.now();
    return now.difference(fechaUltimoAbono).inDays.clamp(0, 999);
  }

  /// Días restantes antes de abonar
  int get diasRestantesAbono {
    return frecuenciaAbonoDias - diasPasadosAbono;
  }

  String get etiquetaAbono {
    if (diasRestantesAbono <= 0) return 'Abonar hoy 🌱';
    return 'Abono en $diasRestantesAbono días';
  }

  double get porcentajeAbono {
    if (diasRestantesAbono <= 0) return 1.0;
    return (diasRestantesAbono / frecuenciaAbonoDias).clamp(0.1, 1.0);
  }

  /// Conversión hacia Map para almacenamiento en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'especie': especie,
      'fechaUltimoRiego': fechaUltimoRiego.toIso8601String(),
      'fechaUltimoAbono': fechaUltimoAbono.toIso8601String(),
      'frecuenciaRiegoDias': frecuenciaRiegoDias,
      'frecuenciaAbonoDias': frecuenciaAbonoDias,
      'localImagePath': localImagePath,
      'ubicacion': ubicacion,
      'estadoSalud': estadoSalud,
      'exposicionSolar': exposicionSolar,
      'humedadOptima': humedadOptima,
      'recordatorioActivo': recordatorioActivo ? 1 : 0,
    };
  }

  /// Reconstrucción desde registro SQLite
  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      especie: map['especie'] as String,
      fechaUltimoRiego: DateTime.parse(map['fechaUltimoRiego'] as String),
      fechaUltimoAbono: DateTime.parse(map['fechaUltimoAbono'] as String),
      frecuenciaRiegoDias: map['frecuenciaRiegoDias'] as int,
      frecuenciaAbonoDias: map['frecuenciaAbonoDias'] as int,
      localImagePath: map['localImagePath'] as String,
      ubicacion: (map['ubicacion'] as String?) ?? 'Interior',
      estadoSalud: (map['estadoSalud'] as String?) ?? 'saludable',
      exposicionSolar: (map['exposicionSolar'] as String?) ?? 'Luz indirecta',
      humedadOptima: (map['humedadOptima'] as String?) ?? 'Media (50%)',
      recordatorioActivo: (map['recordatorioActivo'] as int?) == 1,
    );
  }

  Plant copyWith({
    String? id,
    String? nombre,
    String? especie,
    DateTime? fechaUltimoRiego,
    DateTime? fechaUltimoAbono,
    int? frecuenciaRiegoDias,
    int? frecuenciaAbonoDias,
    String? localImagePath,
    String? ubicacion,
    String? estadoSalud,
    String? exposicionSolar,
    String? humedadOptima,
    bool? recordatorioActivo,
  }) {
    return Plant(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      especie: especie ?? this.especie,
      fechaUltimoRiego: fechaUltimoRiego ?? this.fechaUltimoRiego,
      fechaUltimoAbono: fechaUltimoAbono ?? this.fechaUltimoAbono,
      frecuenciaRiegoDias: frecuenciaRiegoDias ?? this.frecuenciaRiegoDias,
      frecuenciaAbonoDias: frecuenciaAbonoDias ?? this.frecuenciaAbonoDias,
      localImagePath: localImagePath ?? this.localImagePath,
      ubicacion: ubicacion ?? this.ubicacion,
      estadoSalud: estadoSalud ?? this.estadoSalud,
      exposicionSolar: exposicionSolar ?? this.exposicionSolar,
      humedadOptima: humedadOptima ?? this.humedadOptima,
      recordatorioActivo: recordatorioActivo ?? this.recordatorioActivo,
    );
  }
}
