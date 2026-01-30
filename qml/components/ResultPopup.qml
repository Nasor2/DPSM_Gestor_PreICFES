// components/ResultPopup.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: control

    property bool isEditing: false
    property int currentSimulacroId: -1
    property string currentIdentification: ""
    property string currentName: ""
    property string currentSchool: ""
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

        currentIdentification = resultData.identification || ""
        currentName = resultData.studentName || ""
        currentSchool = resultData.school || ""

        identificationCombo.text = currentIdentification
        nameField.text = currentName
        schoolCombo.text = currentSchool

        lecIn.text = resultData.l || "0"
        matIn.text = resultData.m || "0"
        socIn.text = resultData.s || "0"
        natIn.text = resultData.n || "0"
        ingIn.text = resultData.i || "0"

        refreshSubjectFields()
        control.open()
    }

    function clearFields() {
        identificationCombo.text = ""
        nameField.text = ""
        schoolCombo.text = ""
        lecIn.text = ""
        matIn.text = ""
        socIn.text = ""
        natIn.text = ""
        ingIn.text = ""
        refreshSubjectFields()
    }

    function refreshSubjectFields() {
        for (var i = 0; i < subjectRepeater.count; i++) {
            var item = subjectRepeater.itemAt(i)
            if (item)
                item.refreshFromHidden()
        }
    }

    function findStudentByIdentification(identification) {
        for (var i = 0; i < suggestions.length; i++) {
            var student = suggestions[i]
            if (student.identification === identification) {
                return student
            }
        }
        return null
    }

    /*
    function tryAutoComplete() {
        var student = findStudentByIdentification(identificationCombo.editText)
        if (student) {
            nameField.text = student.name
            schoolCombo.text = student.school

            // Buscar índice del colegio en el modelo
            var schoolIndex = schoolCombo.model.indexOf(student.school)
            if (schoolIndex !== -1) {
                schoolCombo.currentIndex = schoolIndex
            } else {
                schoolCombo.currentIndex = 3 // "Otro"
                schoolCombo.text = student.school
            }
        }
    }*/
    function tryAutoComplete() {
        var student = findStudentByIdentification(identificationCombo.editText)
        if (student) {
            nameField.text = student.name || ""  // ✅ Fallback
            schoolCombo.text = student.school || ""  // ✅ Fallback
        }
    }


    function updateSuggestions() {
        filteredSuggestions.clear()
        var filter = identificationCombo.text.toLowerCase()

        console.log("Filtrando con:", filter)
        console.log("Total sugerencias originales:", suggestions.length)

        for (var i = 0; i < control.suggestions.length; i++) {
            var student = control.suggestions[i]
            if (student.identification.toLowerCase().indexOf(filter) !== -1) {
                console.log("Agregando:", student.identification, student.name, student.school)
                filteredSuggestions.append({
                    "identification": student.identification,
                    "name": student.name,
                    "school": student.school
                })
                if (filteredSuggestions.count >= 10) break
            }
        }
    }

    /*
    function selectSuggestion(index) {
        var item = filteredSuggestions.get(index)
        identificationCombo.text = item.identification
        nameField.text = item.name

        var schoolIndex = schoolCombo.model.indexOf(item.school)
        if (schoolIndex !== -1) {
            schoolCombo.currentIndex = schoolIndex
        } else {
            schoolCombo.currentIndex = 3
            schoolCombo.editText = item.school
        }

        suggestionsPopup.close()
        nameField.forceActiveFocus()
    }*/

    function selectSuggestion(index) {
        if (index < 0 || index >= filteredSuggestions.count) return;

        var item = filteredSuggestions.get(index)
        identificationCombo.text = item.identification
        nameField.text = item.name || ""
        schoolCombo.text = item.school || ""

        console.log("ident:", item.identification, "name:", item.name, "school:", item.school)

        suggestionsPopup.close()
        nameField.forceActiveFocus()
    }

    function updateSchoolSuggestions() {
        filteredSchoolSuggestions.clear()
        var filter = schoolCombo.text.toLowerCase().trim()

        var predefinedSchools = [
            "I. E. PIO XII",
            "I. E. LEÓN XIII",
            "I. E. T. A. DE"
        ]

        // Siempre agregar predefinidas (incluso si no hay filtro)
        for (var i = 0; i < predefinedSchools.length; i++) {
            var schoolName = predefinedSchools[i]
            if (filter === "" || schoolName.toLowerCase().indexOf(filter) !== -1) {
                filteredSchoolSuggestions.append({ "school": schoolName })
            }
        }

        // Luego colegios de estudiantes (solo si coinciden o no hay filtro)
        var addedSchools = {}
        for (var j = 0; j < control.suggestions.length; j++) {
            var student = control.suggestions[j]
            var school = student.school
            if (school && school !== "" && !addedSchools[school]) {
                if (filter === "" || school.toLowerCase().indexOf(filter) !== -1) {
                    var isPredefined = predefinedSchools.includes(school)
                    if (!isPredefined) {
                        filteredSchoolSuggestions.append({ "school": school })
                        addedSchools[school] = true
                    }
                }
            }
            if (filteredSchoolSuggestions.count >= 10) break
        }
    }

    function selectSchoolSuggestion(index) {
        var item = filteredSchoolSuggestions.get(index)
        schoolCombo.text = item.school
        schoolSuggestionsPopup.close()
    }

    width: Math.min(parent.width * 0.92, 640)
    height: Math.min(parent.height * 0.85, 740)
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
                            text: "Si la identificación no existe, se creará un nuevo estudiante automáticamente con los datos ingresados."
                            font.pixelSize: 13
                            color: "#1E40AF"
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }
                    }
                }

                // Campo Identificacion
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 28
                    Layout.rightMargin: 28
                    spacing: 12

                    // Campo Identificación
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
                                        text: "#"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: isEditing ? "#08A979" : "#0888A9"
                                    }
                                }

                                Text {
                                    text: "Identificación"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#1F2937"
                                }
                            }

                            // ✅ TextField simple (no ComboBox)
                            TextField {
                                id: identificationCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                enabled: !isEditing
                                font.pixelSize: 15
                                placeholderText: "Ej: 1234567890"
                                maximumLength: 10
                                selectByMouse: true

                                property alias editText: identificationCombo.text

                                validator: RegularExpressionValidator {
                                    regularExpression: /^[0-9]{0,10}$/
                                }

                                background: Rectangle {
                                    radius: 10
                                    color: identificationCombo.enabled ? (identificationCombo.activeFocus ? "white" : "#FAFBFC") : "#F1F5F9"
                                    border.color: {
                                                if (!identificationCombo.enabled) return "#E2E8F0"
                                                if (identificationCombo.activeFocus) {
                                                    // Si está enfocado y tiene texto inválido → rojo
                                                    if (identificationCombo.text.length > 0 && identificationCombo.text.length < 6) {
                                                        return "#EF4444"  // Rojo
                                                    }
                                                    return isEditing ? "#08A979" : "#0888A9"  // Verde/Azul normal
                                                }
                                                return "#E2E8F0"  // Gris normal
                                            }
                                    border.width: identificationCombo.activeFocus ? 2 : 1
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                color: identificationCombo.enabled ? "#1F2937" : "#94A3B8"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 16
                                rightPadding: 16

                                onActiveFocusChanged: {
                                    if (!activeFocus) {
                                        //tryAutoComplete()
                                        suggestionsPopup.close()
                                    }
                                }

                                onTextChanged: {
                                    var cleaned = text.replace(/\D/g, '')
                                    if (text !== cleaned) {
                                        text = cleaned
                                    }


                                    if (activeFocus && text.length > 0) {
                                        updateSuggestions()
                                        if (suggestionsList.count > 0) {
                                            suggestionsPopup.open()
                                        }
                                    } else {
                                        suggestionsPopup.close()
                                    }
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Down && suggestionsPopup.opened) {
                                        suggestionsList.incrementCurrentIndex()
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up && suggestionsPopup.opened) {
                                        suggestionsList.decrementCurrentIndex()
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (suggestionsPopup.opened && suggestionsList.currentIndex >= 0) {
                                            selectSuggestion(suggestionsList.currentIndex)
                                            event.accepted = true
                                        } else {
                                            tryAutoComplete()
                                        }
                                    } else if (event.key === Qt.Key_Escape) {
                                        suggestionsPopup.close()
                                        event.accepted = true
                                    }
                                }

                                Popup {
                                    id: suggestionsPopup
                                    y: parent.height + 4
                                    width: parent.width
                                    height: Math.min(suggestionsList.contentHeight + 8, 200)
                                    padding: 4

                                    background: Rectangle {
                                        color: "white"
                                        radius: 8
                                        border.color: "#CBD5E0"
                                        border.width: 2
                                    }

                                    contentItem: ListView {
                                        id: suggestionsList
                                        clip: true
                                        model: ListModel { id: filteredSuggestions }

                                        ScrollBar.vertical: ScrollBar {
                                            policy: ScrollBar.AsNeeded
                                        }

                                        delegate: ItemDelegate {
                                            width: ListView.view.width
                                            height: 40
                                            highlighted: ListView.isCurrentItem

                                            // ¡Propiedades explícitas para evitar problemas de scope!
                                            property string ident: model ? model.identification : ""
                                            property string nombre: model ? model.name : ""
                                            property string cole: model ? model.school : ""

                                            background: Rectangle {
                                                color: parent.highlighted || parent.hovered ? "#F1F5F9" : "transparent"
                                                radius: 6
                                            }

                                            contentItem: RowLayout {
                                                spacing: 12

                                                Text {
                                                    text: ident
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                    color: "#1F2937"
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: model.name
                                                    font.pixelSize: 13
                                                    color: "#6B7280"
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            onClicked: {
                                                identificationCombo.text = ident
                                                nameField.text = nombre || ""
                                                schoolCombo.text = cole || ""

                                                console.log("Clic exitoso → ident:", ident,
                                                            "name:", nombre,
                                                            "school:", cole)

                                                suggestionsPopup.close()
                                                nameField.forceActiveFocus()
                                            }
                                        }
                                    }
                                }
                            }



                        }
                    }

                    // Campo Colegio
                    // Campo Colegio
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
                                        text: "🏫"
                                        font.pixelSize: 14
                                    }
                                }

                                Text {
                                    text: "Colegio"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#1F2937"
                                }
                            }

                            // ✅ TextField con autocompletado
                            TextField {
                                id: schoolCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                enabled: !isEditing
                                font.pixelSize: 15
                                placeholderText: "Selecciona o escribe el colegio"
                                selectByMouse: true

                                property alias editText: schoolCombo.text

                                background: Rectangle {
                                    radius: 10
                                    color: schoolCombo.enabled ? (schoolCombo.activeFocus ? "white" : "#FAFBFC") : "#F1F5F9"
                                    border.color: schoolCombo.activeFocus ? (isEditing ? "#08A979" : "#0888A9") : "#E2E8F0"
                                    border.width: schoolCombo.activeFocus ? 2 : 1
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                color: schoolCombo.enabled ? "#1F2937" : "#94A3B8"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 16
                                rightPadding: 16

                                onActiveFocusChanged: {
                                    if (activeFocus) {
                                        // Abrir siempre el popup al ganar foco
                                        updateSchoolSuggestions()
                                        schoolSuggestionsPopup.open()
                                    } else {
                                        schoolSuggestionsPopup.close()
                                    }
                                }

                                onTextChanged: {
                                    if (activeFocus) {
                                        updateSchoolSuggestions()
                                        if (schoolSuggestionsList.count > 0) {
                                            schoolSuggestionsPopup.open()
                                        } else {
                                            schoolSuggestionsPopup.close()
                                        }
                                    }
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Down && schoolSuggestionsPopup.opened) {
                                        schoolSuggestionsList.incrementCurrentIndex()
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up && schoolSuggestionsPopup.opened) {
                                        schoolSuggestionsList.decrementCurrentIndex()
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (schoolSuggestionsPopup.opened && schoolSuggestionsList.currentIndex >= 0) {
                                            selectSchoolSuggestion(schoolSuggestionsList.currentIndex)
                                            event.accepted = true
                                        }
                                    } else if (event.key === Qt.Key_Escape) {
                                        schoolSuggestionsPopup.close()
                                        event.accepted = true
                                    }
                                }

                                Popup {
                                    id: schoolSuggestionsPopup
                                    y: parent.height + 4
                                    width: parent.width
                                    height: Math.min(schoolSuggestionsList.contentHeight + 8, 200)
                                    padding: 4

                                    background: Rectangle {
                                        color: "white"
                                        radius: 8
                                        border.color: "#CBD5E0"
                                        border.width: 2
                                    }

                                    contentItem: ListView {
                                        id: schoolSuggestionsList
                                        clip: true
                                        model: ListModel { id: filteredSchoolSuggestions }

                                        ScrollBar.vertical: ScrollBar {
                                            policy: ScrollBar.AsNeeded
                                        }

                                        delegate: ItemDelegate {
                                            width: ListView.view.width
                                            height: 40
                                            highlighted: ListView.isCurrentItem

                                            background: Rectangle {
                                                color: parent.highlighted || parent.hovered ? "#F1F5F9" : "transparent"
                                                radius: 6
                                            }

                                            contentItem: Text {
                                                text: model.school
                                                font.pixelSize: 14
                                                color: "#1F2937"
                                                verticalAlignment: Text.AlignVCenter
                                                leftPadding: 12
                                            }

                                            onClicked: selectSchoolSuggestion(index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                // Campo Estudiante
                // Campo Nombre Completo
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
                                text: "Nombre Completo"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#1F2937"
                            }
                        }

                        TextField {
                            id: nameField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            enabled: !isEditing
                            font.pixelSize: 15
                            placeholderText: "Ej: Juan Pérez García"
                            selectByMouse: true

                            background: Rectangle {
                                radius: 10
                                color: nameField.enabled ? (nameField.activeFocus ? "white" : "#FAFBFC") : "#F1F5F9"
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

                            color: nameField.enabled ? "#1F2937" : "#94A3B8"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 16
                            rightPadding: 16
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
                    enabled: identificationCombo.editText !== ""
                             && nameField.text !== ""

                    background: Rectangle {
                        radius: 10
                        color: {
                            if (!parent.enabled)
                                return "#CBD5E0"

                            if (parent.hovered) {
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
                        let ident  = identificationCombo.text.trim()
                        let name   = nameField.text.trim()
                        let school = schoolCombo.text.trim()

                        // Validaciones básicas en frontend (UX rápida)
                        if (ident === "" || name === "") {
                            alertSystem.showAlert("Campos requeridos", "Identificación y Nombre son obligatorios", "error")
                            return
                        }

                        if (ident.length < 6 || ident.length > 10) {
                            alertSystem.showAlert(
                                "Identificación inválida",
                                "La identificación debe tener entre 6 y 10 dígitos numéricos.",
                                "error"
                            )
                            identificationCombo.forceActiveFocus()
                            identificationCombo.selectAll()
                            return
                        }

                        // Guardar directamente
                        let l   = parseInt(lecIn.text)   || 0
                        let m   = parseInt(matIn.text)   || 0
                        let soc = parseInt(socIn.text)   || 0
                        let nat = parseInt(natIn.text)   || 0
                        let ing = parseInt(ingIn.text)   || 0

                        let response
                        if (isEditing) {
                            response = backend.updateStudentResult(
                                currentSimulacroId, ident, name, school, l, m, soc, nat, ing
                            )
                        } else {
                            response = backend.addResult(
                                currentSimulacroId, ident, name, school, l, m, soc, nat, ing
                            )
                        }

                        if (response.success === true) {
                            alertSystem.showAlert("¡Guardado!", response.message, "success")
                            control.saved()
                            control.close()
                        } else {
                            // Mejoramos un poco el mensaje según lo que devuelva el backend
                            let msg = response.message
                            if (msg.includes("ya tiene resultados registrados")) {
                                alertSystem.showAlert(
                                    "Ya registrado en este simulacro",
                                    "Este estudiante ya tiene calificaciones en este simulacro.\n" +
                                    "Si quieres modificarlas, usa el modo edición.",
                                    "warning"
                                )
                            } else if (msg.includes("exceden el máximo permitido")) {
                                alertSystem.showAlert("Valores inválidos", msg, "error")
                            } else {
                                alertSystem.showAlert("Error al guardar", msg, "error")
                            }
                        }
                    }
                }
            }
        }
    }
}
