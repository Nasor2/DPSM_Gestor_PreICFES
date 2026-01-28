#ifndef SIMULACRUMCONTROLLER_H
#define SIMULACRUMCONTROLLER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QStringList>
#include <QDebug>
#include <QDate>
#include <qeventloop.h>
#include <qwebengineview.h>
#include <simulacrum_service.h>

class SimulacrumController : public QObject {
    Q_OBJECT

public:
    explicit SimulacrumController(QObject *parent = nullptr);
    ~SimulacrumController();

    // --- Funciones de Simulacros ---
    Q_INVOKABLE int createSimulacrum(QString name, QString date, int bookletId);
    Q_INVOKABLE QVariantList getSimulacrumList();
    Q_INVOKABLE QVariantMap createFullSimulacrum(QString simName, QString date, QString bName, int l, int m, int s, int n, int i);
    Q_INVOKABLE QVariantMap getSimulacrumData(int simId);
    Q_INVOKABLE QVariantMap updateFullSimulacrum(int simId, QString simName, QString date, QString bName, int l, int m, int s, int n, int i);
    Q_INVOKABLE QVariantMap deleteFullSimulacrum(int simId);
    Q_INVOKABLE QVariantMap getSimulacrumStats(int simId);

    // --- Funciones de Resultados ---
    Q_INVOKABLE QVariantMap addResult(int simId, QString studentName, int l, int m, int s, int n, int i);
    Q_INVOKABLE QVariantList getDetailedResults(int simId);
    Q_INVOKABLE QVariantList getFullResultsList(int simId);
    Q_INVOKABLE QVariantMap updateStudentResult(int simId, QString studentName, int l, int m, int s, int n, int i);
    Q_INVOKABLE bool deleteResult(int simId, QString studentName);

    // --- Funciones de Estudiantes ---
    Q_INVOKABLE QStringList getStudentSuggestions();
    Q_INVOKABLE QVariantList getStudentsList();
    Q_INVOKABLE QVariantMap updateStudent(int id, QString newName);
    Q_INVOKABLE QVariantMap deleteStudent(int id);
    Q_INVOKABLE QVariantList getStudentSimulacra(int studentId);
    Q_INVOKABLE QVariantMap getStudentInfo(int studentId);
    Q_INVOKABLE QVariantList getStudentSimulacraWithScores(int studentId);
    QString formatStudentName(const QString& rawName);

    // --- Dashboards y Estadísticas ---
    Q_INVOKABLE QVariantList getEvolutionGraphData();
    Q_INVOKABLE QVariantMap getGlobalDistributionData();
    Q_INVOKABLE QVariantList getTopStudentsGlobal();
    Q_INVOKABLE double getGlobalAverageScore();

    // --- Utilidades (PDF y DB) ---
    Q_INVOKABLE QVariantMap getBookletData(int bookletId);
    Q_INVOKABLE QVariantMap exportDatabase();
    Q_INVOKABLE QVariantMap importDatabase(QString filePath);

    // PDF
    Q_INVOKABLE bool generateAndOpenBoletinPdf(int simId, int studentId);
    Q_INVOKABLE bool generatePdfFromHtml(const QString& html, const QString& pdfPath);
    Q_INVOKABLE QString generateHabilidadesList(const std::vector<std::string>& habilidades);
    Q_INVOKABLE QString generateNivelGrafico(const std::string& nivelStr, bool isIngles);
    Q_INVOKABLE QString generatePercentilBar(int percentil, bool isGlobal);
    Q_INVOKABLE QString buildHtmlFromData(const SimulacrumService::BoletinData& data);
    Q_INVOKABLE bool exportAllBoletines(int simId);

    bool generateBoletinToPath(int simId, int studentId, const QString& pdfPath);
    bool createZipFromFolder(const QString& sourceFolder, const QString& zipFilePath);

signals:
    void pdfGenerationCompleted(bool success, QString path);

private slots:
    void onPdfPrintingFinished(const QString& filePath, bool success);
    void onHtmlLoadFinished(bool ok);

private:
    QWebEngineView* m_pdfView = nullptr;

    // Estado de la generación actual
    struct PdfGenerationState {
        QString targetPath;
        QEventLoop* eventLoop = nullptr;
        bool isProcessing = false;
        bool lastResult = false;
    } m_pdfState;
};

#endif // SIMULACRUMCONTROLLER_H
