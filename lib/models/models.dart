class Vehicle {
  final String id;
  final String model;
  final String number;
  final int mileage;
  final String? image;

  Vehicle({
    required this.id,
    required this.model,
    required this.number,
    required this.mileage,
    this.image,
  });
}

enum ServiceStatus { pending, inProgress, completed }

class ServiceRecord {
  final String id;
  final String vehicleId;
  final String vehicleModel;
  final String serviceType;
  final DateTime date;
  final ServiceStatus status;
  final double? cost;

  ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.vehicleModel,
    required this.serviceType,
    required this.date,
    required this.status,
    this.cost,
  });
}

class SparePart {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  SparePart({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}

class Station {
  final String id;
  final String name;
  final String location;
  final String phone;

  Station({
    required this.id,
    required this.name,
    required this.location,
    required this.phone,
  });
}

class MarketplaceItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String year;

  MarketplaceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.year,
  });
}
