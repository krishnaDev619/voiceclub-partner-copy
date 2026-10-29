class KrutrimMapsReverseGeocodingResponseModel {
  final List<Result>? results;

  KrutrimMapsReverseGeocodingResponseModel({this.results});

  KrutrimMapsReverseGeocodingResponseModel.fromJson(Map<String, dynamic> json)
    : results =
          (json['results'] as List?)
              ?.map((dynamic e) => Result.fromJson(e as Map<String, dynamic>))
              .toList();

  Map<String, dynamic> toJson() => {
    'results': results?.map((e) => e.toJson()).toList(),
  };

  String? get city {
    if (results == null || results!.isEmpty) return null;

    final addressComponents = results!.first.addressComponents;
    if (addressComponents == null) return null;

    final cityComponent = addressComponents.firstWhere(
      (component) => component.types?.contains('locality') ?? false,
      orElse: () => AddressComponents(),
    );

    return cityComponent.longName?.trim();
  }

  String? get state {
    if (results == null || results!.isEmpty) return null;

    final addressComponents = results!.first.addressComponents;
    if (addressComponents == null) return null;

    final stateComponent = addressComponents.firstWhere(
      (component) =>
          component.types?.contains('administrative_area_level_1') ?? false,
      orElse: () => AddressComponents(),
    );

    return stateComponent.longName?.trim();
  }
}

class Result {
  final List<AddressComponents>? addressComponents;

  Result({this.addressComponents});

  Result.fromJson(Map<String, dynamic> json)
    : addressComponents =
          (json['address_components'] as List?)
              ?.map(
                (dynamic e) =>
                    AddressComponents.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'address_components': addressComponents?.map((e) => e.toJson()).toList(),
  };
}

class AddressComponents {
  final List<String>? types;
  final String? shortName;
  final String? longName;

  AddressComponents({this.types, this.shortName, this.longName});

  AddressComponents.fromJson(Map<String, dynamic> json)
    : types =
          (json['types'] as List?)?.map((dynamic e) => e as String).toList(),
      shortName = json['short_name'] as String?,
      longName = json['long_name'] as String?;

  Map<String, dynamic> toJson() => {
    'types': types,
    'short_name': shortName,
    'long_name': longName,
  };
}
