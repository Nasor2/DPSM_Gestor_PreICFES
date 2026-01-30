// qml/views/StudentsView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: viewRoot
    objectName: "estudiantes"

    property var studentsModel: []

    function refreshData() {
        studentsModel = backend.getStudentsList()
        console.log("Estudiantes cargados:", studentsModel.length)
    }

    function filterStudents(searchText) {
        if (!searchText) return viewRoot.studentsModel

        var filtered = []
        var searchLower = searchText.toLowerCase().trim()

        for (var i = 0; i < viewRoot.studentsModel.length; i++) {
            var stu = viewRoot.studentsModel[i]
            if (!stu) continue

            if ((stu.name         || "").toLowerCase().includes(searchLower) ||
                (stu.identification || "").toLowerCase().includes(searchLower) ||
                (stu.school       || "").toLowerCase().includes(searchLower)) {
                filtered.push(stu)
            }
        }

        return filtered
    }

    Component.onCompleted: refreshData()

    readonly property color colorPrimary: "#06781D"
    readonly property color colorSecundary: "#08A929"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            radius: 20

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: colorPrimary
                }
                GradientStop {
                    position: 1.0
                    color: colorSecundary
                }
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
                        text: "Gestión de Estudiantes"
                        font.pixelSize: 26
                        font.bold: true
                        color: "white"
                    }
                    Text {
                        text: "Administra los participantes de tus evaluaciones"
                        font.pixelSize: 14
                        color: "white"
                        opacity: 0.95
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: 25
        }

        // Barra de búsqueda
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            radius: 10
            color: "white"
            border.color: searchField.activeFocus ? colorPrimary : "#E5E7EB"
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
                }
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                    placeholderText: "Buscar por nombre, identificación o colegio..."
                    placeholderTextColor: "#94A3B8"
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
                    }
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: 15
        }

        // Contenedor de la lista
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
                            text: "Nombre del estudiante"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#1F2937"
                        }

                        Text {
                                Layout.preferredWidth: 120
                                text: "Identificación"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#1F2937"
                                horizontalAlignment: Text.AlignHCenter
                                visible: viewRoot.width > 800
                            }

                            Text {
                                Layout.preferredWidth: 160
                                text: "Colegio"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#1F2937"
                                horizontalAlignment: Text.AlignHCenter
                                visible: viewRoot.width > 900
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

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical: ScrollBar {
                        x: parent.width - width + 3 // Pequeño margen a la derecha
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
                        id: studentsList
                        anchors.fill: parent
                        clip: true

                        model: filterStudents(searchField.text)

                        delegate: StudentRow {
                            width: studentsList.width
                            studentData: modelData
                            rowIndex: index
                            onEditClicked: {
                                studentWizard.openForEdit(modelData)
                            }
                            onDeleteClicked: {
                                deleteConfirm.studentId = modelData.id
                                deleteConfirm.studentName = modelData.name
                                deleteConfirm.open()
                            }
                            onClicked: {
                                studentDetailPopup.studentId = modelData.id
                                studentDetailPopup.studentName = modelData.name
                                studentDetailPopup.open()
                            }
                        }

                        // Mensaje de estado vacío → ahora sincronizado con el filtro real
                        Column {
                            visible: filterStudents(searchField.text).length === 0
                                     && searchField.text !== ""

                            anchors.centerIn: parent
                            spacing: 16

                            Rectangle {
                                width: 80
                                height: 80
                                radius: 40
                                color: "#F9FAFB"
                                border.color: "#E5E7EB"
                                border.width: 2
                                anchors.horizontalCenter: parent.horizontalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "⌕"
                                    font.pixelSize: 32
                                    font.bold: true
                                    color: colorPrimary
                                }
                            }

                            Text {
                                text: "No se encontraron estudiantes"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#1F2937"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Intenta con otro nombre, identificación o colegio"
                                font.pixelSize: 14
                                color: "#6B7280"
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 300
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // Mensaje cuando NO hay búsqueda pero tampoco hay estudiantes
                        Column {
                            visible: studentsList.count === 0 && searchField.text === ""

                            anchors.centerIn: parent
                            spacing: 16

                            Rectangle {
                                width: 80
                                height: 80
                                radius: 40
                                color: "#F9FAFB"
                                border.color: "#E5E7EB"
                                border.width: 2
                                anchors.horizontalCenter: parent.horizontalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "E"
                                    font.pixelSize: 32
                                    font.bold: true
                                    color: colorPrimary
                                }
                            }

                            Text {
                                text: "No hay estudiantes registrados"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#1F2937"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Los estudiantes se crean automáticamente al ingresar resultados"
                                font.pixelSize: 14
                                color: "#6B7280"
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 300
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }

        // Diálogo de confirmación de eliminación
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

            property int studentId: -1
            property string studentName: ""

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
                                text: "¿Eliminar Estudiante?"
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

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
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
                                    color: "#08A929"

                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            if (!deleteConfirm.studentName)
                                                return "?"
                                            return deleteConfirm.studentName.charAt(
                                                        0).toUpperCase()
                                        }
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "white"
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        text: deleteConfirm.studentName
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#1F2937"
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: "Estudiante activo"
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
                                    text: "Se eliminarán todos los resultados asociados a este estudiante de forma permanente."
                                    font.pixelSize: 13
                                    color: "#92400E"
                                    wrapMode: Text.WordWrap
                                    lineHeight: 1.3
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
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
                            text: "Sí, Eliminar"

                            background: Rectangle {
                                radius: 10
                                color: parent.hovered ? "#DC2626" : "#EF4444"
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
                                cursorShape: Qt.PointingHandCursor
                            }

                            onClicked: {
                                deleteConfirm.close()
                                var response = backend.deleteStudent(
                                            deleteConfirm.studentId)
                                if (response.success) {
                                    viewAlert.showAlert("Eliminado",
                                                        response.message,
                                                        "success")
                                    viewRoot.refreshData()
                                } else {
                                    viewAlert.showAlert("Error",
                                                        response.message,
                                                        "error")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Componentes auxiliares
    CustomAlert {
        id: viewAlert
        anchors.centerIn: parent
        z: 3
    }

    StudentWizarad {
        id: studentWizard
        alertSystem: viewAlert
        onStudentUpdated: viewRoot.refreshData()
    }

    StudentDetailPopup {
        id: studentDetailPopup
    }
}
