#ifndef TOURSPARPOSTEMODEL_H
#define TOURSPARPOSTEMODEL_H

#include <QAbstractListModel>

class ToursParPosteModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ToursParPosteModel(QObject *parent = 0);

    void setIdEvenement(int idEvenement);

    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int,QByteArray> roleNames() const;

signals:

public slots:

private:

    class Poste {
    public:
        int id;
        QString nom;
        QStringList tours;
    };

    QList<Poste> postes;
};

#endif // TOURSPARPOSTEMODEL_H
