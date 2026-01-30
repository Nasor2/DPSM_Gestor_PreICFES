#ifndef STUDENT_H
#define STUDENT_H

#include <string>
#include <stdexcept>

class Student {
public:
    Student(const std::string& fullname, const std::string& identification, const std::string& school, int id = 0)
        : m_id(id), m_fullname(fullname), m_identification(identification), m_school(school) {
        if (fullname.empty()) {
            throw std::invalid_argument("El nombre no puede estar vacio");
        }
        if (identification.empty()) {
            throw std::invalid_argument("La identificacion no puede estar vacia");
        }
    }

    //Getters
    int getId() const { return m_id; }
    std::string getFullname() const { return m_fullname; }
    std::string getIdentification() const { return m_identification; }
    std::string getSchool() const { return m_school; }

    //setters
    void setId(int newId) { m_id = newId; }
    void setFullname(const std::string& newFullname) { m_fullname = newFullname; }
    void setIdentification(const std::string& newIdentification) { m_identification = newIdentification; }
    void setSchool(const std::string& newSchool) { m_school = newSchool; }

private:
    int m_id;
    std::string m_fullname;
    std::string m_identification;
    std::string m_school;

};

#endif
