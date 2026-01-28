#ifndef SIMULACRUM_H
#define SIMULACRUM_H

#include <string>

class Simulacrum {
private:
    int m_id;
    int m_idBooklet;
    std::string m_name;
    std::string m_date; // Formato YYYY-MM-DD
public:

    Simulacrum(const std::string& name, const std::string& date, int idBooklet, int id = 0)
        : m_id(id), m_idBooklet(idBooklet), m_name(name), m_date(date) {}

    int getId() const { return m_id; }
    int getIdBooklet() const { return m_idBooklet; }
    std::string getName() const { return m_name; }
    std::string getDate() const { return m_date; }

};

#endif
