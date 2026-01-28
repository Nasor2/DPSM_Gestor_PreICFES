import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: deleteDialog

    property var resultToDelete: null

    signal confirmDelete()

    width: Math.min(parent.width * 0.92, 440)
    height: Math.min(parent.height * 0.65, 380)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    focus: true
    padding: 0

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
            Layout.preferredHeight: 100
            color: "#FEE2E2"
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
                    color: "#EF4444"
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "¿Eliminar Resultado?"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#1A202C"
                    }

                    Text {
                        text: "Esta acción es permanente y no se puede deshacer"
                        font.pixelSize: 13
                        color: "#DC2626"
                        font.weight: Font.Medium
                    }
                }

                Button {
                    implicitWidth: 36
                    implicitHeight: 36
                    text: "✕"
                    onClicked: deleteDialog.close()

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered ? "#FEE2E2" : "transparent"
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 20
                        color: "#EF4444"
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
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                anchors.topMargin: 24
                anchors.bottomMargin: 16
                spacing: 18

                // Card del estudiante
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 75
                    radius: 12
                    color: "#F8FAFC"
                    border.color: "#E5E7EB"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        spacing: 14

                        Rectangle {
                            width: 48
                            height: 48
                            radius: 24
                            color: "#FEE2E2"

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (!deleteDialog.resultToDelete) return "?"
                                    var name = deleteDialog.resultToDelete.studentName || "?"
                                    return name.charAt(0).toUpperCase()
                                }
                                font.pixelSize: 20
                                font.bold: true
                                color: "#DC2626"
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: deleteDialog.resultToDelete ? deleteDialog.resultToDelete.studentName : ""
                                font.pixelSize: 16
                                font.bold: true
                                color: "#1F2937"
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "Puntaje: " + (deleteDialog.resultToDelete ? deleteDialog.resultToDelete.global : "0")
                                font.pixelSize: 13
                                color: "#6B7280"
                            }
                        }

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 8
                            color: "#FEE2E2"

                            Text {
                                anchors.centerIn: parent
                                text: "🗑"
                                color: "#F40909"
                                font.pixelSize: 18
                            }
                        }
                    }
                }

                // Warning box
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    radius: 10
                    color: "#FFFBEB"
                    border.color: "#FDE68A"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 8
                            color: "#FEF3C7"

                            Text {
                                anchors.centerIn: parent
                                text: "⚠"
                                font.pixelSize: 20
                                color: "#D97706"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Los datos eliminados no podrán recuperarse. Asegúrate de que esta es la acción correcta."
                            font.pixelSize: 13
                            color: "#92400E"
                            wrapMode: Text.WordWrap
                            lineHeight: 1.3
                        }
                    }
                }

                Item { Layout.fillHeight: true }
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
                anchors.margins: 24
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: "Cancelar"
                    onClicked: deleteDialog.close()

                    background: Rectangle {
                        radius: 10
                        color: parent.hovered ? "#F1F5F9" : "white"
                        border.color: "#E2E8F0"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
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
                    Layout.preferredHeight: 48
                    text: "Sí, Eliminar"

                    background: Rectangle {
                        radius: 10
                        color: parent.hovered ? "#DC2626" : "#EF4444"
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
                        deleteDialog.confirmDelete()
                        deleteDialog.close()
                    }
                }
            }
        }
    }
}
