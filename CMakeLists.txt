cmake_minimum_required(VERSION 3.16)

project(DPMS_Gestor_PreICFES VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS
    Quick
    Sql
    Charts
    Widgets
    Svg
    PrintSupport
    WebEngineWidgets
    QuickControls2
)

qt_standard_project_setup(REQUIRES 6.8)

if (WIN32)
    set(APP_ICON_RESOURCE_WINDOWS
        ${CMAKE_CURRENT_SOURCE_DIR}/appicon.rc
    )
endif()

set(PROJECT_SOURCES
    main.cpp
    src/domain/student.h
    src/domain/result.h
    src/domain/booklet.h
    src/domain/simulacrum.h
    src/application/simulacrum_service.h
    src/presentation/simulacrum_controller.h
    src/infraestructure/database_manager.h
    src/presentation/simulacrum_controller.cpp
)



qt_add_executable(appDPMS_Gestor_PreICFES
    ${PROJECT_SOURCES}
    resources.qrc
    ${APP_ICON_RESOURCE_WINDOWS}
)


qt_add_qml_module(appDPMS_Gestor_PreICFES
    URI DPMS_Gestor_PreICFES
    QML_FILES
        qml/Main.qml
        qml/views/DashboardView.qml
        qml/views/SimulacrumView.qml
        qml/components/Sidebar.qml
        qml/components/NavButton.qml
        qml/components/SimulcrumCard.qml
        qml/views/SimulacrumDetailView.qml
        qml/components/SimulacrumWizard.qml
        qml/components/ResultPopup.qml
        qml/components/SubjectInput.qml
        qml/components/ResultRow.qml
        qml/components/SimulacrumDeleteDialog.qml
        qml/views/SimulacrumStatsView.qml
        qml/components/TableTopList.qml
        qml/components/CustomAlert.qml
        qml/components/DatePicker.qml
        qml/views/StudentsView.qml
        qml/components/StudentRow.qml
        qml/components/StudentDetailPopup.qml
        qml/components/StudentWizarad.qml
        qml/views/ConfigView.qml
        qml/components/SimulacrumRow.qml
        qml/components/BoletinConfirmDialog.qml
        qml/components/ExportAllBoletinesDialog.qml
    RESOURCES
        src/templates/boletin.html
        src/templates/stylesheet.css
        src/templates/assets/ingles.png
        src/templates/assets/lectura.png
        src/templates/assets/mate.png
        src/templates/assets/naturales.png
        src/templates/assets/sociales.png
        src/templates/assets/trophy-1.png
        qml/icons/book.svg
        qml/icons/home.svg
        qml/icons/student.svg
        qml/icons/wheel.svg
        qml/icons/book-purple.svg
        qml/icons/home-purple.svg
        qml/icons/student-purple.svg
        qml/icons/wheel-purple.svg
        qml/icons/logo.png
        qml/icons/dpsm_logo.png
        qml/icons/logo_completo.png
        qml/icons/logo-icon.png
        qml/icons/avatar.svg
        qml/icons/simulacrum-icon.svg
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appDPMS_Gestor_PreICFES PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appDPMS_Gestor_PreICFES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appDPMS_Gestor_PreICFES
    PRIVATE
    Qt6::Quick
    Qt6::Sql
    Qt6::Charts
    Qt6::Widgets
    Qt6::Svg
    Qt6::PrintSupport
    Qt6::WebEngineWidgets
    Qt6::QuickControls2
)

target_include_directories(appDPMS_Gestor_PreICFES PRIVATE
    src/domain
    src/presentation
    src/application
    src/infraestructure
)

include(GNUInstallDirs)
install(TARGETS appDPMS_Gestor_PreICFES
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
