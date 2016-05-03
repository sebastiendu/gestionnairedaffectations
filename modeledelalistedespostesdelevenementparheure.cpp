#include <QSqlQuery>
#include <QSqlError>
#include <QtDebug>
#include "modeledelalistedespostesdelevenementparheure.h"

ModeleDeLaListeDesPostesDeLEvenementParHeure::ModeleDeLaListeDesPostesDeLEvenementParHeure(QObject *parent)
    : QSortFilterProxyModel(parent)
{
}

void ModeleDeLaListeDesPostesDeLEvenementParHeure::setIdEvenement(int id_evenement)
{
    QSqlQuery query;
    if (query.prepare("select debut, fin,"
                      " id_poste, id_evenement, nom, description, posx, posy,"
                      " id_tour, min, max,"
                      " nombre_affectations, nombre_affectations_possibles, nombre_affectations_proposees,"
                      " nombre_affectations_validees_ou_acceptees, nombre_affectations_rejetees_ou_annulees"
                      " from poste_et_tour"
                      " where id_evenement = :id_evenement"
                      " order by debut, fin")) {
        query.bindValue(":id_evenement", id_evenement);
        if (query.exec()) {
            source.setQuery(query);
            setSourceModel(&source);
        } else {
            qCritical() << "Echec d'execution de la requête de la liste des postes de l'événement par heure :" << query.lastError();
        }
    } else {
        qCritical() << "Echec de préparation de la requête de la liste des postes de l'événement par heure :" << query.lastError();
    }

    invalidateFilter();
}

void ModeleDeLaListeDesPostesDeLEvenementParHeure::setHeure(const QDateTime &datetime)
{
    heure = datetime;
    invalidateFilter();
}

bool ModeleDeLaListeDesPostesDeLEvenementParHeure::filterAcceptsRow(int sourceRow,
                                                                    const QModelIndex &sourceParent) const
{
    return heure.isValid()
            && heure >= sourceModel()->data(sourceModel()->index(sourceRow, 0, sourceParent)).toDateTime()
            && heure <= sourceModel()->data(sourceModel()->index(sourceRow, 1, sourceParent)).toDateTime();
}
