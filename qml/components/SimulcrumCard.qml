// qml/components/SimulcrumCard.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: cardRoot

    // Dimensiones por defecto (se sobrescriben desde el parent)
    width: 180
    height: 220

    property string title: "Simulacro 1"
    property string date: "Sin fecha"
    property color accentColor: "#5C61F2"

    signal clicked()

    scale: cardMouse.pressed ? 0.96 : (cardMouse.containsMouse ? 1.02 : 1.0)
    Behavior on scale { NumberAnimation { duration: 50; easing.type: Easing.OutCubic } }

    ColumnLayout {
        anchors.fill: parent
        spacing: cardRoot.height * 0.055  // 12px en proporción

        Rectangle {
            id: folderShape
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: cardRoot.width * 0.78  // Proporción de 140/180
            Layout.preferredHeight: cardRoot.height * 0.68  // Proporción de 150/220
            color: cardMouse.containsMouse ? "#F7F9FF" : "white"
            radius: cardRoot.width * 0.067
            border.color: cardMouse.containsMouse ? cardRoot.accentColor : "#E2E8F0"
            border.width: 2

            Behavior on color { ColorAnimation { duration: 50 } }
            Behavior on border.color { ColorAnimation { duration: 50 } }

            // Pestaña superior
            Rectangle {
                width: folderShape.width * 0.32
                height: folderShape.height * 0.08
                radius: height / 2
                color: parent.border.color
                anchors.bottom: parent.top
                anchors.left: parent.left
                anchors.leftMargin: folderShape.width * 0.057
                anchors.bottomMargin: -3
                Behavior on color { ColorAnimation { duration: 50 } }
            }

            // Barra lateral de acento
            Rectangle {
                width: folderShape.width * 0.043
                height: parent.height - 30
                anchors.left: parent.left
                anchors.leftMargin: folderShape.width * 0.086
                anchors.verticalCenter: parent.verticalCenter
                color: cardRoot.accentColor
                radius: 3
                opacity: cardMouse.containsMouse ? 0.8 : 0.4
                Behavior on opacity { NumberAnimation { duration: 50 } }
            }

            // Contenido central
            ColumnLayout {
                anchors.centerIn: parent
                spacing: folderShape.height * 0.053

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: folderShape.width * 0.36
                    height: width
                    radius: width / 2
                    color: cardRoot.accentColor
                    opacity: 0.1

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.6
                        height: width
                        radius: width / 2
                        color: cardRoot.accentColor
                        opacity: 0.3
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "SIMLUACRO"
                    font.pixelSize: Math.max(10, folderShape.height * 0.073)
                    font.bold: true
                    color: cardRoot.accentColor
                    opacity: 0.6
                }
            }
        }

        // Información del card
        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Text {
                text: cardRoot.title
                width: cardRoot.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.pixelSize: Math.max(12, cardRoot.width * 0.078)
                font.bold: true
                color: "#2D3748"
            }

            Text {
                text: cardRoot.date
                width: cardRoot.width
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Math.max(10, cardRoot.width * 0.061)
                color: "#A0AEC0"
            }
        }
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: cardRoot.clicked()
    }
}
