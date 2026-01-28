#ifndef SIMULACRUMSERVICE_H
#define SIMULACRUMSERVICE_H

#include "database_manager.h"
#include <vector>
#include <string>
#include <algorithm>


class SimulacrumService {
public:

    //Global access singleton
    static SimulacrumService& intance(){
        static SimulacrumService _instance;
        return _instance;
    }

    enum ResultCode {
        Success = 0,
        DuplicateName = -2,
        DatabaseError = -1,
        InvalidData = -3
    };




    //Step 1: create o get booklet
    int setupBooklet(const std::string& name,
                     int l, int m, int s, int n, int i){
        Booklet b(name, l, m, s, n, i);
        return DatabaseManager::instance().saveBooklet(b);
    }

    //Setop 2: initializate simulacrum
    int startSimulacrum(const std::string& name,
                        const std::string& date,
                        int bookletId){
        if (name.empty()) return InvalidData;

        Simulacrum s(name, date, bookletId);
        return DatabaseManager::instance().saveSimulacrum(s);
    }

    //Step 3: register in burst
    bool registerStudentResult(int simulacrumId,
                               const std::string& studentName,
                               int l, int m, int s, int n, int i){
        //Ensure student

        int studentId = DatabaseManager::instance().asegurarStudents(studentName);
        if (studentId == -1) return false;

        //Create object of domain result
        Result newResult(studentId, simulacrumId, l, m, s, n, i);

        // Persistence
        return DatabaseManager::instance().saveResult(newResult);
    }

    std::vector<Simulacrum> getAllSimulacrums(){
        return DatabaseManager::instance().getSimulacrums();
    }

    int createFullSimulacrum(const std::string& simName, const std::string& date,
                             const std::string& bookName, int l, int m, int s, int n, int i) {
        // Paso 1: Usamos TU setupBooklet
        int bId = setupBooklet(bookName, l, m, s, n, i);
        if (bId == -1) return -1;

        // Paso 2: Usamos TU startSimulacrum
        return startSimulacrum(simName, date, bId);
    }

    struct StudentSummary {
        std::string name;
        int score;
    };

    struct SimulacrumStats {
        double avgL, avgM, avgS, avgN, avgI;
        int totalEstudiantes;
        int topScore;
        int minScore;
        double avgGlobal;

        int countInsuficiente;    // < 230
        int countMinimo;          // 230-299
        int countSatisfactorio;   // 300-359
        int countAvanzado;        // >= 360


        std::vector<StudentSummary> topStudents;
        std::vector<StudentSummary> bottomStudents;
    };

    SimulacrumStats getStats(int simId) {
        auto results = DatabaseManager::instance().getDetailedResultsBySimulacrum(simId);
        SimulacrumStats stats = {0,0,0,0,0, (int)results.size(), 0, 0, 0, 0, 0, 0};

        if (results.empty()) return stats;

        std::vector<StudentSummary> allRanked;
        double globalSum = 0;

        for (const auto& r: results){
            // Promediamos el rendimiento (aciertos / totales * 100)
            stats.avgL += (r.tL > 0) ? (double)r.l / r.tL * 100 : 0;
            stats.avgM += (r.tM > 0) ? (double)r.m / r.tM * 100 : 0;
            stats.avgS+= (r.tS > 0) ? (double)r.s / r.tS * 100 : 0;
            stats.avgN+= (r.tN > 0) ? (double)r.n / r.tN * 100 : 0;
            stats.avgI+= (r.tI > 0) ? (double)r.i / r.tI * 100 : 0;


            // Calculamos el global para sacar el maxScore

            Result tempRes(0, simId, r.l, r.m, r.s, r.n, r.i);
            Booklet tempBook("", r.tL, r.tM, r.tS, r.tN, r.tI);
            int currentGlobal = tempRes.calculateGlobalScore(tempBook);
            globalSum += currentGlobal;

            allRanked.push_back({r.studentName, currentGlobal});

            if (currentGlobal < 230) {
                stats.countInsuficiente++;
            } else if (currentGlobal < 300) {
                stats.countMinimo++;
            } else if (currentGlobal < 360) {
                stats.countSatisfactorio++;
            } else {
                stats.countAvanzado++;
            }

        }


        // Dividir la suma de porcentajes por el total de estudiantes
        if (stats.totalEstudiantes > 0) {
            stats.avgL /= stats.totalEstudiantes;
            stats.avgM /= stats.totalEstudiantes;
            stats.avgS /= stats.totalEstudiantes;
            stats.avgN /= stats.totalEstudiantes;
            stats.avgI /= stats.totalEstudiantes;
        }

        // --- ORDENAMIENTO ---
        std::sort(allRanked.begin(), allRanked.end(), [](const StudentSummary& a, const StudentSummary& b) {
            return a.score > b.score; // De mayor a menor
        });

        // Extraer Top 5
        for(int i = 0; i < std::min(5, (int)allRanked.size()); ++i) {
            stats.topStudents.push_back(allRanked[i]);
        }

        // Extraer Bottom 5 (en orden ascendente para ver el peor primero)
        for(int i = (int)allRanked.size() - 1; i >= std::max(0, (int)allRanked.size() - 5); --i) {
            stats.bottomStudents.push_back(allRanked[i]);
        }

        stats.avgGlobal = globalSum / stats.totalEstudiantes;
        stats.topScore = allRanked.front().score;
        stats.minScore = allRanked.back().score;

        return stats;
    }

    // Dentro de la clase SimulacrumService
    bool removeStudentResult(int simulacrumId, const std::string& studentName) {
        // 1. Obtenemos el ID del estudiante (reutilizando tu lógica existente)
        int studentId = DatabaseManager::instance().asegurarStudents(studentName);
        if (studentId == -1) return false;

        // 2. Pedimos a la infraestructura que lo borre
        return DatabaseManager::instance().deleteResult(simulacrumId, studentId);
    }


    struct EvolutionPoint {
        std::string date;
        double globalAverage;
        std::string name;
    };

    struct GlobalStatsDistribution {
        int totalInsuficiente = 0;  // < 230
        int totalMinimo = 0;        // 230-299
        int totalSatisfactorio = 0; // 300-359
        int totalAvanzado = 0;      // >= 360
    };

    std::vector<EvolutionPoint> getGlobalEvolution() {
        std::vector<EvolutionPoint> history;

        // 1. Traemos todos los simulacros (Ya tienes este método)
        auto simulacros = getAllSimulacrums();

        // 2. Para mantener el orden cronológico en la gráfica, invertimos si vienen DESC
        std::reverse(simulacros.begin(), simulacros.end());

        // 3. Iteramos y reutilizamos tu lógica de negocio
        for (const auto& sim : simulacros) {
            // ¡AQUÍ ESTÁ LA CLAVE! Reutilizamos getStats.
            // Si cambias la fórmula en el futuro, esto se actualiza solo.
            SimulacrumStats stats = getStats(sim.getId());

            if (stats.totalEstudiantes > 0) {
                history.push_back({
                    sim.getDate(),
                    stats.avgGlobal, // Este valor ya fue calculado con tus reglas de negocio
                    sim.getName()
                });
            }
        }
        return history;
    }

    GlobalStatsDistribution getGlobalDistribution() {
        GlobalStatsDistribution globalDist;
        auto simulacros = getAllSimulacrums();

        for (const auto& sim : simulacros) {
            SimulacrumStats stats = getStats(sim.getId());
            // Sumamos los contadores individuales al global
            globalDist.totalInsuficiente += stats.countInsuficiente;
            globalDist.totalMinimo += stats.countMinimo;
            globalDist.totalSatisfactorio += stats.countSatisfactorio;
            globalDist.totalAvanzado += stats.countAvanzado;
        }
        return globalDist;
    }

    struct SaveResultResponse {
        bool success;
        QString message;
        SaveResultResponse(bool s = true, QString msg = "") : success(s), message(msg) {}
    };

    SaveResultResponse registerStudentResultValidated(int simulacrumId,
                                                      const std::string& studentName,
                                                      int l, int m, int s, int n, int i) {
        // 1. Obtener booklet del simulacro
        Booklet booklet = DatabaseManager::instance().getBookletBySimulacrumId(simulacrumId);
        if (booklet.getId() < 0) {
            return SaveResultResponse(false, "No se encontró el cuadernillo asociado al simulacro.");
        }

        // 2. Validar límites
        QString errorMsg;
        if (l > booklet.getTLectura()) errorMsg += QString("Lectura Crítica: máximo %1, ingresaste %2\n").arg(booklet.getTLectura()).arg(l);
        if (m > booklet.getTMatematicas()) errorMsg += QString("Matemáticas: máximo %1, ingresaste %2\n").arg(booklet.getTMatematicas()).arg(m);
        if (s > booklet.getTSociales()) errorMsg += QString("Sociales: máximo %1, ingresaste %2\n").arg(booklet.getTSociales()).arg(s);
        if (n > booklet.getTNaturales()) errorMsg += QString("Naturales: máximo %1, ingresaste %2\n").arg(booklet.getTNaturales()).arg(n);
        if (i > booklet.getTIngles()) errorMsg += QString("Inglés: máximo %1, ingresaste %2\n").arg(booklet.getTIngles()).arg(i);

        if (!errorMsg.isEmpty()) {
            return SaveResultResponse(false, "Los valores ingresados exceden el máximo permitido del cuadernillo:\n" + errorMsg);
        }

        // 3. Asegurar estudiante
        int studentId = DatabaseManager::instance().asegurarStudents(studentName);
        if (studentId == -1) {
            return SaveResultResponse(false, "Error al registrar o buscar al estudiante.");
        }

        // 4. Crear y guardar
        Result newResult(studentId, simulacrumId, l, m, s, n, i);
        int saveResult = DatabaseManager::instance().saveResult(newResult);

        if (saveResult > 0) {
            return SaveResultResponse(true, "Resultado registrado correctamente");
        } else if (saveResult == -2) {
            return SaveResultResponse(false, "Este estudiante ya tiene resultados registrados en este simulacro.");
        } else {
            return SaveResultResponse(false, "Error al guardar el resultado en la base de datos.");
        }
    }

    SaveResultResponse updateStudentResultValidated(int simulacrumId,
                                                    const std::string& studentName,
                                                    int l, int m, int s, int n, int i) {
        // Mismo chequeo de booklet y límites que en register
        Booklet booklet = DatabaseManager::instance().getBookletBySimulacrumId(simulacrumId);
        if (booklet.getId() < 0) {
            return SaveResultResponse(false, "No se encontró el cuadernillo asociado al simulacro.");
        }

        QString errorMsg;
        if (l > booklet.getTLectura()) errorMsg += QString("Lectura Crítica: máximo %1, ingresaste %2\n").arg(booklet.getTLectura()).arg(l);
        if (m > booklet.getTMatematicas()) errorMsg += QString("Matemáticas: máximo %1, ingresaste %2\n").arg(booklet.getTMatematicas()).arg(m);
        if (s > booklet.getTSociales()) errorMsg += QString("Sociales: máximo %1, ingresaste %2\n").arg(booklet.getTSociales()).arg(s);
        if (n > booklet.getTNaturales()) errorMsg += QString("Naturales: máximo %1, ingresaste %2\n").arg(booklet.getTNaturales()).arg(n);
        if (i > booklet.getTIngles()) errorMsg += QString("Inglés: máximo %1, ingresaste %2\n").arg(booklet.getTIngles()).arg(i);

        if (!errorMsg.isEmpty()) {
            return SaveResultResponse(false, "Los valores ingresados exceden el máximo permitido del cuadernillo:\n" + errorMsg);
        }

        int studentId = DatabaseManager::instance().asegurarStudents(studentName);
        if (studentId == -1) {
            return SaveResultResponse(false, "Error al identificar al estudiante.");
        }

        Result r(studentId, simulacrumId, l, m, s, n, i);
        bool updated = DatabaseManager::instance().updateResult(r);

        if (updated) {
            return SaveResultResponse(true, "Resultado actualizado correctamente");
        } else {
            return SaveResultResponse(false, "Error al actualizar el resultado.");
        }
    }

    int updateFullSimulacrum(int simId, const std::string& simName, const std::string& date,
                             const std::string& bookName, int l, int m, int s, int n, int i) {
        Simulacrum current = DatabaseManager::instance().getSimulacrumById(simId);
        if (current.getId() < 0) return -1;

        // Actualizar booklet si cambió
        int bId = current.getIdBooklet();
        Booklet b(bookName, l, m, s, n, i, bId);
        bool updatedBooklet = DatabaseManager::instance().updateBooklet(b);
        if (!updatedBooklet) return -1;

        // Actualizar simulacro
        Simulacrum updatedSim(simName, date, bId, simId);
        return DatabaseManager::instance().updateSimulacrum(updatedSim);
    }

    bool deleteFullSimulacrum(int simId) {
        Simulacrum sim = DatabaseManager::instance().getSimulacrumById(simId);
        if (sim.getId() < 0) return false;

        bool deletedSim = DatabaseManager::instance().deleteSimulacrum(simId);
        if (deletedSim) {
            DatabaseManager::instance().deleteBooklet(sim.getIdBooklet());
        }
        return deletedSim;
    }

    // Editar estudiante
    bool updateStudent(int id, const std::string& newName) {
        if (newName.empty()) return false;
        // Verificar si el nuevo nombre ya existe (evitar duplicados)
        QSqlQuery checkQuery;
        checkQuery.prepare("SELECT id FROM students WHERE fullname = :nom AND id != :id");
        checkQuery.bindValue(":nom", QString::fromStdString(newName));
        checkQuery.bindValue(":id", id);
        if (checkQuery.exec() && checkQuery.next()) {
            return false;  // Duplicado
        }
        return DatabaseManager::instance().updateStudent(id, newName);
    }

    // Eliminar estudiante (full delete)
    bool deleteStudent(int id) {
        return DatabaseManager::instance().deleteStudent(id);
    }

    // Obtener simulacros de un estudiante
    std::vector<Simulacrum> getStudentSimulacra(int studentId) {
        return DatabaseManager::instance().getStudentSimulacra(studentId);
    }

    // Obtener info de estudiante
    Student getStudentById(int id) {
        return DatabaseManager::instance().getStudentById(id);
    }

    int getStudentTotalSimulacra(int studentId) {
        return DatabaseManager::instance().getStudentTotalSimulacra(studentId);
    }

    struct SimulacrumWithScore {
        int id;
        std::string name;
        std::string date;
        int score;
    };

    std::vector<SimulacrumWithScore> getStudentSimulacraWithScores(int studentId) {
        auto dataList = DatabaseManager::instance().getStudentSimulacraWithScores(studentId);
        std::vector<SimulacrumWithScore> result;

        for (const auto& data : dataList) {
            result.push_back({
                data.id,
                data.name,
                data.date,
                data.score
            });
        }

        return result;
    }

    // En la sección pública
    QString exportDatabaseToDownloads() {
        return DatabaseManager::instance().exportDatabase();
    }

    QString importDatabaseFromFile(const std::string& filePath) {
        return DatabaseManager::instance().importDatabase(QString::fromStdString(filePath));
    }

    // En SimulacrumService.h (sección pública)

    double getGlobalAverageScoreAcrossAllSimulacra() {
        auto simulacros = getAllSimulacrums();
        if (simulacros.empty()) {
            return 0.0;
        }

        double totalGlobalSum = 0.0;
        int totalSimulacrosWithStudents = 0;

        for (const auto& sim : simulacros) {
            int simId = sim.getId();

            // Reutilizamos getStats (que ya calcula avgGlobal por simulacro)
            SimulacrumStats stats = getStats(simId);

            if (stats.totalEstudiantes > 0) {
                totalGlobalSum += stats.avgGlobal;
                totalSimulacrosWithStudents++;
            }
        }

        if (totalSimulacrosWithStudents == 0) {
            return 0.0;
        }

        return totalGlobalSum / totalSimulacrosWithStudents;
    }

    struct MateriaData {
        std::string nombre;
        int aciertos;
        int totalPreguntas = 500;
        int porcentaje = 0;
        int percentil = 100;  // Default 100 si no se calcula
        std::string nivelStr; // "1" a "4" o "A-", "A1", etc. para Inglés
        std::vector<std::string> habilidades;
    };

    struct BoletinData {
        std::string studentName;
        std::string simulacroName;
        std::string fechaAplicacion;
        int puntajeGlobal = 0;
        int puntajeMaxGlobal = 500;
        int percentilGlobal = 100;  // Default 100 si no se calcula
        std::vector<MateriaData> materias;
    };

    Simulacrum getSimulacrumById(int simId){
        return DatabaseManager::instance().getSimulacrumById(simId);
    }

    int calculatePercentil(int simId, int studentId) {
        auto results = DatabaseManager::instance().getDetailedResultsBySimulacrum(simId);
        if (results.size() < 2) return 100; // No hay comparación real

        std::vector<std::pair<int, std::string>> rankings; // <global, studentName>
        int targetGlobal = 0;
        std::string targetName;

        // Primero obtenemos el nombre del estudiante objetivo (para comparar por string)
        auto targetStudent = getStudentById(studentId);
        if (targetStudent.getId() < 0) return 100;
        targetName = targetStudent.getFullname();

        for (const auto& r : results) {
            Result temp(0, simId, r.l, r.m, r.s, r.n, r.i);
            Booklet book("", r.tL, r.tM, r.tS, r.tN, r.tI);
            int global = temp.calculateGlobalScore(book);
            rankings.emplace_back(global, r.studentName);

            if (r.studentName == targetName) {
                targetGlobal = global;
            }
        }

        // Orden descendente (mayor puntaje primero)
        std::sort(rankings.rbegin(), rankings.rend());

        // Encontrar posición (contando empates como misma posición, pero para percentil usamos el peor caso)
        int position = 1;
        bool found = false;
        for (const auto& rank : rankings) {
            if (rank.second == targetName) {
                found = true;
                break;
            }
            if (rank.first > targetGlobal) position++;
            else if (rank.first == targetGlobal) {
                // Empate: para percentil conservador, contamos como posición siguiente
                position++;
            }
        }

        if (!found) return 100; // No debería pasar, pero por seguridad

        // Percentil = % de estudiantes que están por debajo
        double perc = (1.0 - (position - 1.0) / results.size()) * 100;
        return static_cast<int>(std::round(perc));
    }

    int calculatePercentilArea(int simId, int studentId, size_t areaIndex) {
        auto results = DatabaseManager::instance().getDetailedResultsBySimulacrum(simId);
        if (results.size() < 2) return 100;

        std::vector<std::pair<double, std::string>> rankings; // <porcentaje área, studentName>
        double targetPorc = 0;
        std::string targetName;

        auto targetStudent = getStudentById(studentId);
        if (targetStudent.getId() < 0) return 100;
        targetName = targetStudent.getFullname();

        for (const auto& r : results) {
            int aciertos = (areaIndex == 0 ? r.l : areaIndex == 1 ? r.m : areaIndex == 2 ? r.s : areaIndex == 3 ? r.n : r.i);
            int total = (areaIndex == 0 ? r.tL : areaIndex == 1 ? r.tM : areaIndex == 2 ? r.tS : areaIndex == 3 ? r.tN : r.tI);
            double porc = total > 0 ? (static_cast<double>(aciertos) / total) * 100 : 0;
            rankings.emplace_back(porc, r.studentName);

            if (r.studentName == targetName) {
                targetPorc = porc;
            }
        }

        std::sort(rankings.rbegin(), rankings.rend());

        int position = 1;
        bool found = false;
        for (const auto& rank : rankings) {
            if (rank.second == targetName) {
                found = true;
                break;
            }
            if (rank.first > targetPorc) position++;
            else if (std::abs(rank.first - targetPorc) < 0.001) { // Empate aproximado
                position++;
            }
        }

        if (!found) return 100;

        double perc = (1.0 - (position - 1.0) / results.size()) * 100;
        return static_cast<int>(std::round(perc));
    }

    std::string calculateNivelStr(size_t areaIndex, double porcentaje) {
        if (areaIndex == 0) {
            if (porcentaje >= 66) return "4";
            if (porcentaje >= 51) return "3";
            if (porcentaje >= 36) return "2";
            return "1";
        } else if (areaIndex == 1){
            if (porcentaje >= 71) return "4";
            if (porcentaje >= 51) return "3";
            if (porcentaje >= 36) return "2";
            return "1";
        } else if (areaIndex == 2 or areaIndex == 3){
            if (porcentaje >= 71) return "4";
            if (porcentaje >= 56) return "3";
            if (porcentaje >= 41) return "2";
            return "1";
        } else {            // Inglés (más niveles)
            if (porcentaje >= 71) return "B1";
            if (porcentaje >= 58) return "A2";
            if (porcentaje >= 37) return "A1";
            return "A-";
        }
    }

    std::vector<std::string> getHabilidadesPorMateriaYNivel(const std::string& materia, const std::string& nivel) {
        // Lectura Crítica - ejemplos (cámbialos)
        if (materia == "Lectura Crítica") {
            if (nivel == "4") return {
                    "Propone soluciones a problemas de interpretación presentes en un texto.",
                    "Evalúa contenidos y estrategias discursivas y argumentativas del texto.",
                    "Relaciona información de dos o más textos para construir conclusiones.",
                    "Aplica conceptos de análisis literario para caracterizar elementos del texto.",
                    "Reconoce el contexto como un elemento clave para la valoración del texto.",
                    "Selecciona información relevante y construye argumentos que sustentan una tesis.",
                    "Asume una postura crítica frente a los planteamientos del texto.",
                    "Plantea hipótesis de lectura a partir de las ideas presentes en un texto."
                };

            if (nivel == "3") return {
                    "Jerarquiza la información presente en un texto.",
                    "Infiere información implícita en textos continuos y discontinuos.",
                    "Establece relaciones intertextuales: definición, causa-efecto, oposición y antecedente-consecuente.",
                    "Relaciona marcadores textuales en la interpretación de textos.",
                    "Reconoce la intención comunicativa del texto.",
                    "Reconoce la función de figuras literarias en el texto.",
                    "Identifica el uso del lenguaje según el contexto.",
                    "Analiza y sintetiza la información contenida en un texto.",
                    "Identifica la estructura sintáctica en textos discontinuos.",
                    "Establece la validez de los argumentos presentes en un texto."
                };

            if (nivel == "2") return {
                    "Identifica información local del texto.",
                    "Identifica la estructura de textos continuos y discontinuos.",
                    "Identifica relaciones básicas entre componentes del texto.",
                    "Identifica fenómenos semánticos básicos: sinónimos y antónimos.",
                    "Reconoce en un texto la diferencia entre proposición y párrafo.",
                    "Reconoce el sentido local y global del texto",
                    "Identifica intenciones comunicativas explícitas",
                    "Identifica relaciones básicas: contraste, similitud y complementación entre textos presentes."
                };
            if (nivel == "1") return {
                    "Identifica elementos literales en textos continuos y discontinuos sin establecer relaciones de significado."
                };
        }

        // Matemáticas - ejemplos (ajusta)
        if (materia == "Matemáticas") {
            if (nivel == "4") return {
                    "Resuelve problemas que requieren interpretar información de eventos dependientes.",
                    "Realiza transformaciones de subconjuntos de información que implican el uso de operaciones complejas, como el cálculo de porcentajes.",
                    "Resuelve problemas que requieren construir representaciones auxiliares, como gráficas o fórmulas, como paso intermedio para su solución.",
                    "Modela información dada en lenguaje natural, tablas o representaciones geométricas mediante lenguaje algebraico.",
                    "Manipula expresiones algebraicas o aritméticas utilizando las propiedades de las operaciones.",
                    "Modela fenómenos variacionales no explícitos mediante lenguaje simbólico o representaciones gráficas.",
                    "Reconoce el espacio muestral de un experimento aleatorio en diferentes formatos, como árboles, listas o diagramas.",
                    "Resuelve problemas de conteo que requieren el uso de permutaciones.",
                    "Justifica la falta de información en una situación problema para la toma de decisiones.",
                    "Toma decisiones sobre la veracidad o falsedad de una afirmación cuando requiere el uso de múltiples propiedades o conceptos formales."
                };


            if (nivel == "3") return {
                    "Selecciona la gráfica adecuada a partir de una tabla o de descripciones verbales, considerando la escala, el tipo de variable y el tipo de gráfica.",
                    "Compara información gráfica que requiere manipulaciones aritméticas.",
                    "Identifica información representada en formatos no convencionales como mapas o infografías.",
                    "Reconoce errores en la transformación entre diferentes tipos de registro.",
                    "Reconoce desarrollos planos de formas tridimensionales y viceversa.",
                    "Compara la probabilidad de eventos simples en diversos contextos, incluso cuando los casos posibles son diferentes.",
                    "Selecciona la información necesaria para resolver problemas que involucran operaciones aritméticas.",
                    "Selecciona la información necesaria para resolver problemas relacionados con características medibles de figuras geométricas elementales.",
                    "Modifica la escala cuando la transformación no es convencional.",
                    "Justifica afirmaciones mediante planteamientos y operaciones aritméticas o a partir de un único concepto.",
                    "Identifica información relevante en registros que contienen más de tres categorías.",
                    "Realiza manipulaciones algebraicas sencillas con términos semejantes."
                };



            if (nivel == "2") return {
                    "Compara datos de dos variables presentadas en una misma gráfica sin realizar operaciones aritméticas.",
                    "Identifica valores o puntos representativos en distintos tipos de registro a partir de su significado en la situación.",
                    "Compara la probabilidad de eventos simples cuando los casos posibles son iguales en contextos similares.",
                    "Toma decisiones sobre la veracidad o falsedad de una afirmación a partir de la lectura directa de la información.",
                    "Transforma gráficas de barras en tablas de doble entrada.",
                    "Reconoce e interpreta, según el contexto, el significado de promedio simple, moda, mayor, menor, máximo y mínimo."
                };


            if (nivel == "1") return {
                    "Lee información puntual (un dato, por ejemplo) relacionada con situaciones cotidianas y presentada en tablas o gráficas con escala explícita, cuadrícula o, por lo menos, líneas horizontales."
                };
        }

        // Sociales y Ciudadanas - ejemplos
        if (materia == "Sociales y Ciudadanas") {
            if (nivel == "4") return {
                    "Conoce los procedimientos de reforma a la Constitución Política de Colombia, los mecanismos de participación ciudadana y las funciones de los organismos de control.",
                    "Compara enunciados, argumentos, intereses y posiciones de actores en contextos donde se discuten situaciones problemáticas o alternativas de solución.",
                    "Relaciona propuestas de solución a un problema con su contexto de implementación y con sus posibles impactos en distintas dimensiones.",
                    "Comprende problemáticas, eventos o procesos sociales mediante el uso de conceptos básicos de las ciencias sociales y de contextos históricos y/o geográficos.",
                    "Analiza fuentes primarias y secundarias para valorar inferencias, identificar intenciones, características de los actores y los contextos en los que se ubican.",
                    "Establece relaciones entre modelos conceptuales, las fuentes que los abordan y las decisiones sociales que los aplican."
                };


            if (nivel == "3") return {
                    "Valora y contextualiza la información presentada en una fuente.",
                    "Reconoce intenciones, prejuicios y argumentos similares o diferentes en un contexto o situación específica.",
                    "Identifica dimensiones económicas, políticas, culturales, ambientales, entre otras, involucradas en situaciones, problemáticas o propuestas de solución.",
                    "Identifica y compara opiniones e intereses de diferentes actores en una situación problemática y relaciona esas posturas con posibles soluciones.",
                    "Reconoce conceptos básicos de las ciencias sociales.",
                    "Identifica supuestos y usos de algunos modelos conceptuales.",
                    "Relaciona contextos históricos y/o geográficos con fuentes, situaciones y prácticas sociales.",
                    "Valora la información contenida en una fuente y reconoce sus alcances."
                };


            if (nivel == "2") return {
                    "Identifica relaciones entre las conductas de las personas y sus cosmovisiones.",
                    "Reconoce las dimensiones presentes en una situación, problema, decisión o propuesta de solución, y contextualiza fuentes y procesos sociales.",
                    "Identifica derechos ciudadanos y deberes del Estado establecidos en la Constitución Política de Colombia.",
                    "Relaciona la conducta de una persona con su cosmovisión o forma de entender el mundo.",
                    "Reconoce los efectos de una solución y las dimensiones que privilegia.",
                    "Identifica los contextos o procesos en los que se inscribe una fuente o evento."
                };


            if (nivel == "1") return {
                    "Reconoce algunos derechos ciudadanos en situaciones sencillas.",
                    "Reconoce factores que generan un conflicto.",
                    "Identifica creencias que explican algunos comportamientos."
                };

        }

        // Ciencias Naturales - ejemplos
        if (materia == "Ciencias Naturales") {

            if (nivel == "4") return {
                    "Plantea preguntas de investigación en ciencias naturales a partir de un contexto determinado.",
                    "Establece conclusiones derivadas de una investigación.",
                    "Contrasta modelos de las ciencias naturales con fenómenos cotidianos.",
                    "Resuelve situaciones problema utilizando conceptos, leyes y teorías de las ciencias naturales.",
                    "Comunica resultados de procesos de investigación científica.",
                    "Analiza fenómenos naturales con base en los procedimientos propios de la investigación científica."
                };


            if (nivel == "3") return {
                    "Establece relaciones de causa-efecto utilizando conceptos, leyes y teorías científicas.",
                    "Interpreta gráficas, tablas y modelos para realizar predicciones.",
                    "Relaciona conceptos, leyes y teorías científicas con diseños experimentales y sus resultados.",
                    "Diferencia entre evidencias y conclusiones.",
                    "Plantea hipótesis basadas en evidencias.",
                    "Relaciona variables para explicar fenómenos naturales."
                };


            if (nivel == "2") return {
                    "Identifica patrones y características a partir de información presentada en textos, gráficas y tablas.",
                    "Relaciona esquemas con nociones básicas del conocimiento científico.",
                    "Establece predicciones a partir de datos en tablas, gráficas y esquemas que muestran patrones crecientes o decrecientes.",
                    "Ordena datos e información en gráficas y tablas."
                };


            if (nivel == "1") return {
                    "Reconoce información explícita, presentada de manera ordenada en tablas o gráficas, con un lenguaje cotidiano y que implica la lectura de una sola variable independiente."
                };


        }

        // Inglés - ejemplos por nivel
        if (materia == "Inglés") {
            if (nivel == "B1") return {
                    "Comprende textos sobre temas generales y específicos en ámbitos laboral, académico, cultural y personal.",
                    "Infiere el significado de palabras desconocidas a partir del contexto dado.",
                    "Identifica puntos de vista, como sentimientos, deseos e intenciones, en escritos determinados."
                };

            if (nivel == "A2") return {
                    "Comprende textos sobre temáticas relacionadas con su contexto inmediato, como ocupaciones, personas, objetos, lugares o situaciones familiares.",
                    "Identifica vocabulario simple en textos cortos que narran acciones o eventos presentes, pasados o futuros.",
                    "Interpreta enunciados que expresan puntos de vista particulares en situaciones comunicativas simples.",
                    "Identifica y comprende información literal o parafraseada en textos cortos."
                };

            if (nivel == "A1") return {
                    "Identifica el uso de lenguaje básico para proporcionar información personal, saludos, despedidas, indicaciones de lugares y acciones del presente.",
                    "Comprende información e indicaciones presentes en avisos según el contexto en que se aplican."
                };

            if (nivel == "A-") return {
                    "Comprende oraciones, preguntas, instrucciones o conversaciones cuando se utiliza vocabulario simple.",
                    "Identifica palabras simples en frases sencillas que incluyen personas o lugares familiares en su cotidianidad."
                };

        }

        // Si llega aquí, fallback
        return {"Habilidades no definidas para este nivel y materia."};
    }

    BoletinData getBoletinData(int simId, int studentId) {
        BoletinData data;

        // 1. Datos básicos del estudiante y simulacro
        auto student = getStudentById(studentId);
        if (student.getId() < 0) return data; // inválido
        auto sim = getSimulacrumById(simId);
        if (sim.getId() < 0) return data;
        data.studentName = student.getFullname();
        data.simulacroName = sim.getName();
        QDate fecha = QDate::fromString(QString::fromStdString(sim.getDate()), "yyyy-MM-dd");
        data.fechaAplicacion = fecha.isValid() ? fecha.toString("dd/MM/yyyy").toStdString() : sim.getDate();

        // 2. Obtener todos los resultados del simulacro
        auto results = DatabaseManager::instance().getDetailedResultsBySimulacrum(simId);
        if (results.empty()) return data;

        // 3. Encontrar el resultado del estudiante específico
        DatabaseManager::FullResult studentResult;
        bool found = false;
        for (const auto& r : results) {
            if (DatabaseManager::instance().asegurarStudents(r.studentName) == studentId) {
                studentResult = r;
                found = true;
                break;
            }
        }
        if (!found) return data;

        // 4. Calcular puntaje global
        Result tempRes(studentId, simId, studentResult.l, studentResult.m, studentResult.s, studentResult.n, studentResult.i);
        Booklet tempBook("", studentResult.tL, studentResult.tM, studentResult.tS, studentResult.tN, studentResult.tI);
        data.puntajeGlobal = tempRes.calculateGlobalScore(tempBook);
        data.percentilGlobal = calculatePercentil(simId, studentId);

        // 6. Llenar las 5 materias fijas (orden obligatorio)
        std::vector<std::string> nombresMaterias = {
            "Lectura Crítica",
            "Matemáticas",
            "Sociales y Ciudadanas",
            "Ciencias Naturales",
            "Inglés"
        };
        std::vector<int> aciertosLista = {studentResult.l, studentResult.m, studentResult.s, studentResult.n, studentResult.i};
        std::vector<int> totalesLista = {studentResult.tL, studentResult.tM, studentResult.tS, studentResult.tN, studentResult.tI};

        for (size_t i = 0; i < 5; ++i) {
            MateriaData mat;
            mat.nombre = nombresMaterias[i];
            mat.aciertos = aciertosLista[i];
            mat.totalPreguntas = totalesLista[i];

            // CALCULO DEL PORCENTAJE → REDONDEADO A ENTERO
            double porcDouble = totalesLista[i] > 0
                                    ? (static_cast<double>(aciertosLista[i]) / totalesLista[i]) * 100.0
                                    : 0.0;
            mat.porcentaje = static_cast<int>(std::round(porcDouble));  // ← Esto es lo que faltaba

            // Percentil por área
            mat.percentil = calculatePercentilArea(simId, studentId, i);

            // Nivel de desempeño → usa el porcentaje ya redondeado
            mat.nivelStr = calculateNivelStr(i, static_cast<double>(mat.porcentaje));

            // Habilidades según materia y nivel
            mat.habilidades = getHabilidadesPorMateriaYNivel(mat.nombre, mat.nivelStr);

            data.materias.push_back(mat);
        }

        return data;
    }

private:
    SimulacrumService(){}
};

#endif
