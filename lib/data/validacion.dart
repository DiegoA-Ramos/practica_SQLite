String? validarTitulo(String? titulo) {
  if (titulo == null || titulo.trim().isEmpty) {
    return 'El título no puede estar vacío';
  }
  if (titulo.trim().length > 120) return 'Máximo 120 caracteres';
  return null;
}