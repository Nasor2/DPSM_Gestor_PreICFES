#include "simulacrum_controller.h"
#include "simulacrum_service.h"

#include <QFile>
#include <QTextStream>
#include <QFileDialog>
#include <QDesktopServices>
#include <QUrl>
#include <QRegularExpression>
#include <QDir>
#include <QDebug>

#include <QEventLoop>
#include <QTimer>
#include <QStandardPaths>
#include <QThread>

#include <QWebEngineView>
#include <QWebEnginePage>

#include <QProcess>
#include <QTemporaryDir>
#include <QProgressDialog>
#include <QCoreApplication>
#include <QFileInfo>

#include <algorithm>
#include <vector>

#include <QDirIterator>


SimulacrumController::SimulacrumController(QObject *parent) : QObject(parent) {}
// --- 1. Gestión de Simulacros ---

int SimulacrumController::createSimulacrum(QString name, QString date, int bookletId) {
    return SimulacrumService::intance().startSimulacrum(
        name.toStdString(), date.toStdString(), bookletId
        );
}

QVariantList SimulacrumController::getSimulacrumList() {
    auto list = SimulacrumService::intance().getAllSimulacrums();
    qDebug() << "Enviando a QML" << list.size() << "simulacros";

    QVariantList result;
    for (const auto& s : list) {
        QVariantMap map;
        map["id"] = s.getId();
        map["name"] = QString::fromStdString(s.getName());

        QDate dateObj = QDate::fromString(QString::fromStdString(s.getDate()), "yyyy-MM-dd");
        map["date"] = dateObj.isValid() ? dateObj.toString("dd-MM-yyyy") : QString::fromStdString(s.getDate());
        result.append(map);
    }
    return result;
}

QVariantMap SimulacrumController::createFullSimulacrum(QString simName, QString date, QString bName,
                                                       int l, int m, int s, int n, int i) {
    int result = SimulacrumService::intance().createFullSimulacrum(
        simName.toStdString(), date.toStdString(), bName.toStdString(), l, m, s, n, i);

    QVariantMap response;
    if (result > 0) {
        response["success"] = true;
        response["id"] = result;
        response["message"] = "Simulacro creado correctamente";
    } else if (result == -2) {
        response["success"] = false;
        response["message"] = "Ya existe un simulacro con ese nombre.";
        response["errorCode"] = "duplicate_name";
    } else {
        response["success"] = false;
        response["message"] = "Error al crear el simulacro.";
    }
    return response;
}

QVariantMap SimulacrumController::getSimulacrumData(int simId) {
    Simulacrum sim = DatabaseManager::instance().getSimulacrumById(simId);
    QVariantMap map;
    if (sim.getId() < 0) return map;
    map["id"] = sim.getId();
    map["name"] = QString::fromStdString(sim.getName());
    map["date"] = QString::fromStdString(sim.getDate());
    map["bookletId"] = sim.getIdBooklet();
    return map;
}

QVariantMap SimulacrumController::updateFullSimulacrum(int simId, QString simName, QString date, QString bName,
                                                       int l, int m, int s, int n, int i) {
    int result = SimulacrumService::intance().updateFullSimulacrum(
        simId, simName.toStdString(), date.toStdString(), bName.toStdString(), l, m, s, n, i);

    QVariantMap response;
    response["success"] = (result > 0);
    response["message"] = (result > 0) ? "Actualizado correctamente" : "Error al actualizar";
    return response;
}

QVariantMap SimulacrumController::deleteFullSimulacrum(int simId) {
    bool deleted = SimulacrumService::intance().deleteFullSimulacrum(simId);
    QVariantMap map;
    map["success"] = deleted;
    map["message"] = deleted ? "Simulacro eliminado" : "Error al eliminar";
    return map;
}

// --- 2. Gestión de Resultados ---

QVariantMap SimulacrumController::addResult(int simId,
                                            QString identification,
                                            QString studentName,
                                            QString school,
                                            int l, int m, int s, int n, int i)
{
    // Opcional: formatear nombre si lo deseas
    QString formattedName = formatStudentName(studentName);

    // Llamada actualizada con los 3 campos de estudiante
    auto resp = SimulacrumService::intance().registerStudentResultValidated(
        simId,
        identification.toStdString(),
        formattedName.toStdString(),
        school.toStdString(),
        l, m, s, n, i
        );

    QVariantMap map;
    map["success"] = resp.success;
    map["message"] = resp.message;
    return map;
}

QVariantList SimulacrumController::getDetailedResults(int simId) {
    auto list = DatabaseManager::instance().getResultsFromSimulacrum(simId);
    QVariantList result;
    for (const auto& res : list) {
        QVariantMap map;
        map["name"] = QString::fromStdString(res.studentName);
        map["score"] = res.global;
        result.append(map);
    }
    return result;
}

QVariantList SimulacrumController::getFullResultsList(int simId)
{
    auto list = DatabaseManager::instance().getDetailedResultsBySimulacrum(simId);

    struct ResultWithScore {
        DatabaseManager::FullResult result;
        int globalScore;
    };

    std::vector<ResultWithScore> resultsWithScores;

    for (const auto& res : list) {
        Result tempRes(0, simId, res.l, res.m, res.s, res.n, res.i);
        Booklet tempBook("", res.tL, res.tM, res.tS, res.tN, res.tI);
        int globalScore = tempRes.calculateGlobalScore(tempBook);
        resultsWithScores.push_back({res, globalScore});
    }

    std::sort(resultsWithScores.begin(), resultsWithScores.end(),
              [](const ResultWithScore& a, const ResultWithScore& b) {
                  return a.globalScore > b.globalScore;
              });

    QVariantList result;
    for (const auto& item : resultsWithScores) {
        QVariantMap map;
        map["studentId"]       = item.result.studentId;
        map["studentName"]     = QString::fromStdString(item.result.studentName);
        map["identification"]  = QString::fromStdString(item.result.identification);   // ← NUEVO
        map["school"]          = QString::fromStdString(item.result.school);           // ← NUEVO
        map["l"] = item.result.l;
        map["m"] = item.result.m;
        map["s"] = item.result.s;
        map["n"] = item.result.n;
        map["i"] = item.result.i;
        map["global"] = item.globalScore;
        result.append(map);
    }

    return result;
}


QVariantMap SimulacrumController::updateStudentResult(int simId,
                                                      QString identification,
                                                      QString studentName,
                                                      QString school,
                                                      int l, int m, int s, int n, int i)
{
    QString formattedName = formatStudentName(studentName);

    auto resp = SimulacrumService::intance().updateStudentResultValidated(
        simId,
        identification.toStdString(),
        formattedName.toStdString(),
        school.toStdString(),
        l, m, s, n, i
        );

    QVariantMap map;
    map["success"] = resp.success;
    map["message"] = resp.message;
    return map;
}

bool SimulacrumController::deleteResult(int simId, QString identification) {
    return SimulacrumService::intance().removeStudentResult(simId, identification.toStdString());
}

// --- 3. Gestión de Estudiantes ---
QString SimulacrumController::formatStudentName(const QString& rawName) {
    if (rawName.isEmpty()) return rawName;

    QStringList words = rawName.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);

    for (QString& word : words) {
        if (!word.isEmpty()) {
            word = word.at(0).toUpper() + word.mid(1).toLower();
        }
    }

    return words.join(" ");
}

QVariantList SimulacrumController::getStudentSuggestions() {
    auto students = DatabaseManager::instance().getAllStudents();
    QVariantList suggestions;
    for (const auto& s : students) {
        QVariantMap studentMap;
        studentMap["identification"] = QString::fromStdString(s.getIdentification());
        studentMap["name"] = QString::fromStdString(s.getFullname());
        studentMap["school"] = QString::fromStdString(s.getSchool());
        suggestions << studentMap;
    }
    return suggestions;
}

QVariantList SimulacrumController::getStudentsList() {
    auto students = DatabaseManager::instance().getAllStudents();
    QVariantList list;
    for (const auto& s : students) {
        QVariantMap map;
        map["id"] = s.getId();
        map["name"] = QString::fromStdString(s.getFullname());
        map["identification"] = QString::fromStdString(s.getIdentification()); // CAMBIO
        map["school"] = QString::fromStdString(s.getSchool()); // CAMBIO
        list.append(map);
    }
    return list;
}

QVariantMap SimulacrumController::updateStudent(int id, QString newName, QString newIdentification, QString newSchool)
{
    QString formatted = formatStudentName(newName);

    bool success = SimulacrumService::intance().updateStudentValidated(
        id,
        formatted.toStdString(),
        newIdentification.toStdString(),
        newSchool.toStdString()
        );

    QVariantMap map;
    map["success"] = success;
    map["message"] = success ? "Estudiante actualizado correctamente"
                             : "No se pudo actualizar. Verifica que la identificación sea válida y no esté duplicada.";
    return map;
}

QVariantMap SimulacrumController::deleteStudent(int id) {
    bool success = SimulacrumService::intance().deleteStudent(id);
    QVariantMap map;
    map["success"] = success;
    map["message"] = success ?
                         "Estudiante eliminado correctamente" :
                         "No se pudo eliminar el estudiante (¿existe aún?)";
    return map;
}

QVariantList SimulacrumController::getStudentSimulacra(int studentId) {
    auto simulacra = SimulacrumService::intance().getStudentSimulacra(studentId);
    QVariantList list;
    for (const auto& sim : simulacra) {
        QVariantMap map;
        map["id"] = sim.getId();
        map["name"] = QString::fromStdString(sim.getName());
        QDate dateObj = QDate::fromString(QString::fromStdString(sim.getDate()), "yyyy-MM-dd");
        map["date"] = dateObj.isValid() ? dateObj.toString("dd-MM-yyyy") : QString::fromStdString(sim.getDate());
        list.append(map);
    }
    return list;
}

QVariantMap SimulacrumController::getStudentInfo(int studentId) {
    auto student = SimulacrumService::intance().getStudentById(studentId);
    QVariantMap map;
    if (student.getId() < 0) return map;
    map["id"] = student.getId();
    map["name"] = QString::fromStdString(student.getFullname());
    map["totalSimulacra"] = SimulacrumService::intance().getStudentTotalSimulacra(studentId);
    return map;
}

QVariantMap SimulacrumController::getStudentById(int studentId) {
    auto student = SimulacrumService::intance().getStudentById(studentId);
    QVariantMap map;
    if (student.getId() < 0) return map;

    map["id"] = student.getId();
    map["fullname"] = QString::fromStdString(student.getFullname());
    map["identification"] = QString::fromStdString(student.getIdentification());
    map["school"] = QString::fromStdString(student.getSchool());

    return map;
}

QVariantList SimulacrumController::getStudentSimulacraWithScores(int studentId) {
    auto simulacra = SimulacrumService::intance().getStudentSimulacraWithScores(studentId);
    QVariantList list;
    for (const auto& sim : simulacra) {
        QVariantMap map;
        map["id"] = sim.id;
        map["name"] = QString::fromStdString(sim.name);
        QDate dateObj = QDate::fromString(QString::fromStdString(sim.date), "yyyy-MM-dd");
        map["date"] = dateObj.isValid() ? dateObj.toString("dd-MM-yyyy") : QString::fromStdString(sim.date);
        map["score"] = sim.score;
        list.append(map);
    }
    return list;
}

// --- 4. Dashboards y Utilidades ---

QVariantList SimulacrumController::getEvolutionGraphData() {
    auto history = SimulacrumService::intance().getGlobalEvolution();
    QVariantList list;
    for (const auto& point : history) {
        QVariantMap map;
        QDate dateObj = QDate::fromString(QString::fromStdString(point.date), "yyyy-MM-dd");
        map["label"] = dateObj.isValid() ? dateObj.toString("dd/MM") : QString::fromStdString(point.date);
        map["value"] = point.globalAverage;
        map["tooltip"] = QString::fromStdString(point.name);
        list.append(map);
    }
    return list;
}

QVariantMap SimulacrumController::getGlobalDistributionData() {
    auto dist = SimulacrumService::intance().getGlobalDistribution();
    QVariantMap map;
    map["insuficiente"] = dist.totalInsuficiente;
    map["bajo"] = dist.totalMinimo;
    map["medio"] = dist.totalSatisfactorio;
    map["alto"] = dist.totalAvanzado;
    map["total"] = dist.totalInsuficiente + dist.totalMinimo + dist.totalSatisfactorio + dist.totalAvanzado;
    return map;
}

QVariantList SimulacrumController::getTopStudentsGlobal() {
    QVariantList topList;
    auto students = DatabaseManager::instance().getAllStudents();
    struct StudentRank { QString name; double average; };
    std::vector<StudentRank> ranking;

    for (const auto& s : students) {
        auto simulacros = SimulacrumService::intance().getAllSimulacrums();
        double totalSum = 0; int count = 0;
        for (const auto& sim : simulacros) {
            auto results = DatabaseManager::instance().getDetailedResultsBySimulacrum(sim.getId());
            for (const auto& res : results) {
                if (res.studentId == s.getId()) {
                    Result tr(0, sim.getId(), res.l, res.m, res.s, res.n, res.i);
                    Booklet tb("", res.tL, res.tM, res.tS, res.tN, res.tI);
                    totalSum += tr.calculateGlobalScore(tb);
                    count++; break;
                }
            }
        }
        if (count > 0) ranking.push_back({QString::fromStdString(s.getFullname()), totalSum / count});
    }
    std::sort(ranking.begin(), ranking.end(), [](const StudentRank& a, const StudentRank& b) { return a.average > b.average; });
    for (int i = 0; i < std::min(5, (int)ranking.size()); ++i) {
        QVariantMap m; m["name"] = ranking[i].name; m["score"] = ranking[i].average; topList.append(m);
    }
    return topList;
}

QVariantMap SimulacrumController::getSimulacrumStats(int simId) {
    auto stats = SimulacrumService::intance().getStats(simId);
    QVariantMap map;
    map["avgL"] = stats.avgL; map["avgM"] = stats.avgM; map["avgS"] = stats.avgS;
    map["avgN"] = stats.avgN; map["avgI"] = stats.avgI; map["total"] = stats.totalEstudiantes;
    map["topScore"] = stats.topScore; map["minScore"] = stats.minScore; map["avgGlobal"] = stats.avgGlobal;

    QVariantList t5, b5;
    for(const auto& s : stats.topStudents) { QVariantMap sm; sm["name"] = QString::fromStdString(s.name); sm["score"] = s.score; t5.append(sm); }
    for(const auto& s : stats.bottomStudents) { QVariantMap sm; sm["name"] = QString::fromStdString(s.name); sm["score"] = s.score; b5.append(sm); }
    map["top5"] = t5; map["bottom5"] = b5;
    return map;
}

QVariantMap SimulacrumController::getBookletData(int bookletId) {
    Booklet b = DatabaseManager::instance().getBookletById(bookletId);
    QVariantMap map;
    map["name"] = QString::fromStdString(b.getName());
    map["tL"] = b.getTLectura(); map["tM"] = b.getTMatematicas(); map["tS"] = b.getTSociales();
    map["tN"] = b.getTNaturales(); map["tI"] = b.getTIngles();
    return map;
}

double SimulacrumController::getGlobalAverageScore() {
    return SimulacrumService::intance().getGlobalAverageScoreAcrossAllSimulacra();
}

QVariantMap SimulacrumController::exportDatabase() {
    QString path = SimulacrumService::intance().exportDatabaseToDownloads();
    QVariantMap map; map["success"] = !path.isEmpty(); map["message"] = map["success"].toBool() ? "Exportado" : "Error"; map["path"] = path;
    return map;
}

QVariantMap SimulacrumController::importDatabase(QString filePath) {
    QString err = SimulacrumService::intance().importDatabaseFromFile(filePath.toStdString());
    QVariantMap map; map["success"] = err.isEmpty(); map["message"] = err.isEmpty() ? "Importado" : err;
    return map;
}

// Función auxiliar para construir el HTML dinámico completo desde BoletinData
QString SimulacrumController::buildHtmlFromData(const SimulacrumService::BoletinData& data) {
    // 1. Cargar template base
    QFile htmlFile(":/qt/qml/DPMS_Gestor_PreICFES/src/templates/boletin.html");
    if (!htmlFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Error al cargar template HTML";
        return "";
    }
    QString html = QTextStream(&htmlFile).readAll();

    // 2. Embeber CSS directamente (para que sea independiente)
    QFile cssFile(":/qt/qml/DPMS_Gestor_PreICFES/src/templates/stylesheet.css");
    if (cssFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString css = QTextStream(&cssFile).readAll();
        html.replace(QRegularExpression("<link rel=\"stylesheet\" href=\"stylesheet.css\" />"), "<style>" + css + "</style>");
    } else {
        qDebug() << "Warning: CSS no encontrado, usando template sin estilos embebidos";
    }

    // 3. Embeber imágenes como base64 (para multiplataforma y standalone)
    QStringList imgNames = {"lectura.png", "mate.png", "sociales.png", "naturales.png", "ingles.png", "trophy-1.png", "logo_completo.png"};
    for (const QString& name : imgNames) {
        QString path = ":/qt/qml/DPMS_Gestor_PreICFES/src/templates/assets/" + name;
        if (!QFile::exists(path)) path = ":/qt/qml/DPMS_Gestor_PreICFES/qml/icons/" + name;

        QFile imgFile(path);
        if (imgFile.open(QIODevice::ReadOnly)) {
            QByteArray base64 = imgFile.readAll().toBase64();
            html.replace(QRegularExpression("src=\"\\S*" + name + "\""), QString("src=\"data:image/png;base64,%1\"").arg(QString::fromLatin1(base64)));
        } else {
            qDebug() << "Warning: Imagen no encontrada:" << name;
        }
    }

    // 4. Reemplazos básicos (datos generales)
    html.replace("{{studentName}}", QString::fromStdString(data.studentName));
    html.replace("{{identification}}",  QString::fromStdString(data.identification));
    html.replace("{{school}}",          QString::fromStdString(data.school));
    html.replace("{{simulacroName}}", QString::fromStdString(data.simulacroName));
    html.replace("{{fechaAplicacion}}", QString::fromStdString(data.fechaAplicacion));
    html.replace("{{puntajeGlobal}}", QString::number(data.puntajeGlobal));
    html.replace("{{percentilGlobal}}", QString::number(data.percentilGlobal));

    // 5. Generar dinámicamente la barra de percentil global
    QString percentilBarHtml = generatePercentilBar(data.percentilGlobal, true);  // true para barra global (color #c78a1f)
    html.replace("{{percentilBar}}", percentilBarHtml);

    // 6. Generar las 5 materias dinámicas (orden fijo)
    QStringList materiaKeys = {"lectura", "mate", "sociales", "naturales", "ingles"};
    QStringList materiaNames = {"Lectura Crítica", "Matemáticas", "Sociales y Ciudadanas", "Ciencias Naturales", "Inglés"};
    QStringList materiaIconPaths = {"lectura.png", "mate.png", "sociales.png", "naturales.png", "ingles.png"};

    for (int i = 0; i < 5; ++i) {
        const SimulacrumService::MateriaData& mat = data.materias[i];
        QString prefix = materiaKeys[i];

        html.replace("{{" + prefix + "Aciertos}}", QString::number(mat.porcentaje));
        html.replace("{{" + prefix + "Percentil}}", QString::number(mat.percentil));
        html.replace("{{" + prefix + "MiniBar}}", generatePercentilBar(mat.percentil, false));  // false para mini-barra (color #494949)
        html.replace("{{" + prefix + "NivelGrafico}}", generateNivelGrafico(mat.nivelStr, mat.nombre == "Inglés"));
        html.replace("{{" + prefix + "Habilidades}}", generateHabilidadesList(mat.habilidades));
    }

    return html;
}

// Función auxiliar para generar HTML de barra de percentil (global o mini)
QString SimulacrumController::generatePercentilBar(int percentil, bool isGlobal) {
    QString barClass = isGlobal ? "percentil-bar" : "mini-bar";
    QString segmentClass = isGlobal ? "percentil-segment" : "mini-segment";
    QString filledColor = isGlobal ? "#c78a1f" : "#494949";

    QString html = "";
    int fullSegments = percentil / 20;
    int partialPercent = (percentil % 20) * 5;  // % para el parcial (20% per segment → 5 units)


    for (int seg = 0; seg < 5; ++seg) {
        if (seg < fullSegments) {
            html += QString("<div class=\"%1 filled\"></div>").arg(segmentClass);
        } else if (seg == fullSegments && partialPercent > 0) {
            html += QString("<div class=\"%1 partial\" style=\"--fill-percent: %2%\"></div>").arg(segmentClass).arg(partialPercent);
            qDebug() << QString("<div class=\"%1 partial\" style=\"--fill-percent: %2%\"></div>").arg(segmentClass).arg(partialPercent) << "partialPercent" << partialPercent << " ;percentil: " << percentil << "; isGlobal: " << isGlobal;
        } else {
            html += QString("<div class=\"%1\"></div>").arg(segmentClass);
        }
    }

    return html;
}

// Función auxiliar para generar HTML de nivel gráfico (con mapeo para Inglés)
QString SimulacrumController::generateNivelGrafico(const std::string& nivelStr, bool isIngles) {
    QString html = "";

    QStringList labels;
    if (isIngles) {
        labels = {"A-", "A1", "A2", "B1"};
    } else {
        labels = {"1", "2", "3", "4"};
    }

    int nivelNum = 1;
    if (isIngles) {
        if (nivelStr == "B1") nivelNum = 4;
        else if (nivelStr == "A2") nivelNum = 3;
        else if (nivelStr == "A1") nivelNum = 2;
        else if (nivelStr == "A-") nivelNum = 1;
    } else {
        nivelNum = std::stoi(nivelStr);
    }

    for (int i = 1; i <= 4; ++i) {
        bool activo = (i == nivelNum);
        int numSegmentos = i;  // 1 segmento para nivel 1, 4 para 4
        QString segmentosHtml = "";

        for (int seg = 0; seg < numSegmentos; ++seg) {
            segmentosHtml += "<div class=\"nivel-segmento\"></div>";
        }

        html += QString("<div class=\"nivel-barra%1\">%2<div class=\"nivel-etiqueta\">%3</div></div>").arg(activo ? " activo" : "").arg(segmentosHtml).arg(labels[i-1]);
    }

    return html;
}

// Función auxiliar para generar HTML de lista de habilidades
QString SimulacrumController::generateHabilidadesList(const std::vector<std::string>& habilidades) {
    QString html = "";
    for (const auto& hab : habilidades) {
        html += QString("<li>%1</li>").arg(QString::fromStdString(hab));
    }
    return html;
}

bool SimulacrumController::generatePdfFromHtml(const QString& html, const QString& pdfPath) {
    qDebug() << "[PDF] Iniciando generación:" << pdfPath;

    // SEGURIDAD: No permitir generaciones concurrentes
    if (m_pdfState.isProcessing) {
        qWarning() << "[PDF] Ya hay una generación en curso, esperando...";
        QThread::msleep(100);  // Espera breve
        if (m_pdfState.isProcessing) {
            qCritical() << "[PDF] ERROR: Sistema ocupado";
            return false;
        }
    }

    // Marcar como en proceso
    m_pdfState.isProcessing = true;
    m_pdfState.targetPath = pdfPath;
    m_pdfState.lastResult = false;

    // Crear view si no existe (se reutiliza pero de forma segura)
    if (!m_pdfView) {
        qDebug() << "[PDF] Creando QWebEngineView reutilizable";
        m_pdfView = new QWebEngineView();
        m_pdfView->setAttribute(Qt::WA_DontShowOnScreen);
        m_pdfView->setFixedSize(794, 2246);

        // Conexiones permanentes
        connect(m_pdfView->page(), &QWebEnginePage::pdfPrintingFinished,
                this, &SimulacrumController::onPdfPrintingFinished);
        connect(m_pdfView->page(), &QWebEnginePage::loadFinished,
                this, &SimulacrumController::onHtmlLoadFinished);
    }

    // Crear event loop LOCAL para esta llamada
    QEventLoop localLoop;
    m_pdfState.eventLoop = &localLoop;

    // Conexión TEMPORAL para saber cuándo terminó
    QMetaObject::Connection completionConn = connect(
        this, &SimulacrumController::pdfGenerationCompleted,
        &localLoop, &QEventLoop::quit
        );

    // Iniciar carga del HTML
    qDebug() << "[PDF] Cargando HTML...";
    m_pdfView->setHtml(html, QUrl("qrc:/"));

    // ESPERAR hasta que termine (con timeout de seguridad)
    QTimer::singleShot(30000, &localLoop, &QEventLoop::quit);  // 30 seg timeout
    localLoop.exec();

    // Limpiar
    disconnect(completionConn);
    m_pdfState.eventLoop = nullptr;

    bool success = m_pdfState.lastResult;
    m_pdfState.isProcessing = false;

    qDebug() << "[PDF] Generación finalizada:" << success
             << "- Archivo:" << (QFile::exists(pdfPath) ? "existe" : "NO existe")
             << "- Tamaño:" << QFileInfo(pdfPath).size() << "bytes";

    return success;
}

void SimulacrumController::onHtmlLoadFinished(bool ok) {
    if (!m_pdfState.isProcessing) {
        qDebug() << "[PDF] Load finished pero no hay proceso activo (ignorando)";
        return;
    }

    if (!ok) {
        qCritical() << "[PDF] ERROR al cargar HTML";
        m_pdfState.lastResult = false;
        emit pdfGenerationCompleted(false, m_pdfState.targetPath);
        return;
    }

    qDebug() << "[PDF] HTML cargado OK, iniciando impresión...";

    // Pequeño delay para asegurar que el rendering está completo
    QTimer::singleShot(150, this, [this]() {
        // Configurar layout
        QPageLayout layout(
            QPageSize(QPageSize::A4),
            QPageLayout::Portrait,
            QMarginsF(15, 15, 15, 15),
            QPageLayout::Millimeter
            );

        // Iniciar generación del PDF (asíncrono)
        qDebug() << "[PDF] Ejecutando printToPdf...";
        m_pdfView->page()->printToPdf(m_pdfState.targetPath, layout);
    });
}

void SimulacrumController::onPdfPrintingFinished(const QString& filePath, bool success) {
    if (!m_pdfState.isProcessing) {
        qDebug() << "[PDF] Printing finished pero no hay proceso activo (ignorando)";
        return;
    }

    qDebug() << "[PDF] Impresión completada:" << filePath << "- Success:" << success;

    // Verificar que el archivo existe y no está vacío
    bool fileValid = success
                     && QFile::exists(filePath)
                     && QFileInfo(filePath).size() > 1000;  // Al menos 1KB

    if (!fileValid && success) {
        qWarning() << "[PDF] El archivo se reportó exitoso pero está vacío o no existe";
    }

    m_pdfState.lastResult = fileValid;

    // Emitir señal de completado (esto despertará el event loop)
    emit pdfGenerationCompleted(fileValid, filePath);
}

// Función para generar y abrir PDF de un solo resultado
bool SimulacrumController::generateAndOpenBoletinPdf(int simId, int studentId) {
    auto data = SimulacrumService::intance().getBoletinData(simId, studentId);
    if (data.materias.size() != 5) return false;

    QString html = buildHtmlFromData(data);
    if (html.isEmpty()) return false;

    QString safeName = QString::fromStdString(data.studentName).replace(" ", "_");
    safeName.remove(QRegularExpression("[^a-zA-Z0-9_]"));

    QString defaultPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation) + "/Boletin_" + safeName + ".pdf";
    QString pdfPath = QFileDialog::getSaveFileName(nullptr, "Guardar Boletín", defaultPath, "PDF (*.pdf)");

    if (pdfPath.isEmpty()) return false;

    bool success = generatePdfFromHtml(html, pdfPath);
    if (success) {
        QDesktopServices::openUrl(QUrl::fromLocalFile(pdfPath));
    }

    return success;
}

// Versión auxiliar SIN diálogo (para usar en bucle)
bool SimulacrumController::generateBoletinToPath(int simId, int studentId, const QString& pdfPath) {
    auto data = SimulacrumService::intance().getBoletinData(simId, studentId);
    if (data.materias.size() != 5) return false;

    QString html = buildHtmlFromData(data);
    if (html.isEmpty()) return false;

    return generatePdfFromHtml(html, pdfPath);
}

// Función para crear ZIP usando comandos nativos del sistema
bool SimulacrumController::createZipFromFolder(const QString& sourceFolder, const QString& zipFilePath) {
    QProcess process;
    QString program;
    QStringList args;

#ifdef Q_OS_WIN
    program = "powershell.exe";
    QString escapedFolder = QDir::toNativeSeparators(sourceFolder).replace("\\", "\\\\").replace("'", "''");
    QString escapedZip = QDir::toNativeSeparators(zipFilePath).replace("\\", "\\\\").replace("'", "''");
    QString psCmd = QString("Compress-Archive -Path '%1\\*' -DestinationPath '%2' -Force")
                        .arg(escapedFolder)
                        .arg(escapedZip);
    args << "-NoProfile" << "-ExecutionPolicy" << "Bypass" << "-Command" << psCmd;
#else
    // Linux y macOS
    program = "zip";
    args << "-r" << "-j" << zipFilePath << sourceFolder;
#endif

    qDebug() << "Ejecutando ZIP:" << program << args.join(" ");

    process.start(program, args);
    process.waitForFinished(-1);

    if (process.exitCode() != 0) {
        QString errOutput = process.readAllStandardError();
        qDebug() << "Fallo al crear ZIP - código:" << process.exitCode() << "Error:" << errOutput;
        return false;
    }

    return QFile::exists(zipFilePath);
}


bool SimulacrumController::exportAllBoletines(int simId) {
    auto results = getFullResultsList(simId);
    if (results.isEmpty()) {
        qDebug() << "[EXPORT] No hay resultados para exportar";
        return false;
    }

    auto simData = getSimulacrumData(simId);
    QString simName = simData.value("name").toString();

    QString defaultZip = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation) +
                         "/Boletines_Simulacro_" + simName + ".zip";

    QString zipPath = QFileDialog::getSaveFileName(nullptr,
                                                   "Guardar todos los boletines como ZIP",
                                                   defaultZip,
                                                   "Archivo ZIP (*.zip)");

    if (zipPath.isEmpty()) {
        qDebug() << "[EXPORT] Usuario canceló";
        return false;
    }

    QTemporaryDir tempDir;
    if (!tempDir.isValid()) {
        qCritical() << "[EXPORT] No se pudo crear carpeta temporal";
        return false;
    }
    QString tempFolder = tempDir.path();

    // Diálogo de progreso mejorado
    QProgressDialog progress("Generando boletines...", "Cancelar", 0, results.size());
    progress.setWindowModality(Qt::ApplicationModal);
    progress.setMinimumDuration(0);
    progress.setWindowTitle("Exportando Boletines");

    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < results.size(); ++i) {
        if (progress.wasCanceled()) {
            qDebug() << "[EXPORT] Cancelado por usuario en" << i << "de" << results.size();
            break;
        }

        QVariantMap res = results[i].toMap();
        int studentId = res["studentId"].toInt();
        QString studentName = res["studentName"].toString();

        progress.setLabelText(QString("Generando boletín %1 de %2\n%3")
                                  .arg(i + 1)
                                  .arg(results.size())
                                  .arg(studentName));

        QString safeName = studentName
                               .replace(" ", "_")
                               .remove(QRegularExpression("[^a-zA-Z0-9_-]"));

        QString pdfPath = tempFolder + "/Boletin_" + safeName + ".pdf";

        qDebug() << "[EXPORT]" << (i+1) << "/" << results.size() << "-" << studentName;

        // CLAVE: Procesar eventos ANTES de generar el PDF
        QCoreApplication::processEvents();

        // Generar PDF (bloqueante pero seguro)
        bool generated = generateBoletinToPath(simId, studentId, pdfPath);

        if (generated) {
            successCount++;
            qDebug() << "[EXPORT] ✓ OK -" << studentName;
        } else {
            failCount++;
            qWarning() << "[EXPORT] ✗ FAIL -" << studentName;
        }

        // Actualizar progreso
        progress.setValue(i + 1);

        // IMPORTANTE: Procesar eventos DESPUÉS también
        QCoreApplication::processEvents();

        // Pequeña pausa entre PDFs para evitar sobrecarga
        QThread::msleep(50);
    }

    progress.close();

    qDebug() << "[EXPORT] Resumen - Exitosos:" << successCount << "- Fallidos:" << failCount;

    if (successCount == 0) {
        qCritical() << "[EXPORT] No se generó ningún boletín";
        return false;
    }

    // Crear ZIP
    qDebug() << "[EXPORT] Comprimiendo" << successCount << "archivos...";
    bool zipSuccess = createZipFromFolder(tempFolder, zipPath);

    if (zipSuccess) {
        qDebug() << "[EXPORT] ✓ ZIP creado exitosamente:" << zipPath;
        QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(zipPath).absolutePath()));
        return true;
    } else {
        qWarning() << "[EXPORT] No se pudo crear ZIP, usando fallback...";

        // FALLBACK: Carpeta suelta
        QString fallbackFolder = QFileDialog::getExistingDirectory(
            nullptr,
            "No se pudo crear el ZIP. Guarda los boletines en una carpeta",
            QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)
            );

        if (!fallbackFolder.isEmpty()) {
            QDir temp(tempFolder);
            QStringList files = temp.entryList(QDir::Files);
            int copied = 0;

            for (const QString& file : files) {
                QString sourcePath = tempFolder + "/" + file;
                QString destPath = fallbackFolder + "/" + file;

                if (QFile::copy(sourcePath, destPath)) {
                    copied++;
                } else {
                    qWarning() << "[EXPORT] No se pudo copiar:" << file;
                }
            }

            qDebug() << "[EXPORT]" << copied << "archivos copiados a" << fallbackFolder;
            QDesktopServices::openUrl(QUrl::fromLocalFile(fallbackFolder));
            return copied > 0;
        }

        return false;
    }
}

SimulacrumController::~SimulacrumController() {
    if (m_pdfState.isProcessing) {
        qDebug() << "[PDF] Esperando generación en destructor...";
        QEventLoop waitLoop;

        QMetaObject::Connection conn = connect(
            this, &SimulacrumController::pdfGenerationCompleted,
            &waitLoop, &QEventLoop::quit
            );

        QTimer::singleShot(2000, &waitLoop, &QEventLoop::quit);  // ← 2 seg es suficiente
        waitLoop.exec();

        disconnect(conn);  // ← Limpiar conexión
    }

    if (m_pdfView) {
        qDebug() << "[PDF] Liberando QWebEngineView";
        disconnect(m_pdfView, nullptr, this, nullptr);  // ← Desconectar TODAS las señales
        m_pdfView->deleteLater();
        m_pdfView = nullptr;
    }
}
