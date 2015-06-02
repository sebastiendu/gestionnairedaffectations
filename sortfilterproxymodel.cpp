#include "sortfilterproxymodel.h"

SortFilterProxyModel::SortFilterProxyModel(QObject *parent) :
    QSortFilterProxyModel(parent)
{
}

QVariant SortFilterProxyModel::getDataFromModel(const QModelIndex &ligne, int colonne)
{
    return data(ligne,colonne).toString();
}
