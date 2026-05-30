class ResponseDataMap {
  bool status;
  String message;
  Map? data;
  ResponseDataMap({required this.status, required this.message, this.data});
}

class ResponseDataList {
  bool status;
  String message;
  List? data;
  ResponseDataList({required this.status, required this.message, this.data});
}