// components/NavButton.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: control
    property bool isActive: false
    property string iconSource: ""
    property string iconSourceActive: ""  // SVG alternativo para estado activo
    property string iconText: ""
    property color activeColor: "#6366F1"
    property color inactiveColor: "#64748B"
    property alias text: btnText.text
    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: 48

    // Trigger del efecto glow
    onIsActiveChanged: {
        if (isActive) glowAnim.restart()
    }

    HoverHandler {
        id: hover
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        color: hover.hovered && !control.isActive ? "#F8FAFC" : "transparent"
        radius: 12
        border.width: hover.hovered && !control.isActive ? 1 : 0
        border.color: "#F1F5F9"

        // Indicador lateral (posicionado absolutamente)
        Rectangle {
            id: indicator
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 0
            width: 4
            height: control.isActive ? 28 : 0
            radius: 2
            color: control.activeColor
            Behavior on height { NumberAnimation { duration: 200 } }
        }

        // Contenido del botón
        Row {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 8
            spacing: 14
            anchors.verticalCenter: parent.verticalCenter

            // Contenedor del icono
            Rectangle {
                width: 40
                height: 40
                radius: 12
                anchors.verticalCenter: parent.verticalCenter
                color: control.isActive ? Qt.rgba(control.activeColor.r, control.activeColor.g, control.activeColor.b, 0.12) : "transparent"

                // Icono - SVG o Texto
                Item {
                    width: 20
                    height: 20
                    anchors.centerIn: parent

                    // Mostrar SVG si hay iconSource
                    Image {
                        visible: control.iconSource !== ""
                        anchors.fill: parent
                        source: control.isActive && control.iconSourceActive !== ""
                                ? control.iconSourceActive
                                : control.iconSource
                        sourceSize: Qt.size(20, 20)
                        smooth: true
                        fillMode: Image.PreserveAspectFit
                    }

                    // Mostrar texto/unicode si hay iconText
                    Text {
                        visible: control.iconText !== ""
                        anchors.centerIn: parent
                        text: control.iconText
                        font.pixelSize: 18
                        color: control.isActive ? control.activeColor : "#94A3B8"
                    }
                }

                // Efecto glow
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: control.activeColor
                    opacity: 0
                    NumberAnimation on opacity {
                        id: glowAnim
                        running: false
                        from: 0.3
                        to: 0
                        duration: 400
                    }
                }
            }

            Text {
                id: btnText
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
                font.weight: control.isActive ? Font.DemiBold : Font.Medium
                color: control.isActive ? control.activeColor : control.inactiveColor
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: control.clicked()
        cursorShape: Qt.PointingHandCursor
    }

    // Animación de escala al presionar
    scale: mouseArea.pressed ? 0.98 : 1.0
    Behavior on scale { NumberAnimation { duration: 100 } }
}
