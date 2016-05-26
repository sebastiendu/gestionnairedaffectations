#ifndef LISTEDESDISPONIBILITESSANSTOURDETRAVAIL_H
#define LISTEDESDISPONIBILITESSANSTOURDETRAVAIL_H
#include "etat.h"

class ListeDesDisponibilitesSansAffectation : public Etat
{
public:
    ListeDesDisponibilitesSansAffectation(int idEvenement, QObject *parent);
};

#endif // LISTEDESDISPONIBILITESSANSTOURDETRAVAIL_H
