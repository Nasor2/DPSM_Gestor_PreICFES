import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: control
    property int editingStudentId: -1
    property var alertSystem: null
    signal studentUpdated()

    function openForEdit(studentObject) {
        console.log("Abriendo wizard para editar estudiante ID:", studentObject.id)
        editingStudentId = studentObject.id
        identificationField.text = studentObject.identification || "N/A"
        nameField.text = studentObject.name || ""
        schoolField.text = studentObject.school || ""
        control.open()
    }

    width: Math.min(parent.width * 0.92, 500)
    height: Math.min(parent.height * 0.60, 600)  // ← Aumentado para caber los campos
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    focus: true
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
            Layout.preferredHeight: 80
            color: "#08A929"
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
                    spacing: 4
                    Text {
                        text: "Editar Estudiante"
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                    }
                    Text {
                        text: "Actualiza la información del estudiante"
                        font.pixelSize: 12
                        color: "white"
                    }
                }

                Button {
                    implicitWidth: 36
                    implicitHeight: 36
                    text: "✕"
                    onClicked: control.close()
                    background: Rectangle { radius: 8; color: "transparent" }
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
                anchors.margins: 28
                spacing: 20

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "Identificación"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#374151"
                    }
                    TextField {
                        id: identificationField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        font.pixelSize: 14
                        placeholderText: "Ej: 1234567890"
                        maximumLength: 10
                        selectByMouse: true

                        validator: RegularExpressionValidator {
                            regularExpression: /^[0-9]{0,10}$/
                        }

                        background: Rectangle {
                            radius: 10
                            color: identificationField.activeFocus ? "white" : "#F9FAFB"
                            border.color: {
                                    if (identificationField.activeFocus) {
                                        if (identificationField.text.length > 0 && identificationField.text.length < 6) {
                                            return "#EF4444"  // ✅ Rojo si < 6 dígitos
                                        }
                                        return "#08A929"  // Verde normal
                                    }
                                    return "#E5E7EB"
                                }
                            border.width: identificationField.activeFocus ? 2 : 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        color: "#1F2937"
                        leftPadding: 16
                        rightPadding: 16

                        // Limpieza automática (igual que en ResultPopup)
                        onTextChanged: {
                            var cleaned = text.replace(/\D/g, '')
                            if (text !== cleaned) {
                                text = cleaned
                            }
                        }
                    }
                }

                // Campo Nombre
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "Nombre Completo"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#374151"
                    }
                    TextField {
                        id: nameField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        placeholderText: "Ej: Juan Pérez"
                        font.pixelSize: 14
                        leftPadding: 16
                        rightPadding: 16
                        color: "#1F2937"
                        selectByMouse: true
                        background: Rectangle {
                            radius: 10
                            color: nameField.activeFocus ? "white" : "#F9FAFB"
                            border.color: nameField.activeFocus ? "#08A929" : "#E5E7EB"
                            border.width: nameField.activeFocus ? 2 : 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Keys.onReturnPressed: {
                            if (saveBtn.enabled) saveBtn.clicked()
                        }


                    }
                }

                // Campo Colegio
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "Colegio"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#374151"
                    }
                    TextField {
                        id: schoolField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        placeholderText: "Ej: I.E. PIO XII"
                        font.pixelSize: 14
                        leftPadding: 16
                        rightPadding: 16
                        color: "#1F2937"
                        selectByMouse: true
                        background: Rectangle {
                            radius: 10
                            color: schoolField.activeFocus ? "white" : "#F9FAFB"
                            border.color: schoolField.activeFocus ? "#08A929" : "#E5E7EB"
                            border.width: schoolField.activeFocus ? 2 : 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Footer
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
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
                anchors.margins: 20
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: "Cancelar"
                    onClicked: control.close()
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
                    id: saveBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: "Guardar Cambios"
                    enabled: nameField.text.trim() !== "" &&
                             identificationField.text.trim().length >= 6 &&
                             identificationField.text.trim().length <= 10
                    background: Rectangle {
                        radius: 10
                        color: parent.enabled ? (parent.hovered ? "#06781D" : "#08A929") : "#CBD5E0"
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
                    HoverHandler {
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                    onClicked: {
                        let ident     = identificationField.text.trim()
                        let newName   = nameField.text.trim()
                        let newSchool = schoolField.text.trim()

                        // Validaciones rápidas en QML (para UX inmediato)
                        if (newName === "") {
                            alertSystem.showAlert("Campo requerido", "El nombre completo es obligatorio", "error")
                            nameField.forceActiveFocus()
                            return
                        }

                        if (ident === "" || ident.length < 6 || ident.length > 10) {
                            alertSystem.showAlert(
                                "Identificación inválida",
                                "Debe tener entre 6 y 10 dígitos numéricos.",
                                "error"
                            )
                            identificationField.forceActiveFocus()
                            identificationField.selectAll()
                            return
                        }

                        var response = backend.updateStudent(editingStudentId, newName, ident, newSchool)

                        if (response.success) {
                            alertSystem.showAlert("¡Actualizado!", response.message, "success")
                            studentUpdated()
                            control.close()
                        } else {
                            alertSystem.showAlert("Error al actualizar", response.message, "error")
                            // Puedes enfocar el campo de identificación si sospechas que es el problema
                            identificationField.forceActiveFocus()
                            identificationField.selectAll()
                        }
                    }
                }
            }
        }
    }
}
