#ifndef SORTFILTERPROXYMODEL_H
#define SORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>

class SortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit SortFilterProxyModel(QObject *parent = 0);


    Q_INVOKABLE QVariant getDataFromModel(const QModelIndex &ligne, int colonne);

signals:

public slots:

};

#endif // SORTFILTERPROXYMODEL_H
