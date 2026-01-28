// qml/views/SimulacrumView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: viewRoot
    objectName: "simulacros"

    property var simulacrosModel: []

    function refreshData() {
        var data = backend.getSimulacrumList()
        console.log("Datos recibidos en QML:", JSON.stringify(data))
        simulacrosModel = data
    }

    Component.onCompleted: refreshData()

    signal openDetail(int simId, string simName)
    signal requestNewSimulacro

    readonly property color colorPrimary: "#066178"
    readonly property color colorSecundary: "#0888A9"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header mejorado
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            radius: 20

            gradient: Gradient {
                GradientStop { position: 0.0; color: colorPrimary }
                GradientStop { position: 1.0; color: colorSecundary }
            }

            Rectangle {
                anchors.fill: parent
                radius: 20
                opacity: 0.1
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "white"
                    }
                    GradientStop {
                        position: 1.0
                        color: "transparent"
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 35
                spacing: 25

                Rectangle {
                    width: 5
                    height: 65
                    radius: 2.5
                    color: "white"
                    opacity: 0.8
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Biblioteca de Simulacros"
                        font.pixelSize: 26
                        font.bold: true
                        color: "white"
                    }

                    Text {
                        text: "Gestiona y organiza tus evaluaciones"
                        font.pixelSize: 14
                        color: "white"
                        opacity: 0.95
                    }
                }

                Button {
                    id: addBtn
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 50
                    text: "Crear Nuevo"
                    onClicked: creationWizard.openForCreate()

                    background: Rectangle {
                        radius: 10
                        color: addBtn.hovered ? "#E7F9FE" : "white"
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        font.bold: true
                        color: colorSecundary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    scale: addBtn.pressed ? 0.95 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }
            }
        }

        // Espaciado después del header
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 25
        }

        // Barra de búsqueda
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            radius: 10
            color: "white"
            border.color: searchField.activeFocus ? colorSecundary : "#E5E7EB"
            border.width: searchField.activeFocus ? 2 : 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 16
                spacing: 10

                Text {
                    text: "⌕"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#94A3B8"
                    verticalAlignment: Text.AlignVCenter
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                    placeholderText: "Buscar simulacro..."
                    font.pixelSize: 15
                    color: "#1F2937"
                    selectByMouse: true

                    background: Rectangle {
                        color: "transparent"
                    }
                }

                Button {
                    visible: searchField.text !== ""
                    implicitWidth: 28
                    implicitHeight: 28
                    text: "✕"
                    onClicked: searchField.text = ""

                    background: Rectangle {
                        radius: 12
                        color: parent.hovered ? "#F1F5F9" : "transparent"
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 18
                        color: "#94A3B8"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        renderType: Text.NativeRendering
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // Espaciado después de búsqueda
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 15
        }

        // Contenedor de tabla
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: "white"
                    border.color: "#E5E7EB"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 0
                        spacing: 0

                        // Header de la tabla
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            color: "#EBEDF0"
                            radius: 12

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.radius
                                color: parent.color
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                spacing: 16

                                // Espacio para avatar
                                Item {
                                    Layout.preferredWidth: 44
                                    Layout.preferredHeight: 44
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 200
                                    text: "Nombre del simulacro"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                }

                                Text {
                                    Layout.preferredWidth: 120
                                    text: "Fecha"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                }

                                Text {
                                    Layout.preferredWidth: 80
                                    text: "Acciones"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        // Lista de simulacros
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            ScrollBar.vertical: ScrollBar {
                                x: parent.width - width - 2 // Pequeño margen a la derecha
                                y: parent.topPadding
                                height: parent.availableHeight

                                // La barra que se mueve (el "handle")
                                contentItem: Rectangle {
                                    implicitWidth: 8
                                    radius: 4
                                    // Usamos tu colorPrimary o uno que resalte
                                    color: parent.pressed ? "#A0AEC0" : "#CBD5E0"
                                    opacity: parent.active ? 0.6 : 0 // Se desvanece si no hay actividad

                                }

                                // El fondo del carril por donde corre la barra
                                background: Rectangle {
                                    implicitWidth: 8
                                    color: "transparent" // O un color muy tenue como "#F0F0F0"
                                }
                            }

                            ListView {
                                id: simulacrosList
                                anchors.fill: parent
                                spacing: 0
                                clip: true

                                model: {
                                    if (searchField.text === "") return viewRoot.simulacrosModel

                                    var filtered = []
                                    var searchLower = searchField.text.toLowerCase()

                                    for (var i = 0; i < viewRoot.simulacrosModel.length; i++) {
                                        var sim = viewRoot.simulacrosModel[i]
                                        if (sim.name.toLowerCase().indexOf(searchLower) !== -1) {
                                            filtered.push(sim)
                                        }
                                    }

                                    return filtered
                                }

                                delegate: SimulacrumRow {
                                    width: simulacrosList.width
                                    simulacrumData: modelData
                                    rowIndex: index

                                    onClicked: {
                                        mainStack.push(simulacroDetailComponent, {
                                            "simulacroId": modelData.id,
                                            "simulacroTitle": modelData.name
                                        })
                                    }

                                    onEditClicked: {
                                        var simData = backend.getSimulacrumData(modelData.id)
                                        editWizard.openForEdit(simData)
                                    }

                                    onDeleteClicked: {
                                        deleteConfirm.simId = modelData.id
                                        deleteConfirm.simName = modelData.name
                                        deleteConfirm.open()
                                    }
                                }

                                // Estado vacío
                                Column {
                                    visible: simulacrosList.count === 0
                                    anchors.centerIn: parent
                                    spacing: 16

                                    Rectangle {
                                        width: 80
                                        height: 80
                                        radius: 40
                                        color: "#F9FAFB"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        border.color: "#E5E7EB"
                                        border.width: 2


                                        Text {
                                            anchors.centerIn: parent
                                            text: searchField.text === "" ? "S" : "⌕"
                                            font.pixelSize: 32
                                            font.bold: true
                                            color: colorPrimary
                                        }
                                    }

                                    Text {
                                        text: searchField.text === "" ? "No hay simulacros registrados" : "No se encontraron resultados"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#1F2937"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: searchField.text === "" ? "Comienza creando tu primer simulacro" : "Intenta con otro término de búsqueda"
                                        font.pixelSize: 14
                                        color: "#6B7280"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
    Popup {
            id: deleteConfirm
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
            width: Math.min(parent.width * 0.92, 440)
            height: Math.min(parent.height * 0.65, 380)
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            padding: 0

            property int simId: -1
            property string simName: ""

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
                    color: "#EF4444"
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
                                text: "¿Eliminar Simulacro?"
                                font.pixelSize: 22
                                font.bold: true
                                color: "white"
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: "Esta acción es permanente y no se puede deshacer"
                                font.pixelSize: 13
                                color: "white"
                                font.weight: Font.Medium
                                wrapMode: Text.WordWrap
                            }
                        }

                        Button {
                            implicitWidth: 36
                            implicitHeight: 36
                            text: "✕"
                            onClicked: deleteConfirm.close()

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

                        // Card del simulacro
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
                                    color: "#09A2C8"

                                    Text {
                                        anchors.centerIn: parent
                                        text: deleteConfirm.simName.charAt(0).toUpperCase() || "S"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "white"
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        width: parent.width
                                        text: deleteConfirm.simName
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#1F2937"
                                        elide: Text.ElideRight
                                        wrapMode: Text.NoWrap
                                    }

                                    Text {
                                        text: "ID: " + deleteConfirm.simId
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
                                        color: "#EF4444"
                                        font.pixelSize: 18
                                    }
                                }
                            }
                        }

                        // Warning
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
                                    text: "Se eliminarán todos los resultados y el cuadernillo asociado de forma permanente."
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
                            onClicked: deleteConfirm.close()

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
                                deleteConfirm.close()
                                var response = backend.deleteFullSimulacrum(deleteConfirm.simId)
                                if (response.success) {
                                    viewAlert.showAlert("Eliminado", response.message, "success")
                                    viewRoot.refreshData()
                                } else {
                                    viewAlert.showAlert("Error", response.message, "error")
                                }
                            }
                        }
                    }
                }
            }

    }

    CustomAlert {
        id: viewAlert
        anchors.centerIn: parent
        z: 3
    }

    SimulacrumWizard {
        id: creationWizard
        alertSystem: viewAlert
        onClosed: viewRoot.refreshData()
    }

    SimulacrumWizard {
        id: editWizard
        alertSystem: viewAlert
        onSimulacrumUpdated: viewRoot.refreshData()
    }
}
