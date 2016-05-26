#ifndef TABLEAUDEREMPLISSAGE_H
#define TABLEAUDEREMPLISSAGE_H
#include "etat.h"

class TableauDeRemplissage : public Etat
{
public:
    TableauDeRemplissage(int idEvenement, QObject *parent);
};

#endif // TABLEAUDEREMPLISSAGE_H
