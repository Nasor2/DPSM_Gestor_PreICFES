#ifndef BOOKLET_H
#define BOOKLET_H

#include <string>

class Booklet {
private:
    int m_id;
    std::string m_name;
    int m_tLectura, m_tMatematicas, m_tSociales, m_tNaturales, m_tIngles;

public:
    Booklet(const std::string& name, int l, int m, int s, int n, int i, int id = 0):
        m_id(id), m_name(name), m_tLectura(l), m_tMatematicas(m),
        m_tSociales(s), m_tNaturales(n), m_tIngles(i) {}

    //Getters
    int getId() const { return m_id; }
    std::string getName() const { return m_name; }
    int getTLectura() const { return m_tLectura; }
    int getTMatematicas() const { return m_tMatematicas; }
    int getTSociales() const { return m_tSociales; }
    int getTNaturales() const { return m_tNaturales; }
    int getTIngles() const { return m_tIngles; }

    //Setters
    void setName(const std::string& n){
        m_name = n;
    }
    void setTotals(int l, int m, int s, int n, int i) {
        m_tLectura = l; m_tMatematicas = m; m_tSociales = s;
        m_tNaturales = n; m_tIngles = i;
    }
    void setId(int id) {
        m_id = id;
    }
};

#endif
