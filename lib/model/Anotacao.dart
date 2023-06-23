class Anotacao {
  int? id;
  late String title;
  late String description;
  late String date;

  Anotacao({
    this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  Anotacao.fromMap(Map map){
    id = map["id"] ?? "";
    title = map["titulo"] ?? "";
    description = map["descricao"] ?? "";
    date = map["data"] ?? "";
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "titulo": title,
      "descricao": description,
      "data": date,
    };

    if (id != null) {
      map["id"] = id;
    }
    return map;
  }
}
