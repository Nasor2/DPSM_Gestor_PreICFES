#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <src/infraestructure/database_manager.h>
#include <src/presentation/simulacrum_controller.h>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QCoreApplication::setOrganizationName("DPSM");
    QCoreApplication::setApplicationName("Gestor PreICFES");
    QCoreApplication::setApplicationVersion("1.0.0");
    QQuickStyle::setStyle("Fusion");
    app.setWindowIcon(QIcon("qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/logo-icon.png"));

    if (!DatabaseManager::instance().init()){
        return -1;
    }

    SimulacrumController controller;
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("backend", &controller);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("DPMS_Gestor_PreICFES", "Main");

    //controller.testWebEngineCrash();

    return app.exec();
}
