import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts
import "../components"

Item {
    id: statsRoot

    property int currentSimId: -1
    property real globalAverage: 0
    property real maxScore: 0
    property real minScore: 0
    property int totalStudents: 0
    property var top5Model: []
    property var bottom5Model: []

    function loadData() {
        if (currentSimId === -1) return

        let stats = backend.getSimulacrumStats(currentSimId)
        maxScore = stats.topScore
        minScore = stats.minScore
        totalStudents = stats.total
        top5Model = stats.top5
        bottom5Model = stats.bottom5

        updateSubjectChart(stats)

        let fullList = backend.getFullResultsList(currentSimId)
        processDistribution(fullList)
    }

    function updateSubjectChart(stats) {
        subjectSeries.clear()
        let barSet = subjectSeries.append("Promedio", [stats.avgL, stats.avgM, stats.avgS, stats.avgN, stats.avgI])
        if (barSet) {
            barSet.color = "#5C61F2"
        }
    }

    function processDistribution(data) {
        donutSeries.clear()
        histoSeries.clear()

        if (!data || data.length === 0) {
            globalAverage = 0
            return
        }

        let sumGlobal = 0
        let ranges = [0, 0, 0, 0, 0]
        let levels = { adv: 0, sat: 0, min: 0, insuf: 0 }

        for (let i = 0; i < data.length; i++) {
            let score = data[i].global
            if (score === undefined) continue

            sumGlobal += score

            if (score <= 100) ranges[0]++
            else if (score <= 200) ranges[1]++
            else if (score <= 300) ranges[2]++
            else if (score <= 400) ranges[3]++
            else ranges[4]++

            if (score >= 360) levels.adv++
            else if (score >= 300) levels.sat++
            else if (score >= 230) levels.min++
            else levels.insuf++
        }

        globalAverage = sumGlobal / data.length
        updateHistogram(ranges)
        updateDonutChart(levels)
    }

    function updateHistogram(ranges) {
        let hSet = histoSeries.append("Frecuencia", ranges)
        if (hSet) hSet.color = "#8B5CF6"
        axisYHisto.max = Math.max(...ranges) + 2
    }

    function updateDonutChart(levels) {
        const slices = [
            { label: "Avanzado", val: levels.adv, col: "#10B981" },
            { label: "Satisfactorio", val: levels.sat, col: "#5C61F2" },
            { label: "Mínimo", val: levels.min, col: "#F59E0B" },
            { label: "Insuficiente", val: levels.insuf, col: "#EF4444" }
        ]

        slices.forEach(item => {
            if (item.val >= 0) {
                let s = donutSeries.append(item.label, item.val)
                if (s) {
                    s.color = item.col
                    s.labelVisible = false
                }
            }
        })
    }

    function getAverageColor() {
        if (isNaN(globalAverage) || globalAverage === 0) {
            return { text: "#9CA3AF", bg: "#F3F4F6" };   // gris suave
        }
        if (globalAverage < 250) {
            return { text: "#DC2626", bg: "#FEE2E2" };   // rojo claro
        }
        if (globalAverage < 300) {
            return { text: "#D97706", bg: "#FEF3C7" };   // ámbar claro
        }
        if (globalAverage < 360) {
            return { text: "#5C61F2", bg: "#EEF2FF" };   // azul/violeta claro
        }
        return { text: "#059669", bg: "#D1FAE5" };       // verde claro
    }

    function getAverageLabel() {
        if (globalAverage < 230) return "INSUFICIENTE"
        if (globalAverage < 300) return "MÍNIMO"
        if (globalAverage < 360) return "SATISFACTORIO"
        return "AVANZADO"
    }

    onCurrentSimIdChanged: loadData()
    Component.onCompleted: loadData()

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ScrollBar.vertical: ScrollBar {
            parent: scrollView
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

        ColumnLayout {
            width: scrollView.availableWidth
            spacing: 18

            Item { height: 5 }

            // Estado vacío - mostrar cuando no hay resultados
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 450
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                color: "white"
                radius: 12
                border.color: "#E5E7EB"
                border.width: 1
                visible: totalStudents === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    width: parent.width * 0.6

                    // Icono grande
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 100
                        height: 100
                        radius: 50
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "📊"
                            font.pixelSize: 48
                        }
                    }

                    // Título
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No hay estadísticas disponibles"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#1F2937"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Descripción
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width
                        text: "Ingresa los resultados de al menos un estudiante para visualizar las estadísticas y análisis de rendimiento"
                        font.pixelSize: 14
                        color: "#6B7280"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.4
                    }
                }
            }

            // KPIs Principales
            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                visible: totalStudents > 0
                Layout.rightMargin: 20
                columns: parent.width > 900 ? 3 : (parent.width > 600 ? 2 : 1)
                columnSpacing: 15
                rowSpacing: 15

                // Promedio Global
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 115
                    color: "white"
                    radius: 12
                    border.width: 2
                    border.color: statsRoot.getAverageColor().text

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Rectangle {
                            width: 45
                            height: 45
                            radius: 9
                            color: statsRoot.getAverageColor().bg

                            Text {
                                anchors.centerIn: parent
                                text: "Σ"
                                font.pixelSize: 26
                                font.bold: true
                                color: statsRoot.getAverageColor().text
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                text: "Promedio Global"
                                color: "#6B7280"
                                font.pixelSize: 12
                            }

                            Text {
                                text: globalAverage.toFixed(1)
                                color: statsRoot.getAverageColor().text
                                font.pixelSize: 28
                                font.bold: true
                            }

                            Text {
                                text: statsRoot.getAverageLabel()
                                font.pixelSize: 10
                                font.bold: true
                                color: statsRoot.getAverageColor().text
                            }
                        }
                    }
                }

                // Puntaje Máximo
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 115
                    color: "white"
                    radius: 12
                    border.color: "#E5E7EB"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Rectangle {
                            width: 45
                            height: 45
                            radius: 9
                            color: "#D1FAE5"

                            Text {
                                anchors.centerIn: parent
                                text: "↑"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#10B981"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                text: "Puntaje Máximo"
                                color: "#6B7280"
                                font.pixelSize: 12
                            }

                            Text {
                                text: maxScore.toFixed(1)
                                color: "#1F2937"
                                font.pixelSize: 28
                                font.bold: true
                            }
                        }
                    }
                }

                // Puntaje Mínimo
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 115
                    color: "white"
                    radius: 12
                    border.color: "#E5E7EB"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Rectangle {
                            width: 45
                            height: 45
                            radius: 9
                            color: "#FEE2E2"

                            Text {
                                anchors.centerIn: parent
                                text: "↓"
                                font.pixelSize: 22
                                font.bold: true
                                color: "#EF4444"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                text: "Puntaje Mínimo"
                                color: "#6B7280"
                                font.pixelSize: 12
                            }

                            Text {
                                text: minScore.toFixed(1)
                                color: "#1F2937"
                                font.pixelSize: 28
                                font.bold: true
                            }
                        }
                    }
                }
            }

            // Gráficos principales
            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                visible: totalStudents > 0
                Layout.rightMargin: 20
                columns: parent.width > 900 ? 2 : 1
                columnSpacing: 18
                rowSpacing: 18

                // Promedio por Materia
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 310
                    color: "white"
                    radius: 12
                    border.color: "#E5E7EB"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        RowLayout {
                            spacing: 8

                            Rectangle {
                                width: 26
                                height: 26
                                radius: 6
                                color: "#E7F9FE"

                                Text {
                                    anchors.centerIn: parent
                                    text: "▥"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: colorSecundary
                                }
                            }

                            Text {
                                text: "Desempeño por Materia (% de aciertos)"
                                font.bold: true
                                color: "#1F2937"
                                font.pixelSize: 14
                            }
                        }

                        ChartView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            antialiasing: true
                            legend.visible: false
                            backgroundColor: "transparent"

                            BarSeries {
                                id: subjectSeries
                                axisX: BarCategoryAxis {
                                    categories: ["LEC", "MAT", "SOC", "NAT", "ING"]
                                    labelsFont.pixelSize: 10
                                    labelsColor: "#6B7280"
                                    gridLineColor: "#F3F4F6"
                                }
                                axisY: ValueAxis {
                                    min: 0
                                    max: 100
                                    tickCount: 6
                                    labelsFont.pixelSize: 10
                                    labelsColor: "#6B7280"
                                    gridLineColor: "#F3F4F6"
                                }
                            }
                        }
                    }
                }

                // Niveles de Desempeño
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 310
                    color: "white"
                    radius: 12
                    border.color: "#E5E7EB"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        RowLayout {
                            spacing: 8

                            Rectangle {
                                width: 26
                                height: 26
                                radius: 6
                                color: "#E7F9FE"

                                Text {
                                    anchors.centerIn: parent
                                    text: "◐"
                                    font.pixelSize: 17
                                    font.bold: true
                                    color: colorSecundary
                                }
                            }

                            Text {
                                text: "Niveles de Desempeño"
                                font.bold: true
                                color: "#1F2937"
                                font.pixelSize: 14
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
                                    id: donutSeries
                                    holeSize: 0.4
                                    size: 0.9
                                }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 130
                                spacing: 10

                                Repeater {
                                    model: [
                                        { label: "Avanzado", range: "≥ 360", color: "#10B981" },
                                        { label: "Satisfactorio", range: "300-359", color: "#5C61F2" },
                                        { label: "Mínimo", range: "230-299", color: "#F59E0B" },
                                        { label: "Insuficiente", range: "&lt; 230", color: "#EF4444" }
                                    ]

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        RowLayout {
                                            spacing: 6

                                            Rectangle {
                                                width: 12
                                                height: 12
                                                radius: 2
                                                color: modelData.color
                                            }

                                            Text {
                                                text: modelData.label
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: "#1F2937"
                                            }
                                        }

                                        Text {
                                            text: modelData.range
                                            font.pixelSize: 10
                                            color: "#6B7280"
                                            Layout.leftMargin: 18
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Distribución de Puntajes
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 310
                visible: totalStudents > 0
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                color: "white"
                radius: 12
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    RowLayout {
                        spacing: 8

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 6
                            color: "#E7F9FE"

                            Text {
                                anchors.centerIn: parent
                                text: "▬"
                                font.pixelSize: 13
                                font.bold: true
                                color: colorSecundary
                            }
                        }

                        Text {
                            text: "Distribución de Puntajes"
                            font.bold: true
                            color: "#1F2937"
                            font.pixelSize: 14
                        }
                    }

                    ChartView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        antialiasing: true
                        legend.visible: false
                        backgroundColor: "transparent"

                        BarSeries {
                            id: histoSeries
                            axisX: BarCategoryAxis {
                                categories: ["0-100", "101-200", "201-300", "301-400", "401-500"]
                                labelsFont.pixelSize: 10
                                labelsColor: "#6B7280"
                                gridLineColor: "#F3F4F6"
                            }
                            axisY: ValueAxis {
                                id: axisYHisto
                                min: 0
                                tickCount: 5
                                labelsFont.pixelSize: 10
                                labelsColor: "#6B7280"
                                gridLineColor: "#F3F4F6"
                            }
                        }
                    }
                }
            }

            // Rankings
            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                visible: totalStudents > 0
                Layout.rightMargin: 20
                columns: parent.width > 700 ? 2 : 1
                columnSpacing: 18
                rowSpacing: 18

                TableTopList {
                    title: "Top 5 Mejores Puntajes"
                    titleColor: "#10B981"
                    iconBg: "#D1FAE5"
                    iconText: "★"
                    modelData: top5Model
                    Layout.fillWidth: true
                    Layout.preferredHeight: 310
                }

                TableTopList {
                    title: "Puntajes Bajos (Refuerzo)"
                    titleColor: "#EF4444"
                    iconBg: "#FEE2E2"
                    iconText: "!"
                    modelData: bottom5Model
                    Layout.fillWidth: true
                    Layout.preferredHeight: 310
                }
            }

            Item { height: 10 }
        }
    }
}
