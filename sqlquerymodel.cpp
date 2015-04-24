#include "sqlquerymodel.h"
#include <QSqlRecord>

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
