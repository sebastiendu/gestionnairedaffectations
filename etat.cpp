#include "etat.h"
#include <QTextCursor>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QLocale>
#include <QDate>
#include <QDebug>
#include <QSqlError>
#include <QTemporaryFile>
#include <QPrinter>
#include <QProcess>
#include <QTextDocumentWriter>

Etat::Etat(QString titre, int idEvenement, QObject *parent) :
    QTextDocument(parent),
    titre(titre),
    idEvenement(idEvenement)
{
    setUndoRedoEnabled(false);
    QTextCursor c(this);
    QSqlQuery query;
    if (query.prepare("select nom, lieu, debut, fin"
                      " from evenement"
                      " where id = :id_evenement")) {
        query.bindValue(":id_evenement", idEvenement);
        if (query.exec()) {
            if (query.first()) {
                QSqlRecord r = query.record();

                QTextBlockFormat formatDuBlocDuNom;
                formatDuBlocDuNom.setAlignment(Qt::AlignCenter);

                QTextCharFormat formatDesCaracteresDuNom;
                formatDesCaracteresDuNom.setFontWeight(QFont::Bold);

                QTextBlockFormat formatDuBlocDuLieuEtDesDates;
                formatDuBlocDuLieuEtDesDates.setAlignment(Qt::AlignCenter);

                QTextCharFormat formatDesCaracteresDuLieuEtDesDates;

                QTextBlockFormat formatDuBlocDeTitre;
                formatDuBlocDeTitre.setAlignment(Qt::AlignHCenter);
                formatDuBlocDeTitre.setBottomMargin(100);
                formatDuBlocDeTitre.setTopMargin(100);

                QTextCharFormat formatDesCaracteresDuTitre;
                formatDesCaracteresDuTitre.setFontWeight(QFont::Bold);
                formatDesCaracteresDuTitre.setFontPointSize(30);

                QTextBlockFormat formatDuBlocDeLaDate;
                formatDuBlocDeLaDate.setAlignment(Qt::AlignRight);
                formatDuBlocDeLaDate.setBottomMargin(100);

                QTextCharFormat formatDesCaracteresDeLaDate;

                c.movePosition(QTextCursor::Start);

                c.insertBlock(formatDuBlocDuNom, formatDesCaracteresDuNom);
                c.insertText(r.value("nom").toString());

                c.insertBlock(formatDuBlocDuLieuEtDesDates, formatDesCaracteresDuLieuEtDesDates);
                c.insertText(
                            tr("%1, du %3 au %4")
                            .arg(r.value("lieu").toString())
                            .arg(QLocale().toString(r.value("debut").toDate()))
                            .arg(QLocale().toString(r.value("fin").toDate()))
                            );

                c.insertBlock(formatDuBlocDeTitre, formatDesCaracteresDuTitre);
                c.insertText(titre);

                c.insertBlock(formatDuBlocDeLaDate, formatDesCaracteresDeLaDate);
                c.insertText(
                            tr("Rapport généré le %1").arg(
                                QLocale().toString(QDateTime::currentDateTime()))
                            );
            } else {
                qCritical() << tr("evenement %1 introuvable").arg(idEvenement);
            }
        } else {
            qCritical() << query.lastError();
        }
    } else {
        qCritical() << query.lastError();
    }
}

void Etat::ouvrirPDF(QString commande)
{
    QTemporaryFile* temporaryFile = new QTemporaryFile(parent());
    if (temporaryFile->open()) {
        QPrinter printer;
        temporaryFile->close();
        printer.setOutputFileName(temporaryFile->fileName());
        print(&printer);
        QProcess* process = new QProcess();
        process->start(commande, QStringList { printer.outputFileName() });
        connect(process, SIGNAL(finished(int)), temporaryFile, SLOT(deleteLater()));
    } else {
        qCritical() << temporaryFile->errorString();
    }
}

void Etat::ouvrirODT(QString commande)
{
    QTemporaryFile* temporaryFile = new QTemporaryFile(parent());
    if (temporaryFile->open()) {
        QTextDocumentWriter writer(temporaryFile, "odt");
        if (writer.write(this)) {
            temporaryFile->close();
            QProcess* process = new QProcess();
            connect(process, SIGNAL(finished(int)), temporaryFile, SLOT(deleteLater()));
            process->start(commande, QStringList { writer.fileName() });
        } else {
            qCritical() << tr("Echec d'écriture du document ODT dans le fichier '%1'")
                           .arg(temporaryFile->fileName());
        }
    } else {
        qCritical() << temporaryFile->errorString();
    }
}
