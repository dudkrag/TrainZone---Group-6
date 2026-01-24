class Player {
  final String id;
  String name;
  String position;
  String coachId;
  int age;

  DataPermissions permissions;

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.coachId,
    required this.age,
    
    required this.permissions,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'coachId': coachId,
    'age': age,
    
    'permissions': permissions.toJson(),
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      coachId: json['coachId'],
      age: json['age'],
      
      permissions: DataPermissions.fromJson(json['permissions']),
    );
  }
}


class DataPermissions {
  bool heartRate;
  bool trainingZones;
  bool trainingHistory;

  DataPermissions({
    this.heartRate = false,
    this.trainingZones = false,
    this.trainingHistory = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'heartRate': heartRate,
      'trainingZones': trainingZones,
      'trainingHistory': trainingHistory,
    };
  }

  factory DataPermissions.fromJson(Map<String, dynamic> json) {
    return DataPermissions(
      heartRate: json['heartRate'] ?? false,
      trainingZones: json['trainingZones'] ?? false,
      trainingHistory: json['trainingHistory'] ?? false,
    );
  }
}



class Coach {
  final String id;
  String name;

  Coach({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id'],
      name: json['name'],
    );
  }
}




