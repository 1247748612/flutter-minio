import 'package:sqflite/sqflite.dart';

Database database;

class DownloadDb {
  Database _database;

  DownloadDb();

  Future<Database> initDb() {
    return getDatabasesPath().then((path) async {
      final dbPath = path + '/minio.db';
      // await deleteDatabase(dbPath);
      this._database = await openDatabase(dbPath, version: 1,
          onCreate: (Database db, int version) {
        db.execute(
            'CREATE TABLE DownloadLog (id INTEGER PRIMARY KEY, bucketName TEXT, filename TEXT, createAt TEXT, updateAt TEXT, fileSize INTEGER, downloadSize INTEGER, state INTEGER, stateText TEXT, filePath TEXT)');
      });
      // this._database.execute('DROP TABLE DownloadLog');
      database = this._database;
      return this._database;
    });
  }

  insert(bucketName, filename, createAt, updateAt, fileSize, downloadSize,
      int state, filePath) {
    this._database.rawInsert(
        'INSERT INTO DownloadLog (bucketName, filename, createAt, updateAt, fileSize, downloadSize, state, stateText, filePath) VALUES(?, ?, ?, ?, ?, ?, ?, "", ?)',
        [
          bucketName,
          filename,
          createAt,
          updateAt,
          fileSize,
          downloadSize,
          state,
          filePath
        ]);
  }

  updateSize(int id, int downloadSize) async {
    return await this._database.rawUpdate(
        'UPDATE DownloadLog SET downloadSize = ? WHERE id = $id',
        [downloadSize]);
  }

  updateState(int id, int state, {stateText = ''}) async {
    return await this._database.rawUpdate(
        'UPDATE DownloadLog SET state = ?, stateText = ?  WHERE id = $id',
        [state, stateText]);
  }

  // 查询所有下载数据 后续可能改成分页
  Future<List<Map<String, dynamic>>> findAll() async {
    final result = await this._database.rawQuery('SELECT * FROM "DownloadLog"');
    return result;
  }

  close() {
    this._database.close();
  }
}