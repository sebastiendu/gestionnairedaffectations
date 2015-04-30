#ifndef POSTE_H
#define POSTE_H
#include <string>
#include <QtQuick>
#include <QObject>

using namespace std;

class Poste
{

        public:
           Poste();
           string getNom();
           string getDescription();
           int getX();
           int getY();

           void setDescription(string description);
           void setNom(string nom);
           void setPosition(int x,int y);

        private:
           int x;
           int y;
           string nom;
           string description;

};



#endif // POSTE_H
