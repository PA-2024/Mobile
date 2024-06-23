class Building {
  final int id;
  final String name;
  final String city;
  final String address;

  Building({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['building_Id'],
      name: json['building_Name'],
      city: json['building_City'],
      address: json['building_Address'],
    );
  }
}