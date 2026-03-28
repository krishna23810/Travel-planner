class PlaceModel {
  String? xid;
  String? name;
  String? kind;
  String? osm;
  String? wikidata;
  double? dist;
  double? lat;
  double? lon;
  String? image;
  String? description;
  String? wikipedia;
  String? wikipediaExtract;

  PlaceModel({
    this.xid,
    this.name,
    this.kind,
    this.osm,
    this.wikidata,
    this.dist,
    this.lat,
    this.lon,
    this.image,
    this.description,
    this.wikipedia,
    this.wikipediaExtract,
  });

  PlaceModel.fromJson(Map<String, dynamic> json) {
    xid = json['xid'];
    name = json['name'];
    kind = json['kinds']; // Some endpoints use 'kinds', others 'kind'
    if (kind == null && json['kind'] != null) {
      kind = json['kind'];
    }
    osm = json['osm'];
    wikidata = json['wikidata'];
    dist = json['dist']?.toDouble();
    lat = json['point']?['lat']?.toDouble();
    lon = json['point']?['lon']?.toDouble();

    // Handle multiple image locations
    image = json['preview']?['source'];

    // Handle descriptions from multiple sources
    description = json['info']?['descr'] ?? json['wikipedia_extracts']?['text'];
    wikipedia = json['wikipedia'];
    wikipediaExtract = json['wikipedia_extracts']?['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['xid'] = xid;
    data['name'] = name;
    data['kinds'] = kind;
    data['osm'] = osm;
    data['wikidata'] = wikidata;
    data['dist'] = dist;
    data['point'] = {'lat': lat, 'lon': lon};
    data['preview'] = {'source': image};
    data['info'] = {'descr': description};
    data['wikipedia'] = wikipedia;
    data['wikipedia_extracts'] = {'text': wikipediaExtract};
    return data;
  }
}
