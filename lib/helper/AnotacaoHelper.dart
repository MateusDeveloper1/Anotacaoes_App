import 'package:anotacoes/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class AnotacaoHelper {
  static const String nameTable = "anotacao";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database? _db;

  factory AnotacaoHelper(){
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal();

  get db async {
    if(_db != null) {
      return _db;
    } else {
      _db = await _initializeDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {

    String sql = "CREATE TABLE $nameTable (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)";
    await db.execute(sql);
  }

  //inicilaiza o Banco de Dados
  _initializeDB() async {
    final pathDataBase = await getDatabasesPath();
    final dataBaseLocale = join(pathDataBase, "banco_minhas_anotações.db");

    var db = await openDatabase(dataBaseLocale, version: 1, onCreate: _onCreate);
    return db;
  }

  //Salva anotação
  Future<int> saveAnnotation(Anotacao anotation) async {
    var dataBase = await db;
    int id = await dataBase.insert(nameTable, anotation.toMap());
    return id;
  }

  //Recupera anotação
  retrieveNotes() async {
    var dataBase = await db;
    String sql = "SELECT * FROM $nameTable ORDER BY data DESC";
    List anotation = await dataBase.rawQuery(sql);
    return anotation;
  }

  // Atualiza anotação
  Future<int> updateAnnotation (Anotacao anotation) async {
    var dataBase = await db;
    return await dataBase.update(
      nameTable,
      anotation.toMap(),
      where: "id = ?",
      whereArgs: [anotation.id]
    );
  }

  //Remover anotação
  Future<int> removeAnnotation(int id) async {
    var dataBase = await db;
    return await dataBase.delete(
      nameTable,
      where: "id = ?",
      whereArgs: [id]
    ); 
  }


}