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
}

class ContactInfo {
  final String email;
  final String phone;
  final String website;
  final String officeAddress;

  ContactInfo({
    required this.email,
    required this.phone,
    required this.website,
    required this.officeAddress,
  });

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
}
