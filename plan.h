#ifndef PLAN_H
#define PLAN_H
#include <QtQuick>
#include <QList>
#include "sqlquerymodel.h"
#include "poste.h"

class Plan: public QQuickView
{


public:
    Plan();

private:
    Q_OBJECT

    QList<Poste> listeDesPostes;
    SqlQueryModel *model;


};

#endif // PLAN_H
