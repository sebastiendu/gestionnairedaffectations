#ifndef ABSTRACTTABLEMODEL_H
#define ABSTRACTTABLEMODEL_H

#include <QSqlQueryModel>

class AbstractTableModel : public QAbstractTableModel
{    
    Q_OBJECT

public:
    explicit AbstractTableModel(QObject *parent = 0);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    Q_INVOKABLE QVariant data (const QModelIndex & index) const;


signals:

public slots:


private:
    QList<QPair<QString, int> > mElements;


};

#endif // ABSTRACTTABLEMODEL_H
