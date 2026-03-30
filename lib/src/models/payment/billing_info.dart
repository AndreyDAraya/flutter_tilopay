/// Información de facturación del cliente.
/// Compartida por múltiples requests de pago.
class BillingInfo {
  const BillingInfo({
    this.firstName,
    this.lastName,
    this.address,
    this.address2,
    this.city,
    this.state,
    this.zipPostCode,
    this.country,
    this.telephone,
    this.email,
  });

  final String? firstName;
  final String? lastName;
  final String? address;
  final String? address2;
  final String? city;
  final String? state;
  final String? zipPostCode;

  /// Código ISO de 2 letras (ej. `CR`, `PA`).
  final String? country;
  final String? telephone;
  final String? email;

  Map<String, dynamic> toJson() => {
        if (firstName != null) 'billToFirstName': firstName,
        if (lastName != null) 'billToLastName': lastName,
        if (address != null) 'billToAddress': address,
        if (address2 != null) 'billToAddress2': address2,
        if (city != null) 'billToCity': city,
        if (state != null) 'billToState': state,
        if (zipPostCode != null) 'billToZipPostCode': zipPostCode,
        if (country != null) 'billToCountry': country,
        if (telephone != null) 'billToTelephone': telephone,
        if (email != null) 'billToEmail': email,
      };
}
