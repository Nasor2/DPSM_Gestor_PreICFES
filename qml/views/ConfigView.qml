// qml/views/ConfigView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

Item {
    id: configRoot
    objectName: "config"

    readonly property color colorPrimary: "#1D0678"
    readonly property color colorSecundary: "#2908A9"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            radius: 20

            gradient: Gradient {
                GradientStop { position: 0.0; color: colorPrimary }
                GradientStop { position: 1.0; color: colorSecundary }
            }

            Rectangle {
                anchors.fill: parent
                radius: 20
                opacity: 0.1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "white" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 35
                spacing: 25

                Rectangle {
                    width: 5;
                    height: 65;
                    radius: 2.5;
                    color: "white";
                    opacity: 0.8
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "Configuración"
                        font.pixelSize: 26
                        font.bold: true
                        color: "white"
                    }
                    Text {
                        text: "Gestiona los datos de tu aplicación"
                        font.pixelSize: 14
                        color: "white"
                        opacity: 0.95
                    }
                }
            }
        }

        Item { Layout.preferredHeight: 30 }

        // Contenedor principal
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: "white"
            border.color: "#E5E7EB"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20

                Text {
                    text: "Gestión de Datos"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#1F2937"
                }

                // Opción Exportar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    radius: 12
                    color: "#F8FAFC"
                    border.color: "#E5E7EB"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 12
                            color: "#EBE7FE"

                            Text {
                                anchors.centerIn: parent
                                text: "📤"
                                font.pixelSize: 28
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Exportar Base de Datos"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#1F2937"
                            }

                            Text {
                                text: "Crea una copia de seguridad en tu carpeta de Descargas"
                                font.pixelSize: 13
                                color: "#6B7280"
                                wrapMode: Text.WordWrap
                            }
                        }

                        Button {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 44
                            text: "Exportar"

                            background: Rectangle {
                                radius: 10
                                color: parent.hovered ? colorPrimary : colorSecundary
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            HoverHandler { cursorShape: Qt.PointingHandCursor }

                            onClicked: {
                                var response = backend.exportDatabase()
                                if (response.success) {
                                    configAlert.showAlert("Exportado",
                                        "Base de datos guardada en:\n" + response.path,
                                        "success")
                                } else {
                                    configAlert.showAlert("Error", response.message, "error")
                                }
                            }
                        }
                    }
                }

                // Opción Importar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    radius: 12
                    color: "#F8FAFC"
                    border.color: "#E5E7EB"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 12
                            color: "#EFFBBB"

                            Text {
                                anchors.centerIn: parent
                                text: "📥"
                                font.pixelSize: 28
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Importar Base de Datos"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#1F2937"
                            }

                            Text {
                                text: "Restaura los datos desde un archivo de respaldo (se creará backup automático)"
                                font.pixelSize: 13
                                color: "#6B7280"
                                wrapMode: Text.WordWrap
                            }
                        }

                        Button {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 44
                            text: "Importar"

                            background: Rectangle {
                                radius: 10
                                color: parent.hovered ? "#617806" : "#88A908"
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            HoverHandler { cursorShape: Qt.PointingHandCursor }

                            onClicked: fileDialog.open()
                        }
                    }
                }

                // Warning
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    radius: 10
                    color: "#FEF2F2"
                    border.color: "#FEE2E2"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        anchors.centerIn: parent
                        spacing: 12

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 8
                            color: "#FEE2E2"

                            Text {
                                anchors.centerIn: parent
                                text: "⚠"
                                font.pixelSize: 20
                                color: "#DC2626"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Al importar, se reemplazarán todos los datos actuales. Se creará un backup automático de seguridad."
                            font.pixelSize: 14
                            color: "#991B1B"
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    // File Dialog para importar
    FileDialog {
        id: fileDialog
        title: "Seleccionar archivo de base de datos"
        nameFilters: ["Database files (*.db)", "All files (*)"]
        fileMode: FileDialog.OpenFile

        onAccepted: {
            var filePath = fileDialog.selectedFile.toString()
            // Remover el prefijo "file:///" en Windows o "file://" en otros
            if (Qt.platform.os === "windows") {
                filePath = filePath.replace(/^file:\/\/\//, "")
            } else {
                filePath = filePath.replace(/^file:\/\//, "")
            }

            importConfirmDialog.importPath = filePath
            importConfirmDialog.open()
        }
    }

    // Confirmación de importación
    Popup {
        id: importConfirmDialog
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: Math.min(parent.width * 0.92, 440)
        height: Math.min(parent.height * 0.40, 320)
        modal: true
        focus: true
        padding: 0

        property string importPath: ""

        background: Rectangle {
            color: "white"
            radius: 16
            border.color: "#E2E8F0"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                color: "#88A908"
                radius: 16

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.radius
                    color: parent.color
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    spacing: 12

                    Rectangle {
                        width: 4
                        height: 50
                        radius: 2
                        color: "white"
                        opacity: 0.8
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "¿Confirmar Importación?"
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }

                    Button {
                        implicitWidth: 32
                        implicitHeight: 32
                        text: "✕"
                        onClicked: importConfirmDialog.close()

                        background: Rectangle {
                            radius: 8
                            color: "transparent"
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                    }
                }
            }

            // Content
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Text {
                        Layout.fillWidth: true
                        text: "Se reemplazarán todos los datos actuales. Esta acción creará un backup automático de tu base de datos actual."
                        font.pixelSize: 14
                        color: "#6B7280"
                        wrapMode: Text.WordWrap
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // Footer
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                color: "#F7FAFC"
                radius: 16

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: parent.radius
                    color: parent.color
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        text: "Cancelar"
                        onClicked: importConfirmDialog.close()

                        background: Rectangle {
                            radius: 10
                            color: parent.hovered ? "#F1F5F9" : "white"
                            border.color: "#E2E8F0"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            font.bold: true
                            color: "#64748B"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        text: "Sí, Importar"

                        background: Rectangle {
                            radius: 10
                            color: parent.hovered ? "#617806" : "#88A908"
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        HoverHandler { cursorShape: Qt.PointingHandCursor }

                        onClicked: {
                            importConfirmDialog.close()
                            var response = backend.importDatabase(importConfirmDialog.importPath)
                            if (response.success) {
                                configAlert.showAlert("Importado",
                                    response.message,
                                    "success")
                            } else {
                                configAlert.showAlert("Error", response.message, "error")
                            }
                        }
                    }
                }
            }
        }
    }

    CustomAlert {
        id: configAlert
        anchors.centerIn: parent
        z: 3
    }
}
