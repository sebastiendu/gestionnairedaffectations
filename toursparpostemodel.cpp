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
                int debutEvenement = queryEvenement.value("debut").toInt();
                int finEvenement = queryEvenement.value("fin").toInt();
                int dureeEvenement = finEvenement - debutEvenement;
                QSqlQuery queryPoste;
                if (queryPoste.prepare(
                            "select poste.id, poste.nom, min(debut) as debut, max(fin) as fin"
                            " from poste left join tour on id_poste = poste.id"
                            " where poste.id_evenement = ?"
                            " group by poste.id, poste.nom"
                            " order by debut, fin")) {
                    queryPoste.addBindValue(idEvenement);
                    if (queryPoste.exec()) {
                        QSqlQuery queryTour;
                        if(queryTour.prepare("select concat_ws('|',"
                                             " id," // 0
                                             " (extract(epoch from debut) - " + QString::number(debutEvenement) + ") / " + QString::number(dureeEvenement) + "," // 1
                                             " (extract(epoch from fin) - extract(epoch from debut)) / " + QString::number(dureeEvenement) + "," // 2
                                             " min, max, debut, fin, effectif, besoin, faim, taux" // 3 à 10
                                             ")"
                                             " from taux_de_remplissage_tour"
                                             " where id_poste=?"
                                             " order by debut, fin")) {
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
