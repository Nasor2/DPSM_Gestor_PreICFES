// qml/views/DashboardView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts

Item {
    id: dashRoot
    objectName: "dashboard"

    signal navigateToSimulacros

    property var lastSimData: null

    function refreshData() {
        let evolution = backend.getEvolutionGraphData()
        let dist = backend.getGlobalDistributionData()
        let topStudents = backend.getTopStudentsGlobal()
        let studentList = backend.getStudentsList()
        let globalProm = backend.getGlobalAverageScore().toFixed(1)

        // Obtener datos del último simulacro
        let simList = backend.getSimulacrumList()
        let totalSims = simList.length
        let lastSimAvg = 0
        let lastSimTotal = 0

        if (totalSims > 0) {
            let lastSimId = simList[0].id
            let stats = backend.getSimulacrumStats(lastSimId)
            lastSimAvg = stats.avgGlobal || 0
            lastSimTotal = stats.total || 0
            lastSimData = {
                "name": simList[0].name,
                "avg": lastSimAvg,
                "total": lastSimTotal
            }
        }

        kpiRepeater.model = [{
                                 "label": "Estudiantes",
                                 "value": studentList.length,
                                 "color": "#10B981",
                                 "icon": "E",
                                 "iconBg": "#D1FAE5"
                             }, {
                                 "label": "Total Simulacros",
                                 "value": totalSims.toString(),
                                 "color": "#F59E0B",
                                 "icon": "T",
                                 "iconBg": "#FEF3C7"
                             }, {
                                 "label": "Promedio Historico (Simulacros)",
                                 "value": globalProm,
                                 "color": "#8B5CF6",
                                 "icon": "P",
                                 "iconBg": "#EDE9FE"
                             }]

        // Gráfico de evolución
        evolutionSeries.clear()
        let categories = []
        let evolutionOrdered = evolution.slice().reverse()

        for (var i = 0; i < evolutionOrdered.length; i++) {
            evolutionSeries.append(i, evolutionOrdered[i].value)
            categories.push(evolutionOrdered[i].label)
        }
        evolutionAxisX.categories = categories
        evolutionAxisY.max = 500
        evolutionAxisY.min = 0

        // Gráfico de distribución con nuevos niveles
        pieSeries.clear()
        let slices = [{
                          "label": "Avanzado (≥ 360)",
                          "val": dist.alto,
                          "col": "#10B981"
                      }, {
                          "label": "Satisfactorio (300-359)",
                          "val": dist.medio,
                          "col": "#5C61F2"
                      }, {
                          "label": "Mínimo (230-299)",
                          "val": dist.bajo,
                          "col": "#F59E0B"
                      }, {
                          "label": "Insuficiente (< 230)",
                          "val": dist.insuficiente || 0,
                          "col": "#EF4444"
                      }]

        slices.forEach(function (item) {
            if (item.val > 0) {
                let s = pieSeries.append(item.label, item.val)
                if (s !== null && s !== undefined) {
                    s.color = item.col
                }
            }
        })

        topStudentsRepeater.model = topStudents
    }

    Component.onCompleted: refreshData()

    readonly property color colorPrimary: "#062878"
    readonly property color colorSecundary: "#0838A9"

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ScrollBar.vertical: ScrollBar {
            parent: scrollView
            x: scrollView.width - width - 2 // Pequeño margen a la derecha
            y: scrollView.topPadding
            height: scrollView.availableHeight

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

        ColumnLayout {
            width: scrollView.availableWidth
            spacing: 25

            // Header con gradiente azul
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
                    spacing: 20

                    Rectangle {
                        width: 5
                        height: 65
                        radius: 2.5
                        color: "white"
                        opacity: 0.9
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Panel de Control"
                            color: "white"
                            font.pixelSize: 26
                            font.bold: true
                        }

                        Text {
                            text: "Monitorea el rendimiento y gestiona evaluaciones"
                            color: "white"
                            font.pixelSize: 14
                            opacity: 0.95
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 50
                        text: "Nuevo Simulacro"


                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            font.bold: true
                            color: colorSecundary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 10
                            color: parent.hovered ? "#E7EEFE" : "white"
                        }

                        onClicked: dashRoot.navigateToSimulacros()
                    }
                }
            }

            // Estado vacío - mostrar cuando no hay simulacros
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(400, scrollView.availableHeight - 140 - 50)
                color: "white"
                radius: 12
                border.color: "#E5E7EB"
                border.width: 1
                visible: lastSimData === null

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    width: parent.width * 0.6

                    // Icono grande
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 120
                        height: 120
                        radius: 60
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "📊"
                            font.pixelSize: 56
                        }
                    }

                    // Título
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No hay datos para mostrar"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#1F2937"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Descripción
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width
                        text: "Crea tu primer simulacro para comenzar a visualizar estadísticas y métricas de rendimiento"
                        font.pixelSize: 15
                        color: "#6B7280"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Botón CTA
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50
                        text: "Crear Simulacro"

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 15
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 10
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: colorPrimary }
                                GradientStop { position: 1.0; color: colorSecundary }
                            }
                            opacity: parent.hovered ? 0.9 : 1.0
                        }

                        onClicked: dashRoot.navigateToSimulacros()
                    }
                }
            }

            // KPIs - Grid de 3
            GridLayout {
                Layout.fillWidth: true
                visible: lastSimData !== null
                columns: parent.width > 1200 ? 3 : (parent.width > 800 ? 3 : 2)
                columnSpacing: 20
                rowSpacing: 20

                Repeater {
                    id: kpiRepeater

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        color: "white"
                        radius: 12
                        border.color: "#E5E7EB"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12

                            RowLayout {
                                spacing: 12

                                Rectangle {
                                    width: 46
                                    height: 46
                                    radius: 10
                                    color: modelData.iconBg

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.icon
                                        font.pixelSize: 22
                                        font.bold: true
                                        color: modelData.color
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.label
                                    color: "#6B7280"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    wrapMode: Text.WordWrap
                                }
                            }

                            Text {
                                text: modelData.value
                                color: modelData.color
                                font.pixelSize: 36
                                font.bold: true
                            }
                        }
                    }
                }
            }

            // Resumen del último simulacro
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                color: "#E7EEFE"
                radius: 12
                border.color: "#BBCEFC"
                border.width: 1
                visible: lastSimData !== null

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    RowLayout {
                        spacing: 10

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 8
                            color: "#BBCEFC"

                            Text {
                                anchors.centerIn: parent
                                text: "i"
                                font.pixelSize: 18
                                font.bold: true
                                color: colorSecundary
                            }
                        }

                        Text {
                            text: "Último Simulacro Evaluado"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#1F2937"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        Column {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: lastSimData ? lastSimData.name : ""
                                font.pixelSize: 24
                                font.bold: true
                                color: colorSecundary
                                elide: Text.ElideRight
                            }

                            Text {
                                text: lastSimData ? (lastSimData.total + " estudiante"
                                                     + (lastSimData.total
                                                        !== 1 ? "s" : "") + " evaluado"
                                                     + (lastSimData.total !== 1 ? "s" : "")) : ""
                                font.pixelSize: 13
                                color: "#6B7280"
                            }
                        }

                        Rectangle {
                            width: 100
                            height: 60
                            radius: 10
                            color: "#BBCEFC"

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Promedio"
                                    font.pixelSize: 11
                                    color: colorSecundary
                                    font.weight: Font.Medium
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: lastSimData ? lastSimData.avg.toFixed(
                                                            1) : "0"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: colorSecundary
                                }
                            }
                        }
                    }
                }
            }

            // Gráficos principales
            GridLayout {
                Layout.fillWidth: true
                visible: lastSimData !== null
                columns: parent.width > 800 ? 2 : 1
                columnSpacing: 20
                rowSpacing: 20

                // Evolución
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 400
                    color: "white"
                    radius: 12
                    border.color: "#E5E7EB"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        RowLayout {
                            spacing: 10

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 8
                                color: "#E7EEFE"

                                Text {
                                    anchors.centerIn: parent
                                    text: "~"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: colorSecundary
                                }
                            }

                            Text {
                                text: "Tendencia de Rendimiento"
                                font.bold: true
                                font.pixelSize: 16
                                color: "#1F2937"
                            }
                        }

                        ChartView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            antialiasing: true
                            legend.visible: false
                            backgroundColor: "transparent"

                            LineSeries {
                                id: evolutionSeries
                                color: colorSecundary
                                width: 3
                                pointsVisible: true
                                pointLabelsVisible: false

                                axisX: BarCategoryAxis {
                                    id: evolutionAxisX
                                    labelsColor: "#6B7280"
                                    labelsFont.pixelSize: 11
                                    gridLineColor: "#F3F4F6"
                                }
                                axisY: ValueAxis {
                                    id: evolutionAxisY
                                    labelsColor: "#6B7280"
                                    labelsFont.pixelSize: 11
                                    gridLineColor: "#F3F4F6"
                                    titleText: "Puntaje"
                                }
                            }
                        }
                    }
                }

                // Distribución de Niveles de Desempeño
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 400
                    color: "white"
                    radius: 12
                    border.color: "#E5E7EB"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        RowLayout {
                            spacing: 10

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 8
                                color: "#E7EEFE"

                                Text {
                                    anchors.centerIn: parent
                                    text: "◐"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: colorSecundary
                                }
                            }

                            Text {
                                text: "Niveles de Desempeño"
                                font.bold: true
                                font.pixelSize: 16
                                color: "#1F2937"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 15

                            ChartView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumWidth: 200
                                antialiasing: true
                                backgroundColor: "transparent"
                                legend.visible: false

                                PieSeries {
                                    id: pieSeries
                                    holeSize: 0.5
                                    size: 0.9
                                }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 145
                                spacing: 12

                                Repeater {
                                    model: [{
                                            "label": "Avanzado",
                                            "range": "≥ 360",
                                            "color": "#10B981"
                                        }, {
                                            "label": "Satisfactorio",
                                            "range": "300-359",
                                            "color": "#5C61F2"
                                        }, {
                                            "label": "Mínimo",
                                            "range": "230-299",
                                            "color": "#F59E0B"
                                        }, {
                                            "label": "Insuficiente",
                                            "range": "< 230",
                                            "color": "#EF4444"
                                        }]

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3

                                        RowLayout {
                                            spacing: 7

                                            Rectangle {
                                                width: 14
                                                height: 14
                                                radius: 3
                                                color: modelData.color
                                            }

                                            Text {
                                                text: modelData.label
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: "#1F2937"
                                            }
                                        }

                                        Text {
                                            text: modelData.range
                                            font.pixelSize: 11
                                            color: "#6B7280"
                                            Layout.leftMargin: 21
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Ranking
            Rectangle {
                Layout.fillWidth: true
                visible: lastSimData !== null
                Layout.preferredHeight: 450
                color: "white"
                radius: 12
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    RowLayout {
                        spacing: 10

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 8
                            color: "#E7EEFE"

                            Text {
                                anchors.centerIn: parent
                                text: "★"
                                font.pixelSize: 18
                                font.bold: true
                                color: colorSecundary
                            }
                        }

                        Text {
                            text: "Top 5 Estudiantes (Promedio Histórico)"
                            font.bold: true
                            font.pixelSize: 16
                            color: "#1F2937"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10

                        Repeater {
                            id: topStudentsRepeater

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 64
                                color: index === 0 ? "#FEF3C7" : "#F9FAFB"
                                radius: 10
                                border.color: index === 0 ? "#FDE68A" : "#E5E7EB"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 14

                                    Rectangle {
                                        width: 36
                                        height: 36
                                        radius: 18
                                        color: {
                                            if (index === 0)
                                                return "#efb810"
                                            if (index === 1)
                                                return "#C4C4C4"
                                            if (index === 2)
                                                return "#CD7F32"
                                            return "#B8DAFF"
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: (index + 1).toString()
                                            font.bold: true
                                            font.pixelSize: 16
                                            color: "white"
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        font.pixelSize: 15
                                        font.weight: index === 0 ? Font.Bold : Font.Normal
                                        color: "#1F2937"
                                        elide: Text.ElideRight
                                    }

                                    Rectangle {
                                        width: 80
                                        height: 36
                                        radius: 18
                                        color: index === 0 ? "#BFDBFE" : "#E0E7FF"

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.score.toFixed(1)
                                            color: index === 0 ? "#1E40AF" : "#4F46E5"
                                            font.bold: true
                                            font.pixelSize: 15
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }


    }
}
