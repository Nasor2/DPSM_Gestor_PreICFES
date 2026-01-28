// qml/components/StudentRow.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: rowRoot

    property var studentData: ({})
    property int rowIndex: 0

    signal editClicked()
    signal deleteClicked()
    signal clicked()

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



    // Efecto hover
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

        // Avatar circular con inicial
        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: width / 2
            color: "#08A929"
            clip: true

            Text {
                anchors.centerIn: parent
                text: studentData.name.charAt(0).toUpperCase() || "S"
                font.pixelSize: 18
                font.bold: true
                color: "white"
            }
        }

        // Nombre del estudiante
        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 200
            text: studentData.name || "Sin nombre"
            font.pixelSize: 15
            font.weight: Font.DemiBold
            color: "#1F2937"
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        // Botón de menú (tres puntos)
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
                color: (menuBtn.hovered || actionsMenu.opened) ? "#E9EBF0" : "transparent"
                border.color: (menuBtn.hovered || actionsMenu.opened) ? "#D1D5DB" : "transparent"
                border.width: (menuBtn.hovered || actionsMenu.opened) ? 1 : 0
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
                // Posicionamiento responsivo del menú
                var realMenuHeight = actionsMenu.implicitHeight
                var posInList = menuBtn.mapToItem(rowRoot.ListView.view.contentItem, 0, 0).y
                var spaceBelow = rowRoot.ListView.view.height - (posInList + menuBtn.height)

                if (spaceBelow < realMenuHeight) {
                    actionsMenu.y = -realMenuHeight - 4
                } else {
                    actionsMenu.y = menuBtn.height + 4
                }

                actionsMenu.open()
            }



            // Evitar que el click del menú active el click de la fila
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

                // Opción EDITAR
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
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                    }

                    onTriggered: {
                        actionsMenu.close()
                        rowRoot.editClicked()
                    }
                }

                MenuSeparator {
                    contentItem: Rectangle { implicitHeight: 1; color: "#F3F4F6" }
                }

                // Opción ELIMINAR
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
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                    }

                    onTriggered: {
                        actionsMenu.close()
                        rowRoot.deleteClicked()
                    }
                }
            }
        }
    }
}}
