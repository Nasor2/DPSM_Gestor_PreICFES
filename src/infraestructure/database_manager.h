#ifndef DATABASE_MANAGER_H
#define DATABASE_MANAGER_H

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>
#include <QStandardPaths>
#include <QDir>
#include <vector>
#include <QDebug>
#include "booklet.h"
#include "student.h"
#include "simulacrum.h"
#include "result.h"

class DatabaseManager {
public:
    static DatabaseManager &instance(){
        static DatabaseManager _instance;
        return _instance;
    }

    bool init(){
        QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir dir(path);

        if(!dir.exists()) dir.mkpath(path);

        QString dbPath = dir.filePath("preicfes_data_v1.db");

        m_db = QSqlDatabase::addDatabase("QSQLITE");
        m_db.setDatabaseName(dbPath);

        if (!m_db.open()) {
            qDebug() << "Error conectando a la base de datos:" << m_db.lastError().text();
            return false;
        }

        QSqlQuery pragmaQuery(m_db);
        pragmaQuery.exec("PRAGMA foreign_keys = ON;");

        return createTables();
    }

    int asegurarStudents(const std::string &name){
        QSqlQuery query;
        query.prepare("SELECT id FROM students WHERE fullname = :nom");
        query.bindValue(":nom", QString::fromStdString(name));

        if (query.exec() && query.next()) {
            return query.value(0).toInt(); // Ya existía
        }

        query.prepare("INSERT INTO students (fullname) VALUES (:nom)");
        query.bindValue(":nom", QString::fromStdString(name));

        if (query.exec()) {
            return query.lastInsertId().toInt(); // New ID
        }

        //Search
        qDebug() << "Error en asegurarEstudiante:" << query.lastError().text();
        return -1;
    }

    int saveBooklet(const Booklet &b){
        QSqlQuery query;
        query.prepare("INSERT INTO booklets (name, preg_lectura, preg_mate, preg_sociales, preg_naturales, preg_ingles) "
                      "VALUES (:nom, :l, :m, :s, :n, :i)");
        query.bindValue(":nom", QString::fromStdString(b.getName()));
        query.bindValue(":l", b.getTLectura());
        query.bindValue(":m", b.getTMatematicas());
        query.bindValue(":s", b.getTSociales());
        query.bindValue(":n", b.getTNaturales());
        query.bindValue(":i", b.getTIngles());

        if (query.exec()) return query.lastInsertId().toInt();
        return -1;
    }

    int saveSimulacrum(const Simulacrum &s){
        QSqlQuery query;
        query.prepare("INSERT INTO simulacrums (id_booklet, name, date) VALUES (:idC, :nom, :f)");
        query.bindValue(":idC", s.getIdBooklet());
        query.bindValue(":nom", QString::fromStdString(s.getName()));
        query.bindValue(":f", QString::fromStdString(s.getDate()));

        if (query.exec()) return query.lastInsertId().toInt();

        QSqlError err = query.lastError();
        QString driverText = err.driverText().toLower();       // "19" o "2067" en algunos casos
        QString errText    = err.text().toLower();

        if (errText.contains("unique constraint failed") ||
            driverText.contains("unique constraint failed") ||
            errText.contains("simulacrums.name")) { // 19 es SQLITE_CONSTRAINT
            qDebug() << "UNIQUE violation detectada para simulacro:" << QString::fromStdString(s.getName());
            return -2;  // Duplicado por nombre
        }

        qDebug() << "ERROR en saveSimulacrum:" << query.lastError().text();

        return -1;
    }

    Booklet getBookletBySimulacrumId(int simId) {
        QSqlQuery query;
        query.prepare(
            "SELECT b.id, b.name, b.preg_lectura, b.preg_mate, b.preg_sociales, "
            "b.preg_naturales, b.preg_ingles "
            "FROM booklets b "
            "JOIN simulacrums s ON b.id = s.id_booklet "
            "WHERE s.id = :simId"
            );
        query.bindValue(":simId", simId);

        if (query.exec() && query.next()) {
            return Booklet(
                query.value("name").toString().toStdString(),
                query.value("preg_lectura").toInt(),
                query.value("preg_mate").toInt(),
                query.value("preg_sociales").toInt(),
                query.value("preg_naturales").toInt(),
                query.value("preg_ingles").toInt(),
                query.value("id").toInt()
                );
        }

        qDebug() << "No se encontró cuadernillo para simulacro ID:" << simId;
        return Booklet("", 0, 0, 0, 0, 0, -1); // inválido
    }

    int saveResult(const Result &r){
        // 1. Verificamos si ya existe el registro para este estudiante en este simulacro
        QSqlQuery checkQuery;
        checkQuery.prepare("SELECT id FROM results WHERE id_student = :idE AND id_simulacrum = :idS");
        checkQuery.bindValue(":idE", r.getIdStudent());
        checkQuery.bindValue(":idS", r.getIdSimulacrum());

        if (checkQuery.exec() && checkQuery.next()) {
            qDebug() << "Bloqueado: El estudiante ya tiene resultados en este simulacro.";
            return -2; // Código de error específico para "Duplicado"
        }

        // 2. Si no existe, procedemos con el INSERT normal
        QSqlQuery query;
        query.prepare("INSERT INTO results (id_student, id_simulacrum, c_lectura, c_mate, c_sociales, c_naturales, c_ingles) "
                      "VALUES (:idE, :idS, :l, :m, :s, :n, :i)");
        query.bindValue(":idE", r.getIdStudent());
        query.bindValue(":idS", r.getIdSimulacrum());
        query.bindValue(":l", r.getRLectura());
        query.bindValue(":m", r.getRMatematicas());
        query.bindValue(":s", r.getRSociales());
        query.bindValue(":n", r.getRNaturales());
        query.bindValue(":i", r.getRIngles());

        if (!query.exec()) {
            qDebug() << "Error al guardar resultado:" << query.lastError().text();
            return -1;
        }
        return query.lastInsertId().toInt();
    }

    Simulacrum getSimulacrumById(int id){
        QSqlQuery query;
        query.prepare("SELECT id, name, date, id_booklet FROM simulacrums WHERE id = :id");
        query.bindValue(":id", id);
        if (query.exec() && query.next()) {
            return Simulacrum(
                query.value("name").toString().toStdString(),
                query.value("date").toString().toStdString(),
                query.value("id_booklet").toInt(),
                id
                );
        }
        return Simulacrum("", "", -1, -1); // inválido
    }

    std::vector<Simulacrum> getSimulacrums() {
        std::vector<Simulacrum> lista;
        QSqlQuery query("SELECT name, date, id_booklet, id FROM simulacrums ORDER BY date DESC");

        while (query.next()) {
            // Extraemos los datos de SQLite
            std::string name = query.value(0).toString().toStdString();
            std::string date = query.value(1).toString().toStdString();
            int idBooklet = query.value(2).toInt();
            int id = query.value(3).toInt();

            lista.emplace_back(name, date, idBooklet, id);
        }
        return lista;
    }

    std::vector<Booklet> getBooklets(){
        std::vector<Booklet> list;
        QSqlQuery query("SELECT name, preg_lectura, preg_mate, preg_sociales, preg_naturales, preg_ingles, id FROM booklets");
        while(query.next()){
            list.emplace_back(
                query.value(0).toString().toStdString(),
                query.value(1).toInt(),
                query.value(2).toInt(),
                query.value(3).toInt(),
                query.value(4).toInt(),
                query.value(5).toInt(),
                query.value(6).toInt()
                );
        }

        return list;
    }

    struct RowResult {
        std::string studentName;
        int global;
    };

    std::vector<RowResult> getResultsFromSimulacrum(int idSimulacrum){
        std::vector<RowResult> list;

        QSqlQuery query;
        query.prepare("SELECT e.fullname, "
                      "r.c_lectura, r.c_mate, r.c_sociales, r.c_naturales, r.c_ingles, " // Aciertos
                      "c.preg_lectura, c.preg_mate, c.preg_sociales, c.preg_naturales, c.preg_ingles, " // Totales
                      "c.name, c.id " // Info del cuadernillo para el objeto temporal
                      "FROM results r "
                      "JOIN students e ON r.id_student = e.id "
                      "JOIN simulacrums s ON r.id_simulacrum = s.id "
                      "JOIN booklets c ON s.id_booklet = c.id "
                      "WHERE r.id_simulacrum = :idS");
        query.bindValue(":idS", idSimulacrum);

        if (query.exec()) {
            while (query.next()) {
                // 1. Creamos un objeto Result temporal usando tu constructor
                Result resTemp(
                    0, // idStudent (no lo necesitamos para el cálculo aquí, ponemos 0)
                    idSimulacrum,
                    query.value(1).toInt(), // l
                    query.value(2).toInt(), // m
                    query.value(3).toInt(), // s
                    query.value(4).toInt(), // n
                    query.value(5).toInt()  // i
                    );

                // 2. Creamos un objeto Booklet temporal para pasarle los totales al cálculo
                Booklet bookTemp(
                    query.value(11).toString().toStdString(), // nombre
                    query.value(6).toInt(), // tL
                    query.value(7).toInt(), // tM
                    query.value(8).toInt(), // tS
                    query.value(9).toInt(), // tN
                    query.value(10).toInt(), // tI
                    query.value(12).toInt()  // id
                    );

                // 3. Usamos tu lógica de negocio original
                int global = resTemp.calculateGlobalScore(bookTemp);

                // 4. Guardamos en la lista para la UI
                list.push_back({
                    query.value(0).toString().toStdString(), // nombreEstudiante
                    global
                });
            }
        }
            return list;
    }

    bool deleteSimulacrum(int idSimulacrum){
        QSqlQuery checkQuery;
        checkQuery.prepare("SELECT id FROM simulacrums WHERE id = :id");
        checkQuery.bindValue(":id", idSimulacrum);

        if (!checkQuery.exec() || !checkQuery.next()) {
            qDebug() << "Error: El simulacro con ID" << idSimulacrum << "no existe.";
            return false;
        }

        QSqlQuery deleteQuery;
        deleteQuery.prepare("DELETE FROM simulacrums WHERE id = :id");
        deleteQuery.bindValue(":id", idSimulacrum);

        return deleteQuery.exec();
    }

    // infrastructure/database_manager.h
    bool deleteResult(int idSim, int idE) { // Recibe ID Simulacro e ID Estudiante
        QSqlQuery query;
        query.prepare("DELETE FROM results WHERE id_student = :idE AND id_simulacrum = :idS");
        query.bindValue(":idE", idE);
        query.bindValue(":idS", idSim);

        if (!query.exec()) {
            qDebug() << "Error SQL al borrar resultado:" << query.lastError().text();
            return false;
        }
        return true;
    }

    bool deleteBooklet(int bookletId) {
        QSqlQuery query;
        query.prepare("DELETE FROM booklets WHERE id = :id");
        query.bindValue(":id", bookletId);
        if (!query.exec()) {
            qDebug() << "Error al eliminar cuadernillo:" << query.lastError().text();
            return false;
        }
        return true;
    }

    int updateSimulacrum(const Simulacrum &s){
        if(s.getId() <= 0) return -1;
        QSqlQuery query;
        query.prepare("UPDATE simulacrums SET name = :nom, date = :f, id_booklet = :idC WHERE id = :id");
        query.bindValue(":nom", QString::fromStdString(s.getName()));
        query.bindValue(":f", QString::fromStdString(s.getDate()));
        query.bindValue(":idC", s.getIdBooklet());
        query.bindValue(":id", s.getId());

        if (query.exec()) return s.getId();

        QSqlError err = query.lastError();
        QString errText = err.text().toLower();
        if (errText.contains("unique constraint failed") || errText.contains("simulacrums.name")) {
            return -2; // Duplicado
        }

        qDebug() << "Error al actualizar simulacro:" << err.text();
        return -1;
    }

    bool updateBooklet(const Booklet &b){
        if(b.getId() <= 0) return false;

        QSqlQuery query;
        query.prepare("UPDATE booklets SET name = :nom, "
                      "preg_lectura = :l, preg_mate = :m, preg_sociales = :s, "
                      "preg_naturales = :n, preg_ingles = :i WHERE id = :id");
        query.bindValue(":nom", QString::fromStdString(b.getName()));
        query.bindValue(":l", b.getTLectura());
        query.bindValue(":m", b.getTMatematicas());
        query.bindValue(":s", b.getTSociales());
        query.bindValue(":n", b.getTNaturales());
        query.bindValue(":i", b.getTIngles());
        query.bindValue(":id", b.getId());

        return query.exec();
    }

    std::vector<Student> getAllStudents(){
        std::vector<Student> list;
        QSqlQuery query("SELECT fullname, id FROM students ORDER BY fullname ASC");
        while(query.next()){
            list.emplace_back(query.value(0).toString().toStdString(), query.value(1).toInt());
        }
        return list;
    }

    struct FullResult {
        std::string studentName;
        int studentId;
        int l, m, s, n, i; // Aciertos
        int tL, tM, tS, tN, tI; // Totales del cuadernillo
    };

    std::vector<FullResult> getDetailedResultsBySimulacrum(int idSim) {
        std::vector<FullResult> list;
        QSqlQuery query;
        query.prepare("SELECT e.id, e.fullname, r.c_lectura, r.c_mate, r.c_sociales, r.c_naturales, r.c_ingles, "
                      "b.preg_lectura, b.preg_mate, b.preg_sociales, b.preg_naturales, b.preg_ingles "
                      "FROM results r "
                      "JOIN students e ON r.id_student = e.id "
                      "JOIN simulacrums s ON r.id_simulacrum = s.id "
                      "JOIN booklets b ON s.id_booklet = b.id "
                      "WHERE r.id_simulacrum = :idS");
        query.bindValue(":idS", idSim);
        if (query.exec()) {
            while (query.next()) {
                list.push_back({
                    query.value(1).toString().toStdString(),  // fullname
                    query.value(0).toInt(),                  // ← NUEVO: studentId
                    query.value(2).toInt(), query.value(3).toInt(), query.value(4).toInt(), query.value(5).toInt(), query.value(6).toInt(),
                    query.value(7).toInt(), query.value(8).toInt(), query.value(9).toInt(), query.value(10).toInt(), query.value(11).toInt()
                });
            }
        }
        return list;
    }

    Booklet getBookletById(int id) {
        QSqlQuery query;
        query.prepare("SELECT name, preg_lectura, preg_mate, preg_sociales, preg_naturales, preg_ingles, id FROM booklets WHERE id = :id");
        query.bindValue(":id", id);
        if (query.exec() && query.next()) {
            return Booklet(
                query.value(0).toString().toStdString(),
                query.value(1).toInt(), query.value(2).toInt(),
                query.value(3).toInt(), query.value(4).toInt(),
                query.value(5).toInt(), query.value(6).toInt()
                );
        }
        return Booklet("", 0, 0, 0, 0, 0);
    }

    bool updateResult(const Result &r){
        QSqlQuery query;
        query.prepare("UPDATE results SET c_lectura = :l, c_mate = :m, c_sociales = :s, "
                      "c_naturales = :n, c_ingles = :i "
                      "WHERE id_student = :idE AND id_simulacrum = :idS");
        query.bindValue(":l", r.getRLectura());
        query.bindValue(":m", r.getRMatematicas());
        query.bindValue(":s", r.getRSociales());
        query.bindValue(":n", r.getRNaturales());
        query.bindValue(":i", r.getRIngles());
        query.bindValue(":idE", r.getIdStudent());
        query.bindValue(":idS", r.getIdSimulacrum());
        return query.exec();
    }

    // Para editar estudiante
    bool updateStudent(int id, const std::string& newName) {
        QSqlQuery query;
        query.prepare("UPDATE students SET fullname = :nom WHERE id = :id");
        query.bindValue(":nom", QString::fromStdString(newName));
        query.bindValue(":id", id);
        if (!query.exec()) {
            qDebug() << "Error al actualizar estudiante:" << query.lastError().text();
            return false;
        }
        return true;
    }

    // Para eliminar estudiante (results se borran solos por CASCADE)
    bool deleteStudent(int id) {
        QSqlQuery query;
        query.prepare("DELETE FROM students WHERE id = :id");
        query.bindValue(":id", id);
        if (!query.exec()) {
            qDebug() << "Error al eliminar estudiante:" << query.lastError().text();
            return false;
        }
        return true;
    }

    // Para obtener simulacros de un estudiante
    std::vector<Simulacrum> getStudentSimulacra(int studentId) {
        std::vector<Simulacrum> list;
        QSqlQuery query;
        query.prepare("SELECT s.id, s.name, s.date, s.id_booklet "
                      "FROM simulacrums s "
                      "JOIN results r ON s.id = r.id_simulacrum "
                      "WHERE r.id_student = :idE "
                      "ORDER BY s.date DESC");
        query.bindValue(":idE", studentId);
        if (query.exec()) {
            while (query.next()) {
                list.emplace_back(
                    query.value(1).toString().toStdString(),  // name
                    query.value(2).toString().toStdString(),  // date
                    query.value(3).toInt(),                   // id_booklet
                    query.value(0).toInt()                    // id
                    );
            }
        } else {
            qDebug() << "Error al obtener simulacros de estudiante:" << query.lastError().text();
        }
        return list;
    }

    // Para obtener info básica de estudiante (nombre y total simulacros)
    Student getStudentById(int id) {
        QSqlQuery query;
        query.prepare("SELECT fullname FROM students WHERE id = :id");
        query.bindValue(":id", id);
        if (query.exec() && query.next()) {
            return Student(query.value(0).toString().toStdString(), id);
        }
        return Student("", -1);
    }

    int getStudentTotalSimulacra(int studentId) {
        QSqlQuery query;
        query.prepare("SELECT COUNT(DISTINCT id_simulacrum) FROM results WHERE id_student = :idE");
        query.bindValue(":idE", studentId);
        if (query.exec() && query.next()) {
            return query.value(0).toInt();
        }
        return 0;
    }

    struct SimulacrumWithScore {
        int id;
        std::string name;
        std::string date;
        int idBooklet;
        int score;  // Puntaje del estudiante en este simulacro
    };

    std::vector<SimulacrumWithScore> getStudentSimulacraWithScores(int studentId) {
        std::vector<SimulacrumWithScore> list;
        QSqlQuery query;
        query.prepare(
            "SELECT s.id, s.name, s.date, s.id_booklet, "
            "r.c_lectura, r.c_mate, r.c_sociales, r.c_naturales, r.c_ingles, "
            "b.preg_lectura, b.preg_mate, b.preg_sociales, b.preg_naturales, b.preg_ingles "
            "FROM simulacrums s "
            "JOIN results r ON s.id = r.id_simulacrum "
            "JOIN booklets b ON s.id_booklet = b.id "
            "WHERE r.id_student = :idE "
            "ORDER BY s.date DESC"
            );
        query.bindValue(":idE", studentId);

        if (query.exec()) {
            while (query.next()) {
                // Calcular score usando la lógica de dominio
                Result tempRes(
                    studentId,
                    query.value(0).toInt(), // simId
                    query.value(4).toInt(), // l
                    query.value(5).toInt(), // m
                    query.value(6).toInt(), // s
                    query.value(7).toInt(), // n
                    query.value(8).toInt()  // i
                    );

                Booklet tempBook(
                    "",
                    query.value(9).toInt(),  // tL
                    query.value(10).toInt(), // tM
                    query.value(11).toInt(), // tS
                    query.value(12).toInt(), // tN
                    query.value(13).toInt()  // tI
                    );

                list.push_back({
                    query.value(0).toInt(),                    // id
                    query.value(1).toString().toStdString(),   // name
                    query.value(2).toString().toStdString(),   // date
                    query.value(3).toInt(),                    // idBooklet
                    tempRes.calculateGlobalScore(tempBook)     // score calculado
                });
            }
        } else {
            qDebug() << "Error al obtener simulacros con puntajes:" << query.lastError().text();
        }
        return list;
    }

    // Exportar base de datos
    QString exportDatabase() {
        QString downloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
        if (downloadsPath.isEmpty()) {
            qDebug() << "No se pudo acceder a la carpeta de Descargas";
            return "";
        }

        // Generar nombre con timestamp
        QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss");
        QString exportFileName = QString("preicfes_backup_%1.db").arg(timestamp);
        QString exportPath = QDir(downloadsPath).filePath(exportFileName);

        // Cerrar conexión temporalmente
        QString currentDbPath = m_db.databaseName();
        m_db.close();

        // Copiar archivo
        bool success = QFile::copy(currentDbPath, exportPath);

        // Reabrir conexión
        m_db.open();

        if (success) {
            qDebug() << "Base de datos exportada a:" << exportPath;
            return exportPath;
        } else {
            qDebug() << "Error al exportar la base de datos";
            return "";
        }
    }

    // Validar estructura de base de datos
    bool validateDatabaseStructure(const QString& dbPath) {
        QSqlDatabase testDb = QSqlDatabase::addDatabase("QSQLITE", "validation_connection");
        testDb.setDatabaseName(dbPath);

        if (!testDb.open()) {
            qDebug() << "No se pudo abrir el archivo para validación";
            QSqlDatabase::removeDatabase("validation_connection");
            return false;
        }

        // Verificar que existan las tablas necesarias
        QStringList requiredTables = {"students", "booklets", "simulacrums", "results"};
        QStringList existingTables = testDb.tables();

        for (const QString& table : requiredTables) {
            if (!existingTables.contains(table)) {
                qDebug() << "Tabla faltante:" << table;
                testDb.close();
                QSqlDatabase::removeDatabase("validation_connection");
                return false;
            }
        }

        // Validar estructura de tabla students
        QSqlQuery query(testDb);
        query.exec("PRAGMA table_info(students)");
        QStringList studentColumns;
        while (query.next()) {
            studentColumns << query.value(1).toString();
        }
        if (!studentColumns.contains("id") || !studentColumns.contains("fullname")) {
            qDebug() << "Estructura de tabla 'students' inválida";
            testDb.close();
            QSqlDatabase::removeDatabase("validation_connection");
            return false;
        }

        // Validar estructura de tabla simulacrums
        query.exec("PRAGMA table_info(simulacrums)");
        QStringList simColumns;
        while (query.next()) {
            simColumns << query.value(1).toString();
        }
        if (!simColumns.contains("id") || !simColumns.contains("name") || !simColumns.contains("date")) {
            qDebug() << "Estructura de tabla 'simulacrums' inválida";
            testDb.close();
            QSqlDatabase::removeDatabase("validation_connection");
            return false;
        }

        testDb.close();
        QSqlDatabase::removeDatabase("validation_connection");

        qDebug() << "Validación exitosa";
        return true;
    }

    // Crear backup de la base de datos actual
    bool createBackup() {
        QString currentDbPath = m_db.databaseName();
        QString backupPath = currentDbPath + ".backup_" + QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss");

        m_db.close();
        bool success = QFile::copy(currentDbPath, backupPath);
        m_db.open();

        if (success) {
            qDebug() << "Backup creado en:" << backupPath;
        } else {
            qDebug() << "Error al crear backup";
        }
        return success;
    }

    // Importar base de datos
    QString importDatabase(const QString& sourcePath) {
        // 1. Validar que el archivo existe
        if (!QFile::exists(sourcePath)) {
            return "El archivo seleccionado no existe";
        }

        // 2. Validar estructura
        if (!validateDatabaseStructure(sourcePath)) {
            return "El archivo no es una base de datos válida de DPMS";
        }

        // 3. Crear backup de la base actual
        if (!createBackup()) {
            return "Error al crear backup de la base de datos actual";
        }

        // 4. Cerrar conexión actual
        QString currentDbPath = m_db.databaseName();
        m_db.close();

        // 5. Eliminar base actual
        if (!QFile::remove(currentDbPath)) {
            qDebug() << "No se pudo eliminar la base de datos actual";
            m_db.open();
            return "Error al reemplazar la base de datos actual";
        }

        // 6. Copiar nueva base
        if (!QFile::copy(sourcePath, currentDbPath)) {
            qDebug() << "Error al copiar la nueva base de datos";
            // Intentar restaurar el backup
            QString latestBackup = currentDbPath + ".backup_" + QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss");
            QFile::copy(latestBackup, currentDbPath);
            m_db.open();
            return "Error al importar. Base de datos restaurada desde backup";
        }

        // 7. Reabrir conexión
        if (!m_db.open()) {
            return "Error al abrir la nueva base de datos";
        }

        // 8. Activar foreign keys
        QSqlQuery pragmaQuery(m_db);
        pragmaQuery.exec("PRAGMA foreign_keys = ON;");

        qDebug() << "Base de datos importada exitosamente";
        return ""; // Vacío significa éxito
    }

private:
    DatabaseManager() {}
    QSqlDatabase m_db;

    bool createTables(){
        QSqlQuery query;
        bool success = true;

        //Students
        if(!query.exec("CREATE TABLE IF NOT EXISTS students ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                        "fullname TEXT UNIQUE NOT NULL)")) success = false;

        //Booklets
        if(!query.exec("CREATE TABLE IF NOT EXISTS booklets ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                   "name TEXT NOT NULL, "
                   "preg_lectura INTEGER, preg_mate INTEGER, "
                        "preg_sociales INTEGER, preg_naturales INTEGER, preg_ingles INTEGER)")) success = false;

        // Tabla Simulacros
        if(!query.exec("CREATE TABLE IF NOT EXISTS simulacrums ("
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                   "id_booklet INTEGER, "
                   "name TEXT NOT NULL UNIQUE, date DATE, "
                        "FOREIGN KEY(id_booklet) REFERENCES booklets(id) ON DELETE CASCADE)"))success = false;

        // Tabla Resultados
        if(!query.exec("CREATE TABLE IF NOT EXISTS results ("
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                        "id_student INTEGER, id_simulacrum INTEGER, "
                        "c_lectura INTEGER, c_mate INTEGER, c_sociales INTEGER, "
                        "c_naturales INTEGER, c_ingles INTEGER, "
                        "FOREIGN KEY(id_student) REFERENCES students(id) ON DELETE CASCADE, "
                        "FOREIGN KEY(id_simulacrum) REFERENCES simulacrums(id) ON DELETE CASCADE, "
                        "UNIQUE(id_student, id_simulacrum))")) success = false;

        if (!success) {
            qDebug() << "Error creando tablas:" << query.lastError().text();
        }

        return true;
    }
};

#endif
