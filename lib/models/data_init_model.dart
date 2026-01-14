class DataInit {
  final List<VideoGuide> videoGuide;
  final List<MobileService> mobileService;
  final List<Resource> resource;
  final List<BookAppointment> bookAppointment;

  DataInit({
    required this.videoGuide,
    required this.mobileService,
    required this.resource,
    required this.bookAppointment,
  });

  factory DataInit.fromJson(Map<String, dynamic> json) {
    return DataInit(
      videoGuide: (json['video_guide'] as List<dynamic>?)
              ?.map((item) => VideoGuide.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      mobileService: (json['mobile_service'] as List<dynamic>?)
              ?.map((item) => MobileService.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      resource: (json['resource'] as List<dynamic>?)
              ?.map((item) => Resource.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      bookAppointment: (json['book_appointment'] as List<dynamic>?)
              ?.map((item) => BookAppointment.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_guide': videoGuide.map((item) => item.toJson()).toList(),
      'mobile_service': mobileService.map((item) => item.toJson()).toList(),
      'resource': resource.map((item) => item.toJson()).toList(),
      'book_appointment': bookAppointment.map((item) => item.toJson()).toList(),
    };
  }
}

class VideoGuide {
  final String title;
  final dynamic featuredImage; // Can be String or false
  final String video;
  final int order;

  VideoGuide({
    required this.title,
    required this.featuredImage,
    required this.video,
    required this.order,
  });

  factory VideoGuide.fromJson(Map<String, dynamic> json) {
    return VideoGuide(
      title: json['title'] as String? ?? '',
      featuredImage: json['featured_image'],
      video: json['video'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'featured_image': featuredImage,
      'video': video,
      'order': order,
    };
  }
}

class MobileService {
  final String title;
  final dynamic featuredImage; // Can be String or false
  final int order;
  final String link;
  final String shortDescription;

  MobileService({
    required this.title,
    required this.featuredImage,
    required this.order,
    required this.link,
    required this.shortDescription,
  });

  factory MobileService.fromJson(Map<String, dynamic> json) {
    return MobileService(
      title: json['title'] as String? ?? '',
      featuredImage: json['featured_image'],
      order: json['order'] as int? ?? 0,
      link: json['link'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'featured_image': featuredImage,
      'order': order,
      'link': link,
    };
  }
}

class Resource {
  final String title;
  final dynamic featuredImage; // Can be String or false
  final int order;
  final String link;
  final String shortDescription;

  Resource({
    required this.title,
    required this.featuredImage,
    required this.order,
    required this.link,
    required this.shortDescription,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      title: json['title'] as String? ?? '',
      featuredImage: json['featured_image'],
      order: json['order'] as int? ?? 0,
      link: json['link'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'featured_image': featuredImage,
      'order': order,
      'link': link,
      'short_description': shortDescription,
    };
  }
}

class BookAppointment {
  final String typeOfInsurance;
  final String appointmentType;
  final String agent;
  final String location;
  final String timeNeeded;
  final String appointmentLink;

  BookAppointment({
    required this.typeOfInsurance,
    required this.appointmentType,
    required this.agent,
    required this.location,
    required this.timeNeeded,
    required this.appointmentLink,
  });

  factory BookAppointment.fromJson(Map<String, dynamic> json) {
    return BookAppointment(
      typeOfInsurance: json['type_of_insurance'] as String? ?? '',
      appointmentType: json['appointment_type'] as String? ?? '',
      agent: json['agent'] as String? ?? '',
      location: json['location'] as String? ?? '',
      timeNeeded: json['time_needed'] as String? ?? '',
      appointmentLink: json['appointment_link'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_of_insurance': typeOfInsurance,
      'appointment_type': appointmentType,
      'agent': agent,
      'location': location,
      'time_needed': timeNeeded,
      'appointment_link': appointmentLink,
    };
  }
}










