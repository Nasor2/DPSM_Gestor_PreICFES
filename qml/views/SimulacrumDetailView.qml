import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: detailRoot
    objectName: "simulacro_detalle"

    property int simulacroId: 0
    property string simulacroTitle: ""
    property string bookletName: ""
    property var resultsModel: []
    property var studentSuggestions: []
    property var bookletMaxValues: ({
                                        "mat": 0,
                                        "lec": 0,
                                        "soc": 0,
                                        "nat": 0,
                                        "ing": 0
                                    })

    function loadSimulacroDetails() {
        if (simulacroId <= 0) return

        console.log("Refrescando detalle completo para ID:", simulacroId)

        // Recargar nombre del simulacro desde backend
        var simData = backend.getSimulacrumData(simulacroId)
        if (simData && simData.id > 0) {
            simulacroTitle = simData.name || "Sin nombre"
            console.log("Título recargado:", simulacroTitle)
        }

        // Recargar cuadernillo
        var info = backend.getBookletData(simulacroId)
        if (info) {
            bookletMaxValues = {
                "mat": info.tM,
                "lec": info.tL,
                "soc": info.tS,
                "nat": info.tN,
                "ing": info.tI
            }
            bookletName = info.name || "Cuadernillo sin nombre"
            console.log("Booklet recargado:", bookletName)
        }

        studentSuggestions = backend.getStudentSuggestions()
        refreshResults()
    }

    function refreshResults() {
        resultsModel = backend.getFullResultsList(simulacroId)
        if (statsView) {
            statsView.loadData()
        }
    }

    Component.onCompleted: {
        loadSimulacroDetails()
    }

    onSimulacroIdChanged: {
        if (simulacroId > 0) {
            loadSimulacroDetails()
        }
    }

    readonly property color colorPrimary: "#066178"
    readonly property color colorSecundary: "#0888A9"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Botón volver
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.bottomMargin: 15

            Button {
                anchors.left: parent.left
                width: 100
                height: 36
                text: "← Volver"

                background: Rectangle {
                    radius: 10
                    color: parent.hovered ? "#E7F9FE" : "white"
                    border.color: "#E5E7EB"
                    border.width: 1
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: colorPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                onClicked: mainStack.pop()
            }

            // Botón Kebab (tres puntos) - Derecha
            Button {
                id: kebabBtn
                anchors.right: parent.right
                width: 36
                height: 36
                hoverEnabled: true

                background: Rectangle {
                    radius: 8
                    color: (kebabBtn.hovered
                            || actionsMenu.opened) ? "#E9EBF0" : "transparent"
                    border.color: (kebabBtn.hovered
                                   || actionsMenu.opened) ? "#D1D5DB" : "transparent"
                    border.width: (kebabBtn.hovered
                                   || actionsMenu.opened) ? 1 : 0

                }

                contentItem: Text {
                    text: "⋮"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#6B7280"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    var realMenuHeight = actionsMenu.implicitHeight
                    var posInView = kebabBtn.mapToItem(detailRoot, 0, 0).y
                    var spaceBelow = detailRoot.height - (posInView + kebabBtn.height)
                    if (spaceBelow < realMenuHeight) {
                        actionsMenu.y = -realMenuHeight - 8
                    } else {
                        actionsMenu.y = kebabBtn.height + 4
                    }
                    actionsMenu.open()
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                Menu {
                    id: actionsMenu
                    x: kebabBtn.width - width
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
                        height: 42
                        text: "Editar"
                        background: Rectangle {
                            color: parent.hovered ? "#F8FAFC" : "white"
                            border.width: parent.hovered ? 1 : 0
                            border.color: "#F1F5F9"
                        }
                        contentItem: Text {
                            leftPadding: 16
                            text: parent.text
                            font.pixelSize: 13
                            color: "#1F2937"
                            verticalAlignment: Text.AlignVCenter
                        }
                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                        onTriggered: {
                            actionsMenu.close()
                            var simData = backend.getSimulacrumData(simulacroId)
                            editWizard.openForEdit(simData)
                        }
                    }

                    MenuSeparator {
                        contentItem: Rectangle {
                            implicitHeight: 1
                            color: "#F3F4F6"
                        }
                    }

                    // Opción ELIMINAR (rojo)
                    MenuItem {
                        height: 42
                        text: "Eliminar"
                        background: Rectangle {
                            color: parent.hovered ? "#FEF2F2" : "white"
                            border.width: parent.hovered ? 1 : 0
                            border.color: "#FEE2E2"
                        }
                        contentItem: Text {
                            leftPadding: 16
                            text: parent.text
                            font.pixelSize: 13
                            color: "#EF4444"
                            verticalAlignment: Text.AlignVCenter
                        }
                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                        onTriggered: {
                            actionsMenu.close()
                            deleteConfirm.open()
                        }
                    }

                    MenuSeparator {
                        contentItem: Rectangle {
                            implicitHeight: 1
                            color: "#F3F4F6"
                        }
                    }

                    MenuItem {
                        height: 42
                        text: "Exportar Todos los Boletines"
                        enabled: resultsModel.length > 0

                        background: Rectangle {
                            color: parent.hovered ? "#F8FAFC" : "white"
                            border.width: parent.hovered ? 1 : 0
                            border.color: "#F1F5F9"
                            opacity: parent.enabled ? 1 : 0.5
                        }

                        contentItem: Text {
                            leftPadding: 16
                            text: parent.text
                            font.pixelSize: 13
                            color: "#1F2937"
                            verticalAlignment: Text.AlignVCenter
                        }

                        HoverHandler {
                            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                        }

                        onTriggered: {
                            actionsMenu.close()
                            exportAllConfirmDialog.open()
                        }
                    }
                }
            }

        }

        // Header
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
                opacity: 0.12
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
                anchors.margins: 32
                spacing: 24

                Rectangle {
                    Layout.preferredWidth: 4
                    Layout.preferredHeight: 64
                    radius: 2
                    color: "white"
                    opacity: 0.75
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: detailRoot.simulacroTitle
                        font {
                            pixelSize: 28
                            weight: Font.Bold
                        }
                        color: "white"
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        spacing: 16

                        Text {
                            text: bookletName
                            font {
                                pixelSize: 17
                                weight: Font.Medium
                            }
                            color: "#E0E7FF"
                            opacity: 0.95
                        }

                        Rectangle {
                            Layout.preferredWidth: 4
                            Layout.preferredHeight: 4
                            radius: 2
                            color: "#E0E7FF"
                            opacity: 0.6
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: resultsModel.length + " estudiante"
                                  + (resultsModel.length !== 1 ? "s" : "") + " evaluado"
                                  + (resultsModel.length !== 1 ? "s" : "")
                            font {
                                pixelSize: 15
                            }
                            color: "#E0E7FF"
                            opacity: 0.85
                        }
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 52
                    text: "Ingresar Notas"

                    background: Rectangle {
                        radius: 12
                        color: parent.hovered ? "#E7F9FE" : "white"
                        border.color: "#E5E7EB"
                        border.width: parent.hovered ? 2 : 1
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font {
                            pixelSize: 15
                            weight: Font.Bold
                        }
                        color: colorSecundary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    onClicked: {
                        resultPopup.openForAdd(detailRoot.simulacroId,
                                               detailRoot.bookletMaxValues,
                                               backend.getStudentSuggestions())
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
        }

        // Tabs con buscador
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 12

                TabBar {
                    id: bar
                    Layout.fillWidth: false
                    spacing: 12

                    onCurrentIndexChanged: {
                        if (currentIndex === 1) {
                            statsView.loadData()
                        }
                    }

                    background: Rectangle {
                        color: "transparent"
                    }

                    TabButton {
                        text: "Resultados"
                        width: implicitWidth + 32
                        height: 42

                        background: Rectangle {
                            color: parent.checked ? colorSecundary : (parent.hovered ? "#E7F9FE" : "white")
                            radius: 10
                            border.color: parent.checked ? "transparent" : "#E5E7EB"
                            border.width: 1
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            font.bold: parent.checked
                            color: parent.checked ? "white" : "#6B7280"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    TabButton {
                        text: "Estadísticas"
                        width: implicitWidth + 32
                        height: 42

                        background: Rectangle {
                            color: parent.checked ? colorSecundary : (parent.hovered ? "#E7F9FE" : "white")
                            radius: 10
                            border.color: parent.checked ? "transparent" : "#E5E7EB"
                            border.width: 1
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            font.bold: parent.checked
                            color: parent.checked ? "white" : "#6B7280"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: 42
                    radius: 10
                    color: "white"
                    border.color: studentSearchField.activeFocus ? colorSecundary : "#E5E7EB"
                    border.width: studentSearchField.activeFocus ? 2 : 1
                    visible: bar.currentIndex === 0

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            text: "⌕"
                            font.pixelSize: 18
                            color: "#94A3B8"
                        }

                        TextField {
                            id: studentSearchField
                            Layout.fillWidth: true
                            placeholderText: "Buscar estudiante..."
                            font.pixelSize: 13
                            color: "#1F2937"
                            selectByMouse: true

                            background: Rectangle {
                                color: "transparent"
                            }
                        }

                        Button {
                            visible: studentSearchField.text !== ""
                            implicitWidth: 20
                            implicitHeight: 20
                            text: "✕"
                            onClicked: studentSearchField.text = ""

                            background: Rectangle {
                                radius: 10
                                color: parent.hovered ? "#F1F5F9" : "transparent"
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: "#94A3B8"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
        }

        // Contenido
        StackLayout {
            currentIndex: bar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true

            // PESTAÑA 1: RESULTADOS
            Item {
                Rectangle {
                    anchors.fill: parent
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
                            Layout.preferredHeight: 52
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

                                Text {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 150
                                    text: "Estudiante"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                }

                                Text {
                                    Layout.preferredWidth: detailRoot.width > 900 ? 100 : 80
                                    text: "Puntaje Global"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    Layout.preferredWidth: detailRoot.width > 900 ? 70 : 60
                                    text: "MAT"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: detailRoot.width > 700
                                }

                                Text {
                                    Layout.preferredWidth: detailRoot.width > 900 ? 70 : 60
                                    text: "LEC"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: detailRoot.width > 700
                                }

                                Text {
                                    Layout.preferredWidth: detailRoot.width > 900 ? 70 : 60
                                    text: "SOC"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: detailRoot.width > 800
                                }

                                Text {
                                    Layout.preferredWidth: detailRoot.width > 900 ? 70 : 60
                                    text: "NAT"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: detailRoot.width > 800
                                }

                                Text {
                                    Layout.preferredWidth: detailRoot.width > 900 ? 70 : 60
                                    text: "ING"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: detailRoot.width > 800
                                }

                                Text {
                                    Layout.preferredWidth: detailRoot.width > 900 ? 100 : 90
                                    text: "Acciones"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1F2937"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        // Lista
                        ListView {
                            id: resultsList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            model: {
                                if (studentSearchField.text === "") {
                                    return detailRoot.resultsModel
                                }

                                var filtered = []
                                var searchLower = studentSearchField.text.toLowerCase()

                                for (var i = 0; i < detailRoot.resultsModel.length; i++) {
                                    var result = detailRoot.resultsModel[i]
                                    if (result.studentName.toLowerCase(
                                                ).indexOf(searchLower) !== -1) {
                                        filtered.push(result)
                                    }
                                }

                                return filtered
                            }

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                                width: 8

                                contentItem: Rectangle {
                                    implicitWidth: 8
                                    radius: 4
                                    color: parent.pressed ? "#A0AEC0" : "#CBD5E0"
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }
                                }
                            }

                            delegate: ResultRow {
                                width: resultsList.width
                                resultData: modelData
                                rowIndex: index

                                property var bookletMaxValues: ({
                                        "mat": detailRoot.bookletMaxValues.mat,
                                        "lec": detailRoot.bookletMaxValues.lec,
                                        "soc": detailRoot.bookletMaxValues.soc,
                                        "nat": detailRoot.bookletMaxValues.nat,
                                        "ing": detailRoot.bookletMaxValues.ing
                                    })

                                onEditClicked: {
                                    resultPopup.openForEdit(
                                                detailRoot.simulacroId,
                                                detailRoot.bookletMaxValues,
                                                modelData)
                                }

                                onDeleteClicked: {
                                    deleteResultConfirm.resultToDelete = modelData
                                    deleteResultConfirm.open()
                                }

                                onPdfClicked: {
                                    boletinConfirmDialog.studentId = modelData.studentId
                                    boletinConfirmDialog.studentName = modelData.studentName  // ← NUEVO
                                    boletinConfirmDialog.open()
                                }
                            }

                            // Estado vacío
                            Rectangle {
                                visible: {
                                    if (studentSearchField.text === "") {
                                        return detailRoot.resultsModel.length === 0
                                    }

                                    var filtered = 0
                                    var searchLower = studentSearchField.text.toLowerCase()

                                    for (var i = 0; i < detailRoot.resultsModel.length; i++) {
                                        if (detailRoot.resultsModel[i].studentName.toLowerCase(
                                                    ).indexOf(
                                                    searchLower) !== -1) {
                                            filtered++
                                        }
                                    }

                                    return filtered === 0
                                }
                                anchors.centerIn: parent
                                width: parent.width
                                height: 280
                                color: "transparent"

                                Column {
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
                                            text: studentSearchField.text === "" ? "R" : "⌕"
                                            font.pixelSize: 32
                                            font.bold: true
                                            color: colorPrimary
                                        }
                                    }

                                    Text {
                                        text: studentSearchField.text === "" ? "No hay resultados registrados" : "No se encontraron estudiantes"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#1F2937"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: studentSearchField.text === "" ? "Comienza ingresando las notas de tus estudiantes" : "Intenta con otro nombre"
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

            // PESTAÑA 2: ESTADÍSTICAS
            SimulacrumStatsView {
                id: statsView
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentSimId: detailRoot.simulacroId
            }
        }
    }


    CustomAlert {
        id: viewAlert
        anchors.centerIn: parent
        z: 3
    }

    ResultPopup {
        id: resultPopup
        alertSystem: viewAlert
        onSaved: detailRoot.refreshResults()
    }

    Popup {
        id: deleteConfirm

        // Usar detailRoot como parent para centrar en toda la vista
        parent: detailRoot
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: Math.min(parent.width * 0.92, 440)
        height: Math.min(parent.height * 0.65, 380)

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
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
                            width: parent.width
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
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
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
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                radius: 24
                                color: "#09A2C8"

                                Text {
                                    anchors.centerIn: parent
                                    text: detailRoot.simulacroTitle.charAt(0).toUpperCase() || "S"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 4
                                clip: true

                                Text {
                                    width: parent.width
                                    text: detailRoot.simulacroTitle
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#1F2937"
                                    elide: Text.ElideRight
                                    wrapMode: Text.NoWrap
                                }

                                Text {
                                    text: resultsModel.length + " resultado" + (resultsModel.length !== 1 ? "s" : "")
                                    font.pixelSize: 13
                                    color: "#6B7280"
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
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

                    // Warning boxes
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
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
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
                                text: "Se eliminarán todos los resultados registrados y el cuadernillo asociado de forma permanente."
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
                            var response = backend.deleteFullSimulacrum(simulacroId)
                            if (response.success) {
                                viewAlert.showAlert("Eliminado", response.message, "success")
                                mainStack.pop()
                                if (mainStack.depth > 0) {
                                    mainStack.get(0).refreshData()
                                    console.log("Lista de simulacros refrescada después de eliminar")
                                }
                            } else {
                                viewAlert.showAlert("Error", response.message, "error")
                            }
                        }
                    }
                }
            }
        }
    }

    // Popup de confirmación de eliminación de resultado
    Popup {
        id: deleteResultConfirm

        property var resultToDelete: null

        parent: detailRoot
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: Math.min(parent.width * 0.92, 440)
        height: Math.min(parent.height * 0.65, 360)

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
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
                            width: parent.width
                            text: "¿Eliminar Resultado?"
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
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        text: "✕"
                        onClicked: deleteResultConfirm.close()

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
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                radius: 24
                                color: "#09A2C8"

                                Text {
                                    anchors.centerIn: parent
                                    text: (deleteResultConfirm.resultToDelete && deleteResultConfirm.resultToDelete.studentName)
                                          ? deleteResultConfirm.resultToDelete.studentName.charAt(0).toUpperCase()
                                          : "E"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 4
                                clip: true

                                Text {
                                    width: parent.width
                                    text: (deleteResultConfirm.resultToDelete && deleteResultConfirm.resultToDelete.studentName)
                                          ? deleteResultConfirm.resultToDelete.studentName
                                          : "Estudiante"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#1F2937"
                                    elide: Text.ElideRight
                                    wrapMode: Text.NoWrap
                                }

                                Text {
                                    text: (deleteResultConfirm.resultToDelete && deleteResultConfirm.resultToDelete.global)
                                          ? "Puntaje: " + deleteResultConfirm.resultToDelete.global
                                          : "Sin puntaje"
                                    font.pixelSize: 13
                                    color: "#6B7280"
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
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
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
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
                                text: "Se eliminará permanentemente el resultado de este estudiante en el simulacro actual."
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
                        onClicked: deleteResultConfirm.close()

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
                            if (deleteResultConfirm.resultToDelete) {
                                var studentName = deleteResultConfirm.resultToDelete.studentName
                                var success = backend.deleteResult(simulacroId, studentName)

                                deleteResultConfirm.close()

                                if (success) {
                                    viewAlert.showAlert("Eliminado",
                                        "Resultado eliminado correctamente",
                                        "success")
                                    refreshResults()
                                } else {
                                    viewAlert.showAlert("Error",
                                        "No se pudo eliminar el resultado",
                                        "error")
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    // Wizard para editar (independiente del de la lista)
    SimulacrumWizard {
        id: editWizard
        alertSystem: viewAlert

        onSimulacrumUpdated: {
            console.log("✅ Wizard guardado - refrescando vista de detalle")
            loadSimulacroDetails()
        }

        onClosed: mainStack.get(0).refreshData()
    }

    // Al inicio del archivo, junto a los otros imports de components
    BoletinConfirmDialog {
        id: boletinConfirmDialog
        alertSystem: viewAlert
        totalResults: resultsModel.length

        onPdfRequested: {
            let success = backend.generateAndOpenBoletinPdf(
                simulacroId,
                boletinConfirmDialog.studentId
            )

            if (success) {
                viewAlert.showAlert("Éxito",
                    "Boletín generado y guardado correctamente",
                    "success")
            } else {
                viewAlert.showAlert("Error",
                    "No se pudo generar el boletín. Verifica los datos.",
                    "error")
            }
        }
    }

    ExportAllBoletinesDialog {
        id: exportAllConfirmDialog
        alertSystem: viewAlert
        totalResults: resultsModel.length
        simulacroId: detailRoot.simulacroId

        onExportRequested: () => {
            let success = backend.exportAllBoletines(simulacroId)

            if (success) {
                viewAlert.showAlert("¡Éxito!",
                    "Los boletines fueron generados y guardados correctamente.",
                    "success")
            } else {
                viewAlert.showAlert("Atención",
                    "No se pudieron generar todos los boletines o hubo un problema al guardar. Revisa la carpeta de descargas.",
                    "warning")
            }
        }
    }


}
