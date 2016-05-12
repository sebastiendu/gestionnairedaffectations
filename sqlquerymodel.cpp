#include "sqlquerymodel.h"
#include <QSqlRecord>
#include <QtDebug>
#include <QSqlError>
#include <QSqlQuery>

SqlQueryModel::SqlQueryModel(QObject *parent) :
    QSqlQueryModel(parent)
{
}

QVariant SqlQueryModel::data(const QModelIndex &index, int role) const
{
    QVariant value = QSqlQueryModel::data(index, role);
    if(role < Qt::UserRole)
    {
        value = QSqlQueryModel::data(index, role);
    }
    else
    {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}

QVariant SqlQueryModel::data(int row, const QString &fieldName) const
{
    return data(createIndex(row, fieldIndex(fieldName)), Qt::DisplayRole);
}

QHash<int, QByteArray> SqlQueryModel::roleNames() const {
    QHash<int, QByteArray> roleNames;
    for( int i = 0; i < record().count(); i++) {
        roleNames[Qt::UserRole + i + 1] = record().fieldName(i).toLatin1();
    }
    return roleNames;
}

int SqlQueryModel::getIdFromIndex(int index) {
    return this->data(this->index(index, 0), 0).toInt();
}

int SqlQueryModel::getIndexFromId(int id) {
    for(int index = 0; index < this->rowCount(); index ++) {
        if (id == this->data(this->index(index, 0), 0).toInt()) {
            return index;
        }
    }
    return -1;
}

QVariant SqlQueryModel::getDataFromModel(int ligne, QString colonne)
{
    return record(ligne).value(colonne).toString();
}

void SqlQueryModel::reload()
{
    if (query().exec()) {
        setQuery(query());
    } else {
        qCritical() << tr("Echec de ré-execution de la requète %1 : %2").arg(query().lastQuery()).arg(lastError().text());
    }
}

int SqlQueryModel::rowCount()
{
    return QSqlQueryModel::rowCount();
}

int SqlQueryModel::fieldIndex(const QString &fieldName) const
{
    return query().record().indexOf(fieldName);
}
