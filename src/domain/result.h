#ifndef RESULT_H
#define RESULT_H

#include "booklet.h"

class Result {
private:
    int m_id;
    int m_idStudent;
    int m_idSimulacrum;
    // Aciertos obtenidos
    int m_aLectura, m_aMatematicas, m_aSociales, m_aNaturales, m_aIngles;
public:
    Result(int idStu, int idSim, int l, int m, int s, int n, int i, int id = 0)
        : m_id(id), m_idStudent(idStu), m_idSimulacrum(idSim),
        m_aLectura(l), m_aMatematicas(m), m_aSociales(s), m_aNaturales(n), m_aIngles(i) {}

    // LÓGICA DE NEGOCIO: Cálculo del Puntaje Global (0-500)
    // Se le pasa el Cuadernillo para saber los totales de preguntas
    int calculateGlobalScore(const Booklet& b) const {
        auto calcArea = [](int aciertos, int total) {
            return (total > 0) ? (static_cast<double>(aciertos) / total) * 100.0 : 0.0;
        };

        double pL = calcArea(m_aLectura, b.getTLectura());
        double pM = calcArea(m_aMatematicas, b.getTMatematicas());
        double pS = calcArea(m_aSociales, b.getTSociales());
        double pN = calcArea(m_aNaturales, b.getTNaturales());
        double pI = calcArea(m_aIngles, b.getTIngles());

        // Ponderación oficial: 4 materias peso 3, Inglés peso 1. Suma pesos = 13.
        double sumaPonderada = (pL * 3) + (pM * 3) + (pS * 3) + (pN * 3) + (pI * 1);
        return static_cast<int>((sumaPonderada / 13.0) * 5.0);
    }

    // Getters de aciertos
    int getRLectura() const { return m_aLectura; }
    int getRMatematicas() const { return m_aMatematicas; }
    int getRSociales() const { return m_aSociales; }
    int getRNaturales() const { return m_aNaturales; }
    int getRIngles() const { return m_aIngles; }
    int getIdStudent() const {return m_idStudent;}
    int getIdSimulacrum() const {return m_idSimulacrum;}

    //Setters
    void setRights(int l, int m, int s, int n, int i) {
        m_aLectura = l; m_aMatematicas = m; m_aSociales = s;
        m_aNaturales = n; m_aIngles = i;
    }
    void setId(int id) { m_id = id; }
};

#endif // RESULT_H
