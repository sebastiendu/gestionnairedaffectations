#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H

#include <QObject>
#include <QSqlTableModel>
#include <QSqlQuery>
#include <QSqlError>

class SqlTableModel : public QSqlTableModel
{
    Q_OBJECT

public:
    explicit SqlTableModel(QObject *parent = 0, QSqlDatabase db = QSqlDatabase());

    Q_INVOKABLE bool setData(int row, const QString &fieldName, const QVariant &value);
    Q_INVOKABLE bool submitAll() Q_DECL_OVERRIDE { return QSqlTableModel::submitAll(); }
    Q_INVOKABLE bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) Q_DECL_OVERRIDE { return QSqlTableModel::insertRows(row, count, parent); }
    Q_INVOKABLE QVariant lastInsertId() const { return query().lastInsertId(); }
    Q_INVOKABLE QString lastError() const { return QSqlTableModel::lastError().text(); }

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;
};

#endif // SQLTABLEMODEL_H
