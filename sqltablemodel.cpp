#include <QSqlRecord>
#include "sqltablemodel.h"

SqlTableModel::SqlTableModel(QObject *parent, QSqlDatabase db):
    QSqlTableModel(parent, db)
{
    setEditStrategy(OnManualSubmit);
}

QVariant SqlTableModel::data(int row, const QString &fieldName) const
{
    return data(createIndex(row, fieldIndex(fieldName)), Qt::DisplayRole);
}

QVariant SqlTableModel::data(const QModelIndex &index, int role) const
{
    QVariant value;
    if(role < Qt::UserRole)
    {
        value = QSqlTableModel::data(index, role);
    }
    else
    {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        value = QSqlTableModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}

bool SqlTableModel::setData(int row, const QString &fieldName, const QVariant &value)
{
    return QSqlTableModel::setData(createIndex(row, fieldIndex(fieldName)), value, Qt::EditRole);
}

QHash<int, QByteArray> SqlTableModel::roleNames() const {
    QHash<int, QByteArray> roleNames;
    for( int i = 0; i < record().count(); i++) {
        roleNames[Qt::UserRole + i + 1] = record().fieldName(i).toLatin1();
    }
    return roleNames;
}
