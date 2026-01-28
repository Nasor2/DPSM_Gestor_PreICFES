import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    property string title: ""
    property color titleColor: "black"
    property color iconBg: "#F3F4F6"
    property string iconText: "#"
    property var modelData: []

    color: "white"
    radius: 12
    border.color: "#E5E7EB"
    border.width: 1
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        RowLayout {
            spacing: 8

            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: iconBg

                Text {
                    anchors.centerIn: parent
                    text: iconText
                    font.pixelSize: 14
                    font.bold: true
                    color: titleColor
                }
            }

            Text {
                text: title
                font.bold: true
                color: titleColor
                font.pixelSize: 15
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#F3F4F6"
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8

            model: modelData

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 6

                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: parent.pressed ? "#A0AEC0" : "#E5E7EB"
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }

            delegate: Rectangle {
                width: ListView.view.width
                height: 48
                radius: 8
                color: "#F9FAFB"
                border.color: "#F3F4F6"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: titleColor

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            font.pixelSize: 12
                            font.bold: true
                            color: iconBg
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: (modelData && modelData.name) ? modelData.name : ""
                        font.pixelSize: 14
                        color: "#1F2937"
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        width: 55
                        height: 32
                        radius: 6
                        color: "white"
                        border.color: "#E5E7EB"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: (modelData && modelData.score !== undefined) ? modelData.score : "0"
                            font.bold: true
                            font.pixelSize: 14
                            color: titleColor
                        }
                    }
                }
            }
        }

        Text {
            visible: modelData.length === 0
            text: "Sin datos disponibles"
            color: "#9CA3AF"
            font.pixelSize: 13
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
