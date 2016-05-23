#ifndef ETAT_H
#define ETAT_H
#include <QTextDocument>

class Etat : public QTextDocument
{
    QString titre;
    int idEvenement;
public:
    Etat(QString titre, int idEvenement, QObject *parent = 0);
};

#endif // ETAT_H
