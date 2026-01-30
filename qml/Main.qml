import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "views"
import "icons"

Window {
    id: root
    width: 1250
    height: 800
    visible: true
    title: "DPSM Gestor PreICFES"
    color: "#F4F7F9"

    readonly property color colorPrimary: "#254FDA"
    readonly property color colorSidebar: "#FFFFFF"
    readonly property color colorTextMain: "#2D3748"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // --- SIDEBAR ---
        Rectangle {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: 240
            color: root.colorSidebar

            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: "#E2E8F0"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 30
                anchors.bottomMargin: 20
                spacing: 0

                /* Logo superior (icono)
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    Layout.topMargin: 10
                    Layout.bottomMargin: 20

                    Image {
                        anchors.centerIn: parent
                        width: 65
                        height: 65
                        source: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/logo-icon.png"   // ← tu PNG cuadrado
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        antialiasing: true
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 85
                    Layout.bottomMargin: 15

                    Image {
                        id: mainLogo
                        anchors.centerIn: parent
                        width: parent.width - 20  // Casi todo el ancho (220px)
                        height: width / 5.05
                        source: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/logo_completo.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        antialiasing: true
                    }
                }*/


                // Botones de Navegación
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    NavButton {
                        text: "Inicio"
                        iconSource: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/home.svg"
                        iconSourceActive: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/home-purple.svg"
                        isActive: mainStack.currentItem && mainStack.currentItem.objectName === "dashboard"
                        activeColor: root.colorPrimary
                        onClicked: {
                            if (!mainStack.currentItem || mainStack.currentItem.objectName !== "dashboard") {
                                mainStack.replace(null, dashboardComponent)
                            }
                        }
                    }

                    NavButton {
                        text: "Simulacros"
                        iconSource: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/book.svg"
                        iconSourceActive: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/book-purple.svg"
                        isActive: mainStack.currentItem && (mainStack.currentItem.objectName === "simulacros" || mainStack.currentItem.objectName === "simulacro_detalle")
                        activeColor: "#0888A9"
                        onClicked: {
                            if (!mainStack.currentItem || (mainStack.currentItem.objectName !== "simulacros" && mainStack.currentItem.objectName !== "simulacro_detalle")) {
                                mainStack.replace(null, simulacrosViewComponent)
                            } else if (mainStack.currentItem.objectName === "simulacro_detalle") {
                                mainStack.pop()
                            }

                            if (mainStack.currentItem && mainStack.currentItem.refreshData) {
                                mainStack.currentItem.refreshData()
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 30 }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 30
                        Layout.rightMargin: 30
                        height: 1
                        color: "#E2E8F0"
                    }

                    Item { Layout.preferredHeight: 10 }

                    Text {
                        text: "SISTEMA"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#A0AEC0"
                        Layout.leftMargin: 30
                    }

                    Item { Layout.preferredHeight: 6 }

                    NavButton {
                        text: "Estudiantes"
                        iconSource: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/student.svg"
                        iconSourceActive: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/student-purple.svg"
                        isActive: mainStack.currentItem && mainStack.currentItem.objectName === "estudiantes"
                        activeColor: "#08A929"
                        onClicked: {
                            if (!mainStack.currentItem || mainStack.currentItem.objectName !== "estudiantes") {
                                mainStack.replace(null, estudiantesComponent)
                            }
                        }
                    }

                    NavButton {
                        text: "Configuración"
                        iconSource: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/wheel.svg"
                        iconSourceActive: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/wheel-purple.svg"
                        isActive: mainStack.currentItem && mainStack.currentItem.objectName === "config"
                        activeColor: "#2908A9"
                        onClicked: {
                            if (!mainStack.currentItem || mainStack.currentItem.objectName !== "config") {
                                mainStack.replace(null, configComponent)
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                //footer
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 85
                    Layout.bottomMargin: 15

                    Image {
                        id: mainLogo
                        anchors.centerIn: parent
                        width: parent.width - 20  // Casi todo el ancho (220px)
                        height: width / 5.05
                        source: "qrc:/qt/qml/DPMS_Gestor_PreICFES/qml/icons/logo_completo.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        antialiasing: true
                    }
                }

            }
        }

        // --- CONTENIDO PRINCIPAL ---
        ColumnLayout {
            Layout.bottomMargin: 20
            Layout.rightMargin: 20
            Layout.leftMargin: 20
            Layout.topMargin: 30
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 30


            // Área de Trabajo
            StackView {
                id: mainStack
                Layout.fillWidth: true
                Layout.fillHeight: true

                initialItem: DashboardView {
                    objectName: "dashboard"
                    onNavigateToSimulacros: {
                        mainStack.replace(null, simulacrosViewComponent)
                    }
                }

                // Transición para replace (navegación principal)
                replaceEnter: Transition {
                    PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
                    PropertyAnimation { property: "y"; from: 20; to: 0; duration: 250; easing.type: Easing.OutCubic }
                }
                replaceExit: Transition {
                    PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InCubic }
                }

                // Transición para push (entrar a detalle)
                pushEnter: Transition {
                    PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
                    PropertyAnimation { property: "y"; from: 20; to: 0; duration: 250; easing.type: Easing.OutCubic }
                }
                pushExit: Transition {
                    PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InCubic }
                }

                // Transición para pop (volver de detalle)
                popEnter: Transition {
                    PropertyAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
                    PropertyAnimation { property: "y"; from: 20; to: 0; duration: 250; easing.type: Easing.OutCubic }
                }
                popExit: Transition {
                    PropertyAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InCubic }
                }
            }
        }
    }

    // --- COMPONENTES ---
    Component {
        id: dashboardComponent
        DashboardView {
            objectName: "dashboard"
            onNavigateToSimulacros: {
                mainStack.replace(null, simulacrosViewComponent)
            }
        }
    }

    Component {
        id: simulacrosViewComponent
        SimulacrumView {
            objectName: "simulacros"
        }
    }

    Component {
        id: simulacroDetailComponent
        SimulacrumDetailView {
            objectName: "simulacro_detalle"
        }
    }

    Component {
        id: estudiantesComponent
        StudentsView { objectName: "estudiantes" }
    }

    Component {
        id: configComponent
        ConfigView { objectName: "config" }
    }
}
