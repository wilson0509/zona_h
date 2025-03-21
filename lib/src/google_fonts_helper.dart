/// Clase que representa una variante de fuente de Google Fonts.
class GoogleFontsVariant {
  // Aquí definimos las propiedades y métodos relacionados con GoogleFontsVariant.
  // Por ejemplo, puede haber propiedades como peso, estilo, etc.

  // Propiedades de ejemplo:
  final int weight;
  final String style;

  /// Constructor para crear una instancia de una variante de fuente.
  GoogleFontsVariant({required this.weight, required this.style});

  // Métodos adicionales y lógica específica para GoogleFontsVariant.
}

/// Clase que representa una fuente personalizada dentro del contexto de Google Fonts.
class MyFont {
  /// Identificador único para la fuente.
  final int id;

  /// Nombre de la fuente.
  final String name;

  /// Constructor para crear una instancia de una fuente personalizada.
  MyFont({required this.id, required this.name});

  /// Sobrescritura del método hashCode para proporcionar un código hash único.
  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
    );
  }

  // Otros métodos y propiedades específicas para la clase MyFont.
}