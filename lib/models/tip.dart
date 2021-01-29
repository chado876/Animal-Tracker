import 'package:animal_tracker/models/place.dart';

class Tip {
  String id;
  String tipMessage;
  DateTime dateSent;
  String tagId;
  PlaceLocation location;

  Tip({this.id, this.tipMessage, this.dateSent, this.tagId, this.location});
}
