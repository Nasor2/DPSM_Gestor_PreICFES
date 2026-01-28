#ifndef STUDENT_H
#define STUDENT_H

#include <string>
#include <stdexcept>

class Student {
public:
    Student(const std::string& fullname, int id = 0): m_id(id), m_fullname(fullname) {
        if (fullname.empty()){
            throw std::invalid_argument("El nombre no puede estar vacio");
        }
    }

    //Getters
    int getId() const {
        return m_id;
    }
    std::string getFullname() const {
        return m_fullname;
    }

    //setters
    void setId(int newId){
        m_id = newId;
    }
    void setFullname(const std::string& newFullname){
        m_fullname = newFullname;
    }

private:
    int m_id;
    std::string m_fullname;

};

#endif
