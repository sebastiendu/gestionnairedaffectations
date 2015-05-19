#ifndef TOURSPARPOSTEMODEL_H
#define TOURSPARPOSTEMODEL_H

#include <QAbstractListModel>

class ToursParPosteModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ToursParPosteModel(QObject *parent = 0);

    void setIdEvenement(int idEvenement);

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int,QByteArray> roleNames() const;

signals:

public slots:

private:
    class Tour {
    public:
        int id;
        int debut;
        int fin;
    };

    class Poste {
    public:
        int id;
        QString nom;
        QList<Tour> tours;
    };

    QList<Poste> postes;
    int debutEvenement;
    int finEvenement;
};

#endif // TOURSPARPOSTEMODEL_H
