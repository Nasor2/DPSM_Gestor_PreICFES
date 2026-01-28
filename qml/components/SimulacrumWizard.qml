import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: control

    property bool isEditing: false
    property int editingSimId: -1
    property string savedDate: ""
    property var alertSystem: null
    property date currentDate: new Date()


    signal simulacrumUpdated()

    function resetForm() {
        // Limpia campos principales
        nameField.text = ""
        bookletField.text = ""
        currentDate = new Date()
        savedDate = ""

        // Limpia todos los TextField de distribución de preguntas
        for (var i = 0; i < subjectsRepeater.count; ++i) {
            var delegateItem = subjectsRepeater.itemAt(i)
            if (delegateItem && delegateItem.questionValue !== undefined) {
                delegateItem.questionValue = ""
            }
        }
    }

    function openForCreate() {

        resetForm()

        isEditing = false
        editingSimId = -1
        nameField.text = ""
        bookletField.text = ""
        currentDate = new Date()
        subjectsRepeater.model = [{
                                      "tag": "LEC",
                                      "name": "Lectura Crítica",
                                      "val": 41,
                                      "color": "#5C61F2",
                                      "bgColor": "#EEF2FF"
                                  }, {
                                      "tag": "MAT",
                                      "name": "Matemáticas",
                                      "val": 50,
                                      "color": "#F59E0B",
                                      "bgColor": "#FEF3C7"
                                  }, {
                                      "tag": "SOC",
                                      "name": "Sociales",
                                      "val": 50,
                                      "color": "#10B981",
                                      "bgColor": "#D1FAE5"
                                  }, {
                                      "tag": "NAT",
                                      "name": "Naturales",
                                      "val": 58,
                                      "color": "#8B5CF6",
                                      "bgColor": "#EDE9FE"
                                  }, {
                                      "tag": "ING",
                                      "name": "Inglés",
                                      "val": 55,
                                      "color": "#EF4444",
                                      "bgColor": "#FEE2E2"
                                  }]
        control.open()
    }

    function openForEdit(simObject) {
        console.log("🔧 Abriendo wizard en modo edición para ID:", simObject.id)

        resetForm()

        isEditing = true
        editingSimId = simObject.id
        nameField.text = simObject.name
        savedDate = simObject.date
        currentDate = new Date(simObject.date)

        // Cargar booklet
        var bookletId = backend.getSimulacrumData(editingSimId).bookletId
        var info = backend.getBookletData(bookletId)
        bookletField.text = info.name

        // Cargar totals en repeater
        subjectsRepeater.model = [
            { "tag": "LEC", "name": "Lectura Crítica", "val": info.tL, "color": "#5C61F2", "bgColor": "#EEF2FF" },
            { "tag": "MAT", "name": "Matemáticas", "val": info.tM, "color": "#F59E0B", "bgColor": "#FEF3C7" },
            { "tag": "SOC", "name": "Sociales", "val": info.tS, "color": "#10B981", "bgColor": "#D1FAE5" },
            { "tag": "NAT", "name": "Naturales", "val": info.tN, "color": "#8B5CF6", "bgColor": "#EDE9FE" },
            { "tag": "ING", "name": "Inglés", "val": info.tI, "color": "#EF4444", "bgColor": "#FEE2E2" }
        ]

        control.open()
    }

    width: Math.min(parent.width * 0.92, 640)
    height: Math.min(parent.height * 0.85, 720)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2 - parent.height * 0.02
    modal: true
    focus: true
    padding: 0

    Overlay.modal: Rectangle {
        color: "#80000000"
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 200
        }
        NumberAnimation {
            property: "scale"
            from: 0.92
            to: 1
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            to: 0
            duration: 150
        }
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
            Layout.preferredHeight: 90
            color: isEditing ? "#08A979" : "#0888A9"
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
                    height: 50
                    radius: 2
                    color: "white"
                    opacity: 0.8

                }

                Column {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: isEditing ? "Editar Simulacro" : "Nuevo Simulacro"
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }

                    Text {
                        text: isEditing ? "Modifica la información del registro" : "Configura los parámetros de evaluación"
                        font.pixelSize: 13
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

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }


                }
            }
        }

        // Content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            leftPadding: 0
            rightPadding: 0

            ColumnLayout {
                width: control.width
                spacing: 24

                Item {
                    height: 10
                }

                // Campos Nombre y Fecha en dos columnas
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 28
                    Layout.rightMargin: 28
                    spacing: 12

                    // Campo Nombre
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 115
                        radius: 12
                        color: "#F8FAFC"
                        border.color: "#E2E8F0"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 10

                            RowLayout {
                                spacing: 8

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 6
                                    color: isEditing ? "#E7FEF7" : "#E7F9FE"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "S"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: isEditing ? "#08A979" : "#0888A9"
                                    }
                                }

                                Text {
                                    text: "Nombre del Simulacro"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#1F2937"
                                }
                            }

                            TextField {
                                id: nameField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                placeholderText: "Ej: Simulacro Mensual Enero"
                                placeholderTextColor: "#94A3B8"
                                font.pixelSize: 15
                                leftPadding: 16
                                rightPadding: 16
                                color: "#1F2937"

                                background: Rectangle {
                                    radius: 10
                                    color: nameField.activeFocus ? "white" : "#FAFBFC"
                                    border.color: nameField.activeFocus ? (isEditing ? "#08A979" : "#0888A9") : "#E2E8F0"
                                    border.width: nameField.activeFocus ? 2 : 1
                                    Behavior on border.color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Campo Fecha
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 115
                        radius: 12
                        color: "#F8FAFC"
                        border.color: "#E2E8F0"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 10

                            RowLayout {
                                spacing: 8
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 6
                                    color: isEditing ? "#E7FEF7" : "#E7F9FE"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "📅"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: isEditing ? "#08A979" : "#0888A9"
                                    }
                                }
                                Text {
                                    text: "Fecha del Simulacro"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#1F2937"
                                }
                            }

                            TextField {
                                id: dateDisplay
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                placeholderText: "dd/MM/yyyy"
                                font.pixelSize: 15
                                color: "#1F2937"
                                readOnly: true
                                text: Qt.formatDate(currentDate, "dd/MM/yyyy")

                                background: Rectangle {
                                    radius: 10
                                    color: dateDisplay.activeFocus ? "white" : "#FAFBFC"
                                    border.color: dateDisplay.activeFocus ? (isEditing ? "#08A979" : "#0888A9") : "#E2E8F0"
                                    border.width: dateDisplay.activeFocus ? 2 : 1
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: datePicker.open()
                                }
                            }
                        }
                    }
                }

                // Campo Cuadernillo
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 28
                    Layout.rightMargin: 28
                    Layout.preferredHeight: 115
                    radius: 12
                    color: "#F8FAFC"
                    border.color: "#E2E8F0"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        RowLayout {
                            spacing: 8

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 6
                                color: isEditing ? "#E7FEF7" : "#E7F9FE"

                                Text {
                                    anchors.centerIn: parent
                                    text: "C"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: isEditing ? "#08A979" : "#0888A9"
                                }
                            }

                            Text {
                                text: "Referencia de los Cuadernillos"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#1F2937"
                            }
                        }

                        TextField {
                            id: bookletField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            placeholderText: "Ej: S11-A y S11-B"
                            placeholderTextColor: "#94A3B8"
                            font.pixelSize: 15
                            leftPadding: 16
                            rightPadding: 16
                            color: "#1F2937"

                            background: Rectangle {
                                radius: 10
                                color: bookletField.enabled ? (bookletField.activeFocus ? "white" : "#FAFBFC") : "#F1F5F9"
                                border.color: bookletField.activeFocus ? (isEditing ? "#08A979" : "#0888A9") : "#E2E8F0"
                                border.width: bookletField.activeFocus ? 2 : 1
                                Behavior on border.color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }
                            }
                        }
                    }
                }

                // Distribución de Preguntas
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 28
                    Layout.rightMargin: 28
                    spacing: 16

                    RowLayout {
                        spacing: 8

                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: isEditing ? "#E7FEF7" : "#E7F9FE"

                            Text {
                                anchors.centerIn: parent
                                text: "#"
                                font.pixelSize: 14
                                font.bold: true
                                color: isEditing ? "#08A979" : "#0888A9"
                            }
                        }

                        Text {
                            text: "Distribución de Preguntas Totales"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1F2937"
                        }
                    }

                    Grid {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 12

                        Repeater {
                            id: subjectsRepeater

                            delegate: Rectangle {
                                id: subjectDelegateRoot
                                width: (parent.width - parent.columnSpacing) / 2
                                height: 70
                                radius: 10
                                color: "white"
                                border.color: "#E2E8F0"
                                border.width: 1

                                property alias questionValue: qInputFile.text

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 12

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 8
                                        color: modelData.bgColor

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.tag
                                            font.pixelSize: 11
                                            font.bold: true
                                            color: modelData.color
                                        }
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 3

                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "#1F2937"
                                        }

                                        Text {
                                            text: modelData.tag
                                            font.pixelSize: 11
                                            color: "#94A3B8"
                                        }
                                    }

                                    TextField {
                                        id: qInputFile
                                        Layout.preferredWidth: 80
                                        Layout.preferredHeight: 44
                                        text: isEditing ? modelData.val.toString() : ""
                                        placeholderText: isEditing ? "" : ("Ej: " + modelData.val)
                                        horizontalAlignment: Text.AlignHCenter
                                        font.pixelSize: 15
                                        font.bold: true
                                        selectByMouse: true
                                        validator: IntValidator {
                                            bottom: 1
                                            top: 200
                                        }
                                        color: enabled ? "#1F2937" : "#94A3B8"
                                        placeholderTextColor: "#94A3B8"

                                        background: Rectangle {
                                            radius: 8
                                            color: parent.enabled ? (parent.activeFocus ? "white" : "#F8FAFC") : "#F1F5F9"
                                            border.color: parent.activeFocus ? modelData.color : "#E2E8F0"
                                            border.width: parent.activeFocus ? 2 : 1
                                            Behavior on border.color {
                                                ColorAnimation {
                                                    duration: 150
                                                }
                                            }
                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 150
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    height: 20
                }
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
                anchors.margins: 28
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: "Cancelar"
                    onClicked: control.close()

                    background: Rectangle {
                        radius: 10
                        color: parent.hovered ? "#F1F5F9" : "white"
                        border.color: "#E2E8F0"
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
                        font.bold: true
                        color: "#64748B"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: isEditing ? "Guardar Cambios" : "Crear Simulacro"
                    enabled: nameField.text !== ""
                             && (isEditing || bookletField.text !== "")

                    background: Rectangle {
                        radius: 10
                        color: {
                            if (!parent.enabled) return "#CBD5E0"

                            if (parent.hovered){
                                return isEditing ? "#057050" : "#055B70"
                            } else {
                                return isEditing ? "#08A979" : "#0888A9"
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    HoverHandler {
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    onClicked: {
                        var qCount = []
                        for (var i = 0; i < 5; i++) {
                            var val = parseInt(subjectsRepeater.itemAt(i).questionValue)
                            qCount.push(isNaN(val) ? 0 : val)
                        }

                        var dateStr = Qt.formatDate(currentDate, "yyyy-MM-dd")

                        if (isEditing) {
                            console.log("💾 Guardando cambios para ID:", editingSimId)
                            var response = backend.updateFullSimulacrum(
                                    editingSimId, nameField.text, dateStr, bookletField.text,
                                    qCount[0], qCount[1], qCount[2], qCount[3], qCount[4]
                                )
                            if (response.success === true) {
                                alertSystem.showAlert("¡Actualizado!", response.message, "success")
                                console.log("✅ Emitiendo señal simulacrumUpdated")
                                simulacrumUpdated()
                                control.close()
                            } else {
                                alertSystem.showAlert("No se pudo actualizar", response.message, "error")
                                if (response.errorCode === "duplicate_name") {
                                    nameField.forceActiveFocus()
                                    nameField.selectAll()
                                }
                            }
                        } else {
                            var response = backend.createFullSimulacrum(
                                nameField.text,
                                dateStr,
                                bookletField.text, qCount[0], qCount[1], qCount[2], qCount[3], qCount[4]
                            )

                            if (response.success === true) {
                                alertSystem.showAlert("¡Creado con éxito!", response.message, "success")
                                control.close()
                            } else {
                                alertSystem.showAlert("No se pudo crear", response.message, "error")
                                if (response.errorCode === "duplicate_name") {
                                    nameField.forceActiveFocus()
                                    nameField.selectAll()
                                } else if (response.errorCode === "invalid_data") {
                                    nameField.forceActiveFocus()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    DatePicker {
        id: datePicker
        parent: Overlay.overlay
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        selectedDate: currentDate

        onDateAccepted: function(selected) {
            currentDate = selected
            dateDisplay.text = Qt.formatDate(selected, "dd/MM/yyyy")
        }
    }

    onClosed: {
        resetForm()
    }
}
