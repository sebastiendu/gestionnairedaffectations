#include "toursparpostemodel.h"
#include <QSqlQuery>
#include <QDebug>
#include <QSqlError>

ToursParPosteModel::ToursParPosteModel(QObject *parent) :
    QAbstractListModel(parent)
{
}
void ToursParPosteModel::setIdEvenement(int idEvenement) {
    QSqlQuery queryPoste;
    if (queryPoste.prepare(
                "select id, nom"
                " from postes_par_ordre_chronologique"
                " where id_evenement = ?")) {
        queryPoste.addBindValue(idEvenement);
        if (queryPoste.exec()) {
            QSqlQuery queryTour;
            if(queryTour.prepare(
                        "select concat_ws('|',"
                        " id, position_relative, duree_relative, min, max, debut, fin, effectif, besoin, faim, taux"
                         ")"
                         " from tours_emploi_du_temps"
                         " where id_poste=?")) {
                while (queryPoste.next()) {
                    Poste poste;
                    poste.id = queryPoste.value("id").toInt();
                    poste.nom = queryPoste.value("nom").toString();
                    queryTour.addBindValue(poste.id);
                    if (queryTour.exec()) {
                        while (queryTour.next()) {
                            poste.tours.append(queryTour.value(0).toString());
                        }
                        postes.append(poste);
                    } else {
                        qDebug() << "Echec d'execution de la requête de lecture des tours du poste" << poste.id << "(" << poste.nom << ") :" << queryTour.lastError();
                    }
                }
            } else {
                qDebug() << "Echec de preparation de la requête de lecture des tours d'un poste :" << queryTour.lastError();
            }
        } else {
            qDebug() << "Echec d'execution de la requête de lecture des postes de l'evenement" << idEvenement << ":" << queryPoste.lastError();
        }
    } else {
        qDebug() << "Echec de préparation de la requête de lecture des postes d'un évènement' :" << queryPoste.lastError();
    }
}

int ToursParPosteModel::rowCount(const QModelIndex &parent) const
{
    return postes.length();
}

int ToursParPosteModel::columnCount(const QModelIndex &parent) const
{
    return 3;
}

QVariant ToursParPosteModel::data(const QModelIndex &index, int role) const
{
    Poste poste = postes.at(index.row());
    QVariant data;
    switch (role) {
    case 0:
        data = poste.id;
        break;
    case 1:
        data = poste.nom;
        break;
    case 2:
        data = poste.tours;
        break;
    }
    return data;
}

QHash<int, QByteArray> ToursParPosteModel::roleNames() const
{
    QHash<int, QByteArray> hash;
    hash.insert(0, "id");
    hash.insert(1, "nom");
    hash.insert(2, "tours");
    return hash;
}
