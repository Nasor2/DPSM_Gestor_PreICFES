import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property string title: "Atención"
    property string message: ""
    property string type: "error" // "error", "warning", "success"

    // Posicionamiento centrado
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: Math.min(parent.width * 0.9, 380)

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Fondo con un borde sutil en lugar de sombras pesadas
    background: Rectangle {
        radius: 16
        color: "white"
        border.color: "#E5E7EB"
        border.width: 1

        // Simulación de elevación con un segundo borde inferior
        Rectangle {
            width: parent.width
            height: 4
            color: "#10000000"
            radius: 16
            anchors.bottom: parent.bottom
            z: -1
        }
    }

    contentItem: ColumnLayout {
        spacing: 15
        anchors.margins: 24

        // Cabecera con Icono Estilizado
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 56; height: 56
            radius: 28
            color: {
                if (root.type === "error") return "#FEF2F2"
                if (root.type === "warning") return "#FFFBEB"
                return "#F0FDF4"
            }

            Text {
                anchors.centerIn: parent
                text: root.type === "error" ? "✕" : (root.type === "warning" ? "!" : "✓")
                font.pixelSize: 24
                font.bold: true
                color: {
                    if (root.type === "error") return "#EF4444"
                    if (root.type === "warning") return "#F59E0B"
                    return "#22C55E"
                }
            }
        }

        // Textos
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: root.title
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 18
                font.bold: true
                color: "#111827"
            }

            Text {
                text: root.message
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: 14
                lineHeight: 1.2
                color: "#6B7280"
            }
        }

        // Botón de acción único
        Button {
            id: closeBtn
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            Layout.topMargin: 10
            text: "Entendido"

            onClicked: root.close()

            background: Rectangle {
                radius: 12
                color: closeBtn.pressed ? "#1048B9" : (closeBtn.hovered ? "#0D3B96" : "#1048B9")
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 14
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            HoverHandler { cursorShape: Qt.PointingHandCursor }
        }
    }

    // Función pública para llamar desde cualquier lugar
    function showAlert(t, m, type) {
        root.title = t
        root.message = m
        root.type = type || "error"
        root.open()
    }

    // Animación de entrada sutil
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 150; easing.type: Easing.OutBack }
    }
}
