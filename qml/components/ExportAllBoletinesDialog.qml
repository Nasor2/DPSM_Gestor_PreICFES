// components/ExportAllBoletinesDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: control

    property int totalResults: 0
    property int simulacroId: -1
    property var alertSystem: null

    signal exportRequested(bool incluirPercentiles)

    width: Math.min(parent.width * 0.92, 580)
    height: Math.min(parent.height * 0.88, 720)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2 - parent.height * 0.02

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    Overlay.modal: Rectangle {
        color: "#80000000"
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 200
        }
        NumberAnimation {
            property: "scale"
            from: 0.92
            to: 1
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            to: 0
            duration: 150
        }
    }

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
            Layout.preferredHeight: 100
            color: "#0888A9"
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
                anchors.leftMargin: 28
                anchors.rightMargin: 24
                spacing: 15

                Rectangle {
                    width: 4
                    height: 60
                    radius: 2
                    color: "white"
                    opacity: 0.8
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Exportar Todos los Boletines"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                    }

                    Text {
                        text: control.totalResults + " boletín" + (control.totalResults !== 1 ? "es" : "") + " se generarán"
                        font.pixelSize: 14
                        color: "white"
                        font.weight: Font.Medium
                    }
                }

                Button {
                    implicitWidth: 36
                    implicitHeight: 36
                    text: "✕"
                    onClicked: control.close()

                    background: Rectangle {
                        radius: 8
                        color: "transparent"
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 20
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // Content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            leftPadding: 0
            rightPadding: 0

            ColumnLayout {
                width: control.width
                spacing: 20

                Item {
                    height: 10
                }

                // Info card - Percentiles
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 28
                    Layout.rightMargin: 28
                    Layout.preferredHeight: infoColumn.implicitHeight + 32
                    radius: 12
                    color: "#FFFBEB"
                    border.color: "#FDE68A"
                    border.width: 1

                    ColumnLayout {
                        id: infoColumn
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        RowLayout {
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 8
                                color: "#FEF3C7"

                                Text {
                                    anchors.centerIn: parent
                                    text: "i"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#D97706"
                                }
                            }

                            Text {
                                text: "Sobre los Percentiles"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#92400E"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.leftMargin: 52
                            text: "Los percentiles se calculan comparando cada estudiante con TODOS los demás del simulacro. Si hay pocos resultados, los valores pueden no ser representativos."
                            font.pixelSize: 13
                            color: "#78350F"
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }
                    }
                }

                // Warning card - Resultados incompletos
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 28
                    Layout.rightMargin: 28
                    Layout.preferredHeight: warningColumn.implicitHeight + 32
                    radius: 12
                    color: "#FEF2F2"
                    border.color: "#FECACA"
                    border.width: 1
                    visible: control.totalResults < 10 && control.totalResults > 0

                    ColumnLayout {
                        id: warningColumn
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        RowLayout {
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 8
                                color: "#FEE2E2"

                                Text {
                                    anchors.centerIn: parent
                                    text: "!"
                                    font.pixelSize: 22
                                    font.bold: true
                                    color: "#DC2626"
                                }
                            }

                            Text {
                                text: "Pocos Resultados Registrados"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#991B1B"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.leftMargin: 52
                            text: "Solo hay " + control.totalResults + " resultado" + (control.totalResults !== 1 ? "s" : "") + ". Se recomienda tener al menos 10 para percentiles más precisos."
                            font.pixelSize: 13
                            color: "#7F1D1D"
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }
                    }
                }

                // Card de resumen
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 28
                    Layout.rightMargin: 28
                    Layout.preferredHeight: contentColumn.implicitHeight + 32
                    radius: 12
                    color: "#E7F9FE"
                    border.color: "#E2E8F0"
                    border.width: 1

                    ColumnLayout {
                        id: contentColumn
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 18

                        RowLayout {
                            spacing: 10

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 8
                                color: "#BBEFFC"

                                Text {
                                    anchors.centerIn: parent
                                    text: "Z"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#0888A9"
                                }
                            }

                            Text {
                                text: "Se generará un archivo ZIP con:"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#1F2937"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 42
                            spacing: 14

                            Repeater {
                                model: [
                                    { icon: "F", text: control.totalResults + " boletines individuales (PDF)" },
                                    { icon: "G", text: "Puntaje global y percentiles" },
                                    { icon: "D", text: "Resultados detallados por materia" },
                                    { icon: "N", text: "Nivel de desempeño y habilidades" }
                                ]

                                delegate: RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    Rectangle {
                                        Layout.preferredWidth: 30
                                        Layout.preferredHeight: 30
                                        radius: 7
                                        color: "#BBEFFC"

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.icon
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#0888A9"
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.text
                                        font.pixelSize: 14
                                        color: "#475569"
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    height: 20
                }
            }
        }

        // Footer
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 88
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
                anchors.margins: 28
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: "Cancelar"
                    onClicked: control.close()

                    background: Rectangle {
                        radius: 10
                        color: parent.hovered ? "#F1F5F9" : "white"
                        border.color: "#E2E8F0"
                        border.width: 1
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        font.bold: true
                        color: "#64748B"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: "Exportar como ZIP"
                    enabled: control.totalResults > 0

                    background: Rectangle {
                        radius: 10
                        color: parent.enabled ? (parent.hovered ? "#055B70" : "#0888A9") : "#CBD5E0"
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    HoverHandler {
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    }

                    onClicked: {
                        control.exportRequested(true) // true = incluir percentiles
                        control.close()
                    }
                }
            }
        }
    }
}
