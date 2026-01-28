// qml/components/StudentDetailPopup.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: control

    property int studentId: -1
    property string studentName: ""
    property var simulacraList: []

    width: Math.min(parent.width * 0.85, 600)
    height: Math.min(parent.height * 0.75, 520)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    focus: true
    padding: 0

    onAboutToShow: {
        if (studentId > 0) {
            loadStudentData()
        }
    }

    function loadStudentData() {
        var info = backend.getStudentInfo(studentId)
        if (info && info.id) {
            studentName = info.name
            totalSimsText.text = info.totalSimulacra + " simulacro" + (info.totalSimulacra !== 1 ? "s" : "") + " realizados"
        }
        simulacraList = backend.getStudentSimulacraWithScores(studentId)
    }

    Overlay.modal: Rectangle {
        color: "#80000000"
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        NumberAnimation { property: "scale"; from: 0.92; to: 1; duration: 200; easing.type: Easing.OutCubic }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; to: 0; duration: 150 }
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
            Layout.preferredHeight: 120
            color: "#08A929"
            radius: 16

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.radius
                color: parent.color
            }

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                opacity: 0.12
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "white" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 24
                spacing: 20

                // Avatar grande
                Rectangle {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    radius: 32
                    color: "#09C82F"

                    Text {
                        anchors.centerIn: parent
                        text: studentName.charAt(0).toUpperCase()
                        font.pixelSize: 28
                        font.bold: true
                        color: "white"
                    }
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: studentName
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                        elide: Text.ElideRight
                    }

                    Text {
                        id: totalSimsText
                        text: "0 simulacros realizados"
                        font.pixelSize: 14
                        color: "white"
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

                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                }
            }
        }

        // Contenido
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 24
            spacing: 16

            Text {
                text: "Historial de Simulacros"
                font.pixelSize: 16
                font.bold: true
                color: "#1F2937"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "#F9FAFB"
                border.color: "#E5E7EB"
                border.width: 1

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ListView {
                        id: simulacraListView
                        anchors.fill: parent
                        spacing: 8
                        model: control.simulacraList

                        delegate: Rectangle {
                            width: simulacraListView.width
                            height: 60
                            radius: 8
                            color: "white"
                            border.color: "#E5E7EB"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 12

                                Rectangle {
                                    Layout.preferredWidth: 48
                                    Layout.preferredHeight: 48
                                    radius: 24
                                    color: "#09A2C8"

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.name.charAt(0).toUpperCase() || "Simulacro"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "white"
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: modelData.name || "Simulacro"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#1F2937"
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.date || "Sin fecha"
                                        font.pixelSize: 12
                                        color: "#6B7280"
                                    }
                                }
                                Rectangle {
                                            Layout.preferredWidth: 65
                                            Layout.preferredHeight: 36
                                            radius: 8
                                            color: {
                                                var score = modelData.score || 0
                                                if (score === 0) return "#F1F2F4"
                                                if (score >= 360) return "#D1FAE5"
                                                if (score >= 300) return "#E7E8FD"
                                                if (score >= 230) return "#FEF3C7"
                                                return "#FEE2E2"
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.score || "0"
                                                font.pixelSize: 15
                                                font.bold: true
                                                color: {
                                                    var score = modelData.score || 0
                                                    if (score === 0) return "#9CA3AF"
                                                    if (score < 230) return  "#DC2626"
                                                    if (score < 300) return "#D97706"
                                                    if (score < 360) return "#5C61F2"
                                                    return "#059669"
                                                }
                                            }
                                        }
                            }
                        }

                        // Estado vacío
                        Column {
                            visible: simulacraListView.count === 0
                            anchors.centerIn: parent
                            spacing: 12

                            Rectangle {
                                width: 60
                                height: 60
                                radius: 30
                                color: "#F3F4F6"
                                anchors.horizontalCenter: parent.horizontalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "E"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#9CA3AF"
                                }
                            }

                            Text {
                                text: "Sin simulacros registrados"
                                font.pixelSize: 14
                                color: "#6B7280"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: "Cerrar"
                onClicked: control.close()

                background: Rectangle {
                    radius: 10
                    color: parent.hovered ? "#06781D" : "#08A929"
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
            }
        }
    }
}
