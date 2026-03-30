/// Request para eliminar una tarjeta tokenizada de la bóveda de Tilopay.
class RemoveCardRequest {
  const RemoveCardRequest({
    required this.key,
    required this.email,
    required this.token,
  });

  /// API Key del comercio.
  final String key;

  /// Correo electrónico del cliente asociado al token.
  final String email;

  /// Token de la tarjeta que se desea eliminar.
  final String token;

  Map<String, dynamic> toJson() => {'key': key, 'email': email, 'token': token};
}
