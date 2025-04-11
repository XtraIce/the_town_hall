class Representative {
  final int id;
  final String name;
  final String position;
  final PositionLevel positionLevel;
  final String district;
  final String state;
  final String city;
  final String? community;
  final String party;
  final String imageUrl;
  final ContactInfo contactInfo;

  Representative({
    required this.id,
    required this.name,
    required this.position,
    required this.positionLevel,
    required this.district,
    required this.state,
    required this.city,
             this.community,
    required this.party,
    required this.imageUrl,
    required this.contactInfo,
  });

  factory Representative.fromJson(Map<String, dynamic> json) {
    return Representative(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      positionLevel: PositionLevelExtension.fromString(json['positionLevel']),
      district: json['district'],
      state: json['state'],
      city: json['city'],
      community: json['community'],
      party: json['party'],
      imageUrl: json['imageUrl'],
      contactInfo: ContactInfo.fromJson(json['contactInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'positionLevel': positionLevel.toShortString(),
      'district': district,
      'state': state,
      'city': city,
      'community': community,
      'party': party,
      'imageUrl': imageUrl,
      'contactInfo': contactInfo.toJson(),
    };
  }
}

class ContactInfo {
  final String email;
  final String phone;
  final String website;
  // The office address is required, but the second line is optional
  final String officeAddress;
  final String? officeAddress2;
  String locationAddress; // This is the address used for geocoding

  ContactInfo({
    required this.email,
    required this.phone,
    required this.website,
    required this.officeAddress,
    this.officeAddress2,
    required this.locationAddress,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      officeAddress: json['officeAddress'],
      officeAddress2: json['officeAddress2'],
      locationAddress: json['locationAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'website': website,
      'officeAddress': officeAddress,
      'officeAddress2': officeAddress2,
      'locationAddress': locationAddress,
    };
  }
}

enum PositionLevel {
  local,
  city,
  county,
  state,
  national
}

extension PositionLevelExtension on PositionLevel {
  String toShortString() {
    return toString().split('.').last;
  }

  static PositionLevel fromString(String value) {
    switch (value) {
      case 'local':
        return PositionLevel.local;
      case 'city':
        return PositionLevel.city;
      case 'county':
        return PositionLevel.county;
      case 'state':
        return PositionLevel.state;
      case 'national':
        return PositionLevel.national;
      default:
        throw Exception('Unknown position level: $value');
    }
  }
}
