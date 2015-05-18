#include "toursparpostemodel.h"
#include <QSqlQuery>
#include <QDebug>
#include <QSqlError>

ToursParPosteModel::ToursParPosteModel(QObject *parent) :
    QAbstractListModel(parent)
{
}

void ToursParPosteModel::setIdEvenement(int idEvenement) {
    QSqlQuery query;
    if (query.prepare("select poste.nom, poste.id, string_agg(debut::varchar, ',') as debuts, string_agg(fin::varchar, ',') as fins"
                      " from poste left join tour on id_poste = poste.id"
                      " where poste.id_evenement = ?"
                      " group by poste.nom, poste.id"
                      " order by poste.nom, poste.id")) {
        query.addBindValue(idEvenement);
        if (query.exec()) {
            while (query.next()) {
                Poste poste;
                poste.id = query.value("id").toInt();
                poste.nom = query.value("nom").toString();
                QStringList debuts = query.value("debuts").toString().split(',');
                QStringList fins = query.value("fins").toString().split(',');
                for (int i = 0; i < debuts.size(); ++i) {
                    Tranche tranche;
                    tranche.debut = debuts.at(i).toInt();
                    tranche.fin = fins.at(i).toInt();
                    poste.tranches.append(tranche);
                }
                postes.append(poste);
            }
        } else {
            qDebug() << "Echec d'execution de la requête de lecture des postes et des tours pour l'emploi du temps :" << query.lastError();
        }
    } else {
        qDebug() << "Echec de préparation de la requête de lecture des postes et des tours pour l'emploi du temps :" << query.lastError();
    }
}

int ToursParPosteModel::rowCount(const QModelIndex &parent) const
{
    return postes.length();
}

int ToursParPosteModel::columnCount(const QModelIndex &parent) const
{
    return 2;
}

QVariant ToursParPosteModel::data(const QModelIndex &index, int role) const
{
    Poste poste = postes.at(index.row());
    return role == 0 ? QVariant(poste.id) : QVariant(poste.nom);
}

QHash<int, QByteArray> ToursParPosteModel::roleNames() const
{
    QHash<int, QByteArray> hash;
    hash.insert(0, "id");
    hash.insert(1, "nom");
    return hash;
}
