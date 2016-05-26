#include <QSqlRecord>
#include <QTemporaryFile>
#include <QProcess>
#include <QDebug>
#include "sqltablemodel.h"
#include "qxtcsvmodel.h"

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

void SqlTableModel::ouvrirCSV(QString commande)
{
    QTemporaryFile* temporaryFile = new QTemporaryFile(parent());
    if (temporaryFile->open()) {
        QxtCsvModel csv(this);
        csv.insertColumns(0, columnCount());
        csv.insertRows(0, rowCount());
        for (int column = 0; column < csv.columnCount(); column ++) {
            csv.setHeaderText(column, headerData(column, Qt::Horizontal).toString());
        }
        for (int row = 0; row < csv.rowCount(); row ++) {
            for (int column = 0; column < csv.columnCount(); column ++) {
                csv.setText(row, column, QSqlTableModel::data(index(row, column)).toString());
            }
        }
        csv.toCSV(temporaryFile->fileName(), true);
        temporaryFile->close();
        QProcess* process = new QProcess();
        process->start(commande, QStringList { temporaryFile->fileName() });
        connect(process, SIGNAL(finished(int)), temporaryFile, SLOT(deleteLater()));
    } else {
        qCritical() << temporaryFile->errorString();
    }

}

QHash<int, QByteArray> SqlTableModel::roleNames() const {
    QHash<int, QByteArray> roleNames;
    for( int i = 0; i < record().count(); i++) {
        roleNames[Qt::UserRole + i + 1] = record().fieldName(i).toLatin1();
    }
    return roleNames;
}
