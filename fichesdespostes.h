#ifndef FICHESDESPOSTES_H
#define FICHESDESPOSTES_H
#include "etat.h"

class FichesDesPostes : public Etat
{
    Q_OBJECT
public:
    FichesDesPostes(int idEvenement, QObject *parent);
};

#endif // FICHESDESPOSTES_H
