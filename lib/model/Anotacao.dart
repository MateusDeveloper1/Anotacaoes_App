class Anotacao {
  int? id;
  late String titulo;
  late String descricao;
  late String data;

  Anotacao({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
  });

  Anotacao.fromMap(Map map){
    id = map["id"] ?? "";
    titulo = map["titulo"] ?? "";
    descricao = map["descricao"] ?? "";
    data = map["data"] ?? "";
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "titulo": titulo,
      "descricao": descricao,
      "data": data
    };

    if (id != null) {
      map["id"] = id;
    }
    return map;
  }
}
