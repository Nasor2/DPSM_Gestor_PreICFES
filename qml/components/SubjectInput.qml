// SubjectInput.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    property alias text: field.text
    property string label: ""
    property int max: 100

    spacing: 4
    Text { text: label + " (max " + max + ")"; font.pixelSize: 11; color: "#718096" }
    TextField {
        id: field
        placeholderText: "0"
        validator: IntValidator { bottom: 0; top: max }
        Layout.preferredWidth: 80
        background: Rectangle { radius: 6; border.color: field.activeFocus ? "#5C61F2" : "#E2E8F0"; border.width: field.activeFocus ? 2 : 1 }
    }
}
