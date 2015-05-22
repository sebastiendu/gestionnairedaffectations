#ifndef SQLQUERYMODEL_H
#define SQLQUERYMODEL_H

#include <QSqlQueryModel>

class SqlQueryModel: public QSqlQueryModel
{
    Q_OBJECT

public:
    explicit SqlQueryModel(QObject *parent = 0);

    Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;
    Q_INVOKABLE int getIdFromIndex(int);
    Q_INVOKABLE int getIndexFromId(int);


    Q_INVOKABLE QVariant getDataFromModel(int ligne, QString colonne);

signals:

public slots:

};

#endif // SQLQUERYMODEL_H
