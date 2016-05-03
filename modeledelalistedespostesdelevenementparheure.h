#ifndef MODELEDELALISTEDESPOSTESDELEVENEMENTPARHEURE_H
#define MODELEDELALISTEDESPOSTESDELEVENEMENTPARHEURE_H

#include <QDateTime>
#include <QSortFilterProxyModel>
#include "sqlquerymodel.h"

class ModeleDeLaListeDesPostesDeLEvenementParHeure : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    ModeleDeLaListeDesPostesDeLEvenementParHeure(QObject *parent = 0);

    void setIdEvenement(int id_evenement);
    void setHeure(const QDateTime &datetime);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const Q_DECL_OVERRIDE;

private:
    QDateTime heure;
    SqlQueryModel source;
};

#endif // MODELEDELALISTEDESPOSTESDELEVENEMENTPARHEURE_H
