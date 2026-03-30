/// Request para el endpoint de tokenización de Tilopay.
///
/// Este flujo genera un link para que el usuario ingrese sus datos de tarjeta
/// en una página de Tilopay y reciba un token de retorno.
class ProcessTokenizeRequest {
  const ProcessTokenizeRequest({
    required this.key,
    required this.redirect,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.language = 'es',
    this.tokenVersion = 'v2',
  });

  /// API Key del comercio.
  final String key;

  /// URL donde se espera la respuesta después de la tokenización.
  final String redirect;

  /// Correo electrónico del tarjetahabiente.
  final String email;

  /// Nombre del tarjetahabiente.
  final String firstName;

  /// Apellido del tarjetahabiente.
  final String lastName;

  /// Idioma (es, en). Por defecto 'es'.
  final String language;

  /// Versión del token. Siempre 'v2'.
  final String tokenVersion;

  Map<String, dynamic> toJson() => {
        'redirect': redirect,
        'key': key,
        'email': email,
        'language': language,
        'firstName': firstName,
        'lastName': lastName,
        'token_version': tokenVersion,
      };
}
