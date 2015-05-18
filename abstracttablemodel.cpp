#include "abstracttablemodel.h"

AbstractTableModel::AbstractTableModel(QObject *parent) :
    QAbstractTableModel(parent)
{

}

QVariant AbstractTableModel::data(const QModelIndex &index) const
{
    if (!index.isValid() || index.row() < 0)
    {
        return QVariant();
    }

   else {
      return mElements[index.row()].first;

    }

    return QVariant();
}

int AbstractTableModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : mElements.count();
}
