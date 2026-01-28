// components/ResultPopup.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: control

    property bool isEditing: false
    property int currentSimulacroId: -1
    property var maxValues: ({
                                 "mat": 0,
                                 "lec": 0,
                                 "soc": 0,
                                 "nat": 0,
                                 "ing": 0
                             })
    property var suggestions: []
    property var alertSystem: null

    signal saved

    function openForAdd(simId, maxVals, studentList) {
        isEditing = false
        currentSimulacroId = simId
        maxValues = maxVals
        suggestions = studentList
        clearFields()
        control.open()
    }

    function openForEdit(simId, maxVals, resultData) {
        isEditing = true
        currentSimulacroId = simId
        maxValues = maxVals
        suggestions = []

        studentCombo.editText = resultData.studentName
        lecIn.text = resultData.l
        matIn.text = resultData.m
        socIn.text = resultData.s
        natIn.text = resultData.n
        ingIn.text = resultData.i

        for (var i = 0; i < subjectRepeater.count; i++) {
            var item = subjectRepeater.itemAt(i)
            if (item) {
                item.refreshFromHidden()
            }
        }

        control.open()
    }

    function clearFields() {
        studentCombo.editText = ""
        matIn.text = ""
        lecIn.text = ""
        socIn.text = ""
        natIn.text = ""
        ingIn.text = ""

        for (var i = 0; i < subjectRepeater.count; i++) {
            var item = subjectRepeater.itemAt(i)
            if (item) {
                item.refreshFromHidden()
            }
        }
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
                        text: isEditing ? "Editar Resultado" : "Nuevo Resultado"
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }

                    Text {
                        text: isEditing ? "Modifica las respuestas correctas del estudiante" : "Registra las respuestas correctas del estudiante"
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

                // Info card - Estudiante automático
                Rectangle {
                    visible: !isEditing
                    Layout.fillWidth: true
                    Layout.leftMargin: 28
                    Layout.rightMargin: 28
                    Layout.preferredHeight: infoStudentColumn.implicitHeight + 32
                    radius: 12
                    color: "#EFF6FF"
                    border.color: "#BFDBFE"
                    border.width: 1

                    ColumnLayout {
                        id: infoStudentColumn
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        RowLayout {
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 8
                                color: "#DBEAFE"

                                Text {
                                    anchors.centerIn: parent
                                    text: "i"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#2563EB"
                                }
                            }

                            Text {
                                text: "Estudiantes Nuevos"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#1E3A8A"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.leftMargin: 52
                            text: "Si el nombre del estudiante no existe en el sistema, se creará automáticamente al guardar el resultado."
                            font.pixelSize: 13
                            color: "#1E40AF"
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }
                    }
                }

                // Campo Estudiante
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
                                    text: "A"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: isEditing ? "#08A979" : "#0888A9"
                                }
                            }

                            Text {
                                text: "Nombre del Estudiante"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#1F2937"
                            }
                        }

                        ComboBox {
                            id: studentCombo
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            editable: true
                            model: control.suggestions
                            enabled: !isEditing
                            font.pixelSize: 15

                            background: Rectangle {
                                radius: 10
                                color: studentCombo.enabled ? (studentCombo.activeFocus ? "white" : "#FAFBFC") : "#F1F5F9"
                                border.color: studentCombo.activeFocus ? (isEditing ? "#08A979" : "#0888A9") : "#E2E8F0"
                                border.width: studentCombo.activeFocus ? 2 : 1
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

                            contentItem: TextInput {
                                text: studentCombo.editText
                                font: studentCombo.font
                                color: studentCombo.enabled ? "#1F2937" : "#94A3B8"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 16
                                rightPadding: studentCombo.indicator.width + studentCombo.spacing
                                selectByMouse: true
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
                            text: "Respuestas Correctas"
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
                            id: subjectRepeater
                            model: [{
                                    "tag": "LEC",
                                    "name": "Lectura Crítica",
                                    "color": "#5C61F2",
                                    "bgColor": "#EEF2FF",
                                    "field": lecIn,
                                    "max": maxValues.lec
                                }, {
                                    "tag": "MAT",
                                    "name": "Matemáticas",
                                    "color": "#F59E0B",
                                    "bgColor": "#FEF3C7",
                                    "field": matIn,
                                    "max": maxValues.mat
                                }, {
                                    "tag": "SOC",
                                    "name": "Sociales",
                                    "color": "#10B981",
                                    "bgColor": "#D1FAE5",
                                    "field": socIn,
                                    "max": maxValues.soc
                                }, {
                                    "tag": "NAT",
                                    "name": "Naturales",
                                    "color": "#8B5CF6",
                                    "bgColor": "#EDE9FE",
                                    "field": natIn,
                                    "max": maxValues.nat
                                }, {
                                    "tag": "ING",
                                    "name": "Inglés",
                                    "color": "#EF4444",
                                    "bgColor": "#FEE2E2",
                                    "field": ingIn,
                                    "max": maxValues.ing
                                }]

                            delegate: Rectangle {
                                id: delegateRoot
                                width: (parent.width - parent.columnSpacing) / 2
                                height: 70
                                radius: 10
                                color: "white"
                                border.color: "#E2E8F0"
                                border.width: 1

                                property alias inputText: fieldInput.text

                                function refreshFromHidden() {
                                    fieldInput.text = modelData.field.text
                                }

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
                                            text: "Máx: " + modelData.max
                                            font.pixelSize: 11
                                            color: "#94A3B8"
                                        }
                                    }

                                    TextField {
                                        id: fieldInput
                                        Layout.preferredWidth: 80
                                        Layout.preferredHeight: 44
                                        horizontalAlignment: Text.AlignHCenter
                                        font.pixelSize: 17
                                        font.bold: true
                                        selectByMouse: true
                                        validator: IntValidator {
                                            bottom: 0
                                            top: modelData.max
                                        }
                                        color: "#1F2937"
                                        placeholderText: "0"
                                        placeholderTextColor: "#94A3B8"

                                        background: Rectangle {
                                            radius: 8
                                            color: parent.activeFocus ? "white" : "#F8FAFC"
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

                                        Component.onCompleted: {
                                            text = modelData.field.text
                                        }

                                        onTextChanged: {
                                            if (activeFocus) {
                                                modelData.field.text = text
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        TextField {
                            id: lecIn
                            visible: false
                        }
                        TextField {
                            id: matIn
                            visible: false
                        }
                        TextField {
                            id: socIn
                            visible: false
                        }
                        TextField {
                            id: natIn
                            visible: false
                        }
                        TextField {
                            id: ingIn
                            visible: false
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
                    text: isEditing ? "Guardar Cambios" : "Guardar Resultado"
                    enabled: studentCombo.editText !== ""

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
                        let l = parseInt(lecIn.text) || 0
                        let m = parseInt(matIn.text) || 0
                        let soc = parseInt(socIn.text) || 0
                        let nat = parseInt(natIn.text) || 0
                        let ing = parseInt(ingIn.text) || 0

                        let response
                        if (isEditing) {
                            response = backend.updateStudentResult(
                                currentSimulacroId, studentCombo.editText, l, m, soc, nat, ing
                            )
                        } else {
                            response = backend.addResult(
                                currentSimulacroId, studentCombo.editText, l, m, soc, nat, ing
                            )
                        }

                        if (response.success === true) {
                            alertSystem.showAlert("¡Guardado!", response.message, "success")
                            control.saved()
                            control.close()
                        } else {
                            alertSystem.showAlert("Error al guardar", response.message, "error")
                        }
                    }
                }
            }
        }
    }
}
