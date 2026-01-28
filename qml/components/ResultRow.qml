// qml/components/ResultRow.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: rowRoot

    property var resultData: ({})
    property int rowIndex: 0

    signal editClicked()
    signal deleteClicked()
    signal pdfClicked()

    function getColorByScoreBg(score){
        if (score === 0) return "#F1F2F4"
        if (score >= 360) return "#D1FAE5"
        if (score >= 300) return "#E7E8FD"
        if (score >= 230) return "#FEF3C7"
        return "#FEE2E2"
    }

    function getColorByScoreTxt(score){
        if (score === 0) return "#9CA3AF"
        if (score < 230) return  "#DC2626"
        if (score < 300) return "#D97706"
        if (score < 360) return "#5C61F2"
        return "#059669"
    }

    width: parent ? parent.width : 0
    height: 64
    color: "white"

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
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

        // Estudiante
        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 150
            text: resultData.studentName || "Sin nombre"
            font.pixelSize: 14
            color: "#1F2937"
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        // Global - Destacado
        Rectangle {
            Layout.preferredWidth: rowRoot.width > 900 ? 100 : 80
            Layout.preferredHeight: 34
            radius: 8
            color: getColorByScoreBg(resultData.global)

            Text {
                anchors.centerIn: parent
                text: resultData.global || "0"
                font.pixelSize: 15
                font.bold: true
                color: getColorByScoreTxt(resultData.global)
            }
        }

        // MAT
        Rectangle {
            Layout.preferredWidth: rowRoot.width > 900 ? 70 : 60
            Layout.preferredHeight: 30
            radius: 6
            color: "#F3F4F6"
            visible: rowRoot.width > 700

            Text {
                anchors.centerIn: parent
                text: (resultData.m || "0") + "/" + (detailRoot.bookletMaxValues?.mat || "0")
                font.pixelSize: 13
                font.bold: true
                color: "#4B5563"
            }
        }

        // LEC
        Rectangle {
            Layout.preferredWidth: rowRoot.width > 900 ? 70 : 60
            Layout.preferredHeight: 30
            radius: 6
            color: "#F3F4F6"
            visible: rowRoot.width > 700

            Text {
                anchors.centerIn: parent
                text: (resultData.l || "0") + "/" + (detailRoot.bookletMaxValues?.lec || "0")
                font.pixelSize: 13
                font.bold: true
                color: "#4B5563"
            }
        }

        // SOC
        Rectangle {
            Layout.preferredWidth: rowRoot.width > 900 ? 70 : 60
            Layout.preferredHeight: 30
            radius: 6
            color: "#F3F4F6"
            visible: rowRoot.width > 800

            Text {
                anchors.centerIn: parent
                text: (resultData.s || "0") + "/" + (detailRoot.bookletMaxValues?.soc || "0")
                font.pixelSize: 13
                font.bold: true
                color: "#4B5563"
            }
        }

        // NAT
        Rectangle {
            Layout.preferredWidth: rowRoot.width > 900 ? 70 : 60
            Layout.preferredHeight: 30
            radius: 6
            color: "#F3F4F6"
            visible: rowRoot.width > 800

            Text {
                anchors.centerIn: parent
                text: (resultData.n || "0") + "/" + (detailRoot.bookletMaxValues?.nat || "0")
                font.pixelSize: 13
                font.bold: true
                color: "#4B5563"
            }
        }

        // ING
        Rectangle {
            Layout.preferredWidth: rowRoot.width > 900 ? 70 : 60
            Layout.preferredHeight: 30
            radius: 6
            color: "#F3F4F6"
            visible: rowRoot.width > 800

            Text {
                anchors.centerIn: parent
                text: (resultData.i || "0") + "/" + (detailRoot.bookletMaxValues?.ing || "0")
                font.pixelSize: 13
                font.bold: true
                color: "#4B5563"
            }
        }
        // Acciones - Menú de tres puntos
        Item {
            Layout.preferredWidth: rowRoot.width > 900 ? 100 : 90
            Layout.preferredHeight: 32

            Button {
                id: menuBtn
                anchors.centerIn: parent
                width: 32
                height: 32
                hoverEnabled: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: menuBtn.clicked()
                }

                background: Rectangle {
                    radius: 6
                    // Se ilumina si hay hover O si el menú está abierto
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

                // 2. EL CLIC:
                // Usamos la señal nativa del botón para que no haya conflictos
                onClicked: {
                    // Lógica responsiva
                    var realMenuHeight = actionsMenu.implicitHeight
                    var posInList = menuBtn.mapToItem(detailRoot.contentItem, 0, 0).y
                    var spaceBelow = detailRoot.height - (posInList + menuBtn.height)

                    if (spaceBelow < realMenuHeight) {
                        actionsMenu.y = -realMenuHeight - 4
                    } else {
                        actionsMenu.y = menuBtn.height + 4
                    }

                    actionsMenu.open()
                }

                // El menú se mantiene dentro del botón
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

                    // --- OPCIÓN EDITAR ---
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
                            // Cursor de mano para la opción
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

                    // --- OPCIÓN ELIMINAR ---
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

                    MenuSeparator {
                        contentItem: Rectangle { implicitHeight: 1; color: "#F3F4F6" }
                    }

                    // --- OPCIÓN PDF ---
                    MenuItem {
                        id: pdfItem
                        height: 42
                        text: "Visualizar Boletín (PDF)"

                        background: Rectangle {
                            color: pdfItem.hovered ? "#F8FAFC" : "white"
                            border.width: pdfItem.hovered ? 1 : 0
                            border.color: "#F1F5F9"
                        }

                        contentItem: Item {
                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                text: pdfItem.text
                                font.pixelSize: 13
                                color: "#1F2937"
                                verticalAlignment: Text.AlignVCenter
                            }
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                        }

                        onTriggered: {
                            actionsMenu.close()
                            rowRoot.pdfClicked()
                        }
                    }
                }
            }
        }
    }


}
