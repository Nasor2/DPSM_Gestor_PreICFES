// components/DatePicker.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: datePickerPopup
    width: 340
    height: 420
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 16

    property date selectedDate: new Date()
    property date minDate: new Date(2000, 0, 1)
    property date maxDate: new Date(2030, 11, 31)

    signal dateAccepted(date selected)

    property int displayMonth: selectedDate.getMonth()
    property int displayYear: selectedDate.getFullYear()

    background: Rectangle {
        color: "white"
        radius: 12
        border.color: "#E2E8F0"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Header con selectores de mes y año
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#F8FAFC"
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                // Selector de Mes
                ComboBox {
                    id: monthCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    model: [
                        "Enero", "Febrero", "Marzo", "Abril",
                        "Mayo", "Junio", "Julio", "Agosto",
                        "Septiembre", "Octubre", "Noviembre", "Diciembre"
                    ]

                    currentIndex: displayMonth

                    onActivated: {
                        displayMonth = currentIndex
                    }

                    background: Rectangle {
                        radius: 6
                        color: monthCombo.hovered ? "#E2E8F0" : "white"
                        border.color: "#CBD5E0"
                        border.width: 1
                    }

                    contentItem: Text {
                        leftPadding: 12
                        rightPadding: monthCombo.indicator.width + 12
                        text: monthCombo.displayText
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1F2937"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    indicator: Text {
                        x: monthCombo.width - width - 8
                        y: monthCombo.topPadding + (monthCombo.availableHeight - height) / 2
                        text: "▼"
                        font.pixelSize: 10
                        color: "#64748B"
                    }

                    delegate: ItemDelegate {
                        width: monthCombo.width
                        height: 36

                        contentItem: Text {
                            text: modelData
                            font.pixelSize: 14
                            color: highlighted ? "#1048B9" : "#1F2937"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }

                        background: Rectangle {
                            color: parent.highlighted ? "#EEF2FF" : (parent.hovered ? "#F8FAFC" : "transparent")
                        }

                        highlighted: monthCombo.highlightedIndex === index

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    popup: Popup {
                        y: monthCombo.height + 2
                        width: monthCombo.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 4

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: monthCombo.popup.visible ? monthCombo.delegateModel : null
                            currentIndex: monthCombo.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: "white"
                            border.color: "#E2E8F0"
                            border.width: 1
                            radius: 8
                        }
                    }
                }

                // Selector de Año
                ComboBox {
                    id: yearCombo
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40

                    model: {
                        var years = []
                        for (var y = maxDate.getFullYear(); y >= minDate.getFullYear(); y--) {
                            years.push(y)
                        }
                        return years
                    }

                    currentIndex: {
                        var idx = maxDate.getFullYear() - displayYear
                        return idx >= 0 ? idx : 0
                    }

                    onActivated: {
                        displayYear = model[currentIndex]
                    }

                    background: Rectangle {
                        radius: 6
                        color: yearCombo.hovered ? "#E2E8F0" : "white"
                        border.color: "#CBD5E0"
                        border.width: 1
                    }

                    contentItem: Text {
                        leftPadding: 12
                        rightPadding: yearCombo.indicator.width + 12
                        text: yearCombo.displayText
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1F2937"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    indicator: Text {
                        x: yearCombo.width - width - 8
                        y: yearCombo.topPadding + (yearCombo.availableHeight - height) / 2
                        text: "▼"
                        font.pixelSize: 10
                        color: "#64748B"
                    }

                    delegate: ItemDelegate {
                        width: yearCombo.width
                        height: 36

                        contentItem: Text {
                            text: modelData
                            font.pixelSize: 14
                            color: highlighted ? "#1048B9" : "#1F2937"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        background: Rectangle {
                            color: parent.highlighted ? "#EEF2FF" : (parent.hovered ? "#F8FAFC" : "transparent")
                        }

                        highlighted: yearCombo.highlightedIndex === index

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    popup: Popup {
                        y: yearCombo.height + 2
                        width: yearCombo.width
                        implicitHeight: Math.min(contentItem.implicitHeight, 240)
                        padding: 4

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: yearCombo.popup.visible ? yearCombo.delegateModel : null
                            currentIndex: yearCombo.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: "white"
                            border.color: "#E2E8F0"
                            border.width: 1
                            radius: 8
                        }
                    }
                }
            }
        }

        // Días de la semana
        DayOfWeekRow {
            Layout.fillWidth: true
            locale: Qt.locale("es_CO")

            delegate: Text {
                text: model.shortName
                font.pixelSize: 12
                font.bold: true
                color: "#64748B"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Grid de días
        MonthGrid {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            month: displayMonth
            year: displayYear
            locale: Qt.locale("es_CO")

            delegate: Rectangle {
                required property var model

                implicitWidth: 42
                implicitHeight: 42
                radius: 8

                property bool isHovered: false
                property bool isCurrentlySelected: {
                    if (!model.date) return false
                    return model.date.getDate() === selectedDate.getDate() &&
                           model.date.getMonth() === selectedDate.getMonth() &&
                           model.date.getFullYear() === selectedDate.getFullYear()
                }

                color: {
                    if (isCurrentlySelected) return "#1048B9"
                    if (isHovered && model.visibleMonth) return "#F1F5F9"
                    if (model.today) return "#EEF2FF"
                    return "transparent"
                }

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }

                Text {
                    anchors.centerIn: parent
                    text: model.day
                    color: {
                        if (parent.isCurrentlySelected) return "#FFFFFF"
                        if (!model.visibleMonth) return "#CBD5E0"
                        if (model.today) return "#5C61F2"
                        return "#1F2937"
                    }
                    font.pixelSize: 14
                    font.bold: parent.isCurrentlySelected || model.today
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: {
                        parent.isHovered = true
                    }

                    onExited: {
                        parent.isHovered = false
                    }

                    onClicked: {
                        if (model.date) {
                            selectedDate = model.date
                            datePickerPopup.dateAccepted(selectedDate)
                        }
                    }
                }
            }
        }

        // Botones de acción
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: "Cancelar"
                onClicked: datePickerPopup.close()

                background: Rectangle {
                    radius: 8
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

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: "Aceptar"

                background: Rectangle {
                    radius: 8
                    color: parent.hovered ? "#0D3B96" : "#1048B9"
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
                    cursorShape: Qt.PointingHandCursor
                }

                onClicked: {
                    datePickerPopup.dateAccepted(selectedDate)
                    datePickerPopup.close()
                }
            }
        }
    }

    onSelectedDateChanged: {
        displayMonth = selectedDate.getMonth()
        displayYear = selectedDate.getFullYear()
    }

    onAboutToShow: {
        if (selectedDate < minDate) {
            selectedDate = minDate
        } else if (selectedDate > maxDate) {
            selectedDate = maxDate
        }
        displayMonth = selectedDate.getMonth()
        displayYear = selectedDate.getFullYear()
    }
}
