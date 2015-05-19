#include "toursparpostemodel.h"
#include <QSqlQuery>
#include <QDebug>
#include <QSqlError>

ToursParPosteModel::ToursParPosteModel(QObject *parent) :
    QAbstractListModel(parent)
{
}
void ToursParPosteModel::setIdEvenement(int idEvenement) {
    QSqlQuery queryEvenement;
    if (queryEvenement.prepare("select"
                               " extract(epoch from min(debut)) as debut,"
                               " extract(epoch from max(fin)) as fin"
                               " from poste left join tour on id_poste = poste.id"
                               " where id_evenement = ?")) {
        queryEvenement.addBindValue(idEvenement);
        if (queryEvenement.exec()) {
            if (queryEvenement.first()) {
                debutEvenement = queryEvenement.value("debut").toInt();
                finEvenement = queryEvenement.value("fin").toInt();
                QSqlQuery queryPoste;
                if (queryPoste.prepare(
                            "select id, nom"
                            " from poste"
                            " where poste.id_evenement = ?"
                            " order by nom, id")) {
                    queryPoste.addBindValue(idEvenement);
                    if (queryPoste.exec()) {
                        QSqlQuery queryTour;
                        if(queryTour.prepare("select id, extract(epoch from debut) as debut, extract(epoch from fin) as fin"
                                             " from tour"
                                             " where id_poste=?"
                                             " order by debut, fin")) {
                            while (queryPoste.next()) {
                                Poste poste;
                                poste.id = queryPoste.value("id").toInt();
                                poste.nom = queryPoste.value("nom").toString();
                                queryTour.addBindValue(poste.id); // Vérifier si ça marche
                                if (queryTour.exec()) {
                                    while (queryTour.next()) {
                                        Tour tour;
                                        tour.id = queryTour.value("id").toInt();
                                        tour.debut = queryTour.value("debut").toInt();
                                        tour.fin = queryTour.value("fin").toInt();;
                                        poste.tours.append(tour);
                                    }
                                    postes.append(poste);
                                } else {
                                    qDebug() << "Echec d'execution de la requête de lecture des tours du poste" << poste.id << "(" << poste.nom << ") :" << queryPoste.lastError();
                                }
                            }
                        } else {
                            qDebug() << "Echec de preparation de la requête de lecture des tours d'un poste :" << queryPoste.lastError();
                        }
                    } else {
                        qDebug() << "Echec d'execution de la requête de lecture des postes de l'evenement" << idEvenement << ":" << queryPoste.lastError();
                    }
                } else {
                    qDebug() << "Echec de préparation de la requête de lecture des postes d'un évènement' :" << queryPoste.lastError();
                }
            } else {
                qDebug() << "Evenement numéro" << idEvenement << "introuvable";
            }
        } else {
            qDebug() << "Echec d'execution de la requête de récupération des dates de début et de fin de l'évènement" << idEvenement << ":" << queryEvenement.lastError();
        }
    } else {
        qDebug() << "Echec de préparation de la requête de récupération des dates de début et de fin d'un évènement :" << queryEvenement.lastError();
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
        int dureeEvenement = finEvenement - debutEvenement;
        QStringList list;
        for (int i = 0; i < poste.tours.length(); ++i) {
            Tour tour = poste.tours[i];
            list << QString::number(tour.id)
                    + '|' + QString::number(float(tour.debut - debutEvenement)/dureeEvenement)
                    + '|' + QString::number(float(tour.fin - tour.debut)/dureeEvenement);
        }
        data = list;
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
