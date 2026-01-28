// qml/components/SimulacrumRow.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: rowRoot

    property var simulacrumData: ({})
    property int rowIndex: 0

    signal clicked
    signal editClicked
    signal deleteClicked

    width: parent ? parent.width : 0
    height: 64
    color: "white"

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: rowRoot.clicked()
    }

    // Efecto hover elegante
    Rectangle {
        anchors.fill: parent
        color: rowMouse.containsMouse ? "#F8FAFC" : "transparent"
    }

    // Línea divisoria inferior
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        height: 1
        color: "#F3F4F6"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 16

        // Avatar circular con letra S
        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: width / 2
            color: "#09A2C8"
            clip: true

            Text {
                anchors.centerIn: parent
                text: simulacrumData.name.charAt(0).toUpperCase() || "S"
                font.pixelSize: 18
                font.bold: true
                color: "white"
            }
        }

        // Nombre del simulacro
        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 200
            text: simulacrumData.name || "Sin nombre"
            font.pixelSize: 15
            font.weight: Font.DemiBold
            color: "#1F2937"
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        // Fecha
        RowLayout {
            Layout.preferredWidth: 140
            spacing: 8

            Text {
                text: simulacrumData.date || "Sin fecha"
                font.pixelSize: 14
                color: "#6B7280"
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Botón de acciones (tres puntos)
        Item {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 32

            Button {
                id: menuBtn
                anchors.centerIn: parent
                width: 32
                height: 32
                hoverEnabled: true

                background: Rectangle {
                    radius: 6
                    color: (menuBtn.hovered
                            || actionsMenu.opened) ? "#E9EBF0" : "transparent"
                    border.color: (menuBtn.hovered
                                   || actionsMenu.opened) ? "#D1D5DB" : "transparent"
                    border.width: (menuBtn.hovered
                                   || actionsMenu.opened) ? 1 : 0
                }

                contentItem: Text {
                    text: "⋮"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#6B7280"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    var realMenuHeight = actionsMenu.implicitHeight
                    var posInList = menuBtn.mapToItem(
                                rowRoot.ListView.view.contentItem, 0, 0).y
                    var spaceBelow = rowRoot.ListView.view.height - (posInList + menuBtn.height)

                    if (spaceBelow < realMenuHeight) {
                        actionsMenu.y = -realMenuHeight - 4
                    } else {
                        actionsMenu.y = menuBtn.height + 4
                    }

                    actionsMenu.open()
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: parent.clicked()
                    cursorShape: Qt.PointingHandCursor
                    z: 1
                }

                Menu {
                    id: actionsMenu
                    x: -(width - menuBtn.width)
                    width: 200

                    background: Rectangle {
                        implicitWidth: 200
                        color: "white"
                        radius: 8
                        border.color: "#E5E7EB"
                        border.width: 1
                    }

                    // Ver detalles
                    MenuItem {
                        id: viewItem
                        height: 42
                        text: "Ver Detalles"

                        background: Rectangle {
                            color: viewItem.hovered ? "#F8FAFC" : "white"
                            border.width: viewItem.hovered ? 1 : 0
                            border.color: "#F1F5F9"
                        }

                        contentItem: Item {
                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                text: viewItem.text
                                font.pixelSize: 13
                                color: "#1F2937"
                                verticalAlignment: Text.AlignVCenter
                            }
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        onTriggered: {
                            actionsMenu.close()
                            rowRoot.clicked()
                        }
                    }

                    MenuSeparator {
                        contentItem: Rectangle {
                            implicitHeight: 1
                            color: "#F3F4F6"
                        }
                    }

                    // Editar
                    MenuItem {
                        id: editItem
                        height: 42
                        text: "Editar"

                        background: Rectangle {
                            color: editItem.hovered ? "#F8FAFC" : "white"
                            border.width: editItem.hovered ? 1 : 0
                            border.color: "#F1F5F9"
                        }

                        contentItem: Item {
                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                text: editItem.text
                                font.pixelSize: 13
                                color: "#1F2937"
                                verticalAlignment: Text.AlignVCenter
                            }
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        onTriggered: {
                            actionsMenu.close()
                            rowRoot.editClicked()
                        }
                    }

                    MenuSeparator {
                        contentItem: Rectangle {
                            implicitHeight: 1
                            color: "#F3F4F6"
                        }
                    }

                    // Eliminar
                    MenuItem {
                        id: deleteItem
                        height: 42
                        text: "Eliminar"

                        background: Rectangle {
                            color: deleteItem.hovered ? "#FEF2F2" : "white"
                            border.width: deleteItem.hovered ? 1 : 0
                            border.color: "#FEE2E2"
                        }

                        contentItem: Item {
                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                text: deleteItem.text
                                font.pixelSize: 13
                                color: "#EF4444"
                                verticalAlignment: Text.AlignVCenter
                            }
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        onTriggered: {
                            actionsMenu.close()
                            rowRoot.deleteClicked()
                        }
                    }
                }
            }
        }
    }
}
