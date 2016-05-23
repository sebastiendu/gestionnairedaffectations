#include "etat.h"
#include <QTextCursor>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QLocale>
#include <QDate>
#include <QDebug>
#include <QSqlError>

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

                QTextBlockFormat formatDUnBlocNormal(c.blockFormat());
                formatDUnBlocNormal.setAlignment(Qt::AlignCenter);

                QTextCharFormat formatDesCaracteresNormaux(c.charFormat());

                QTextBlockFormat formatDuBlocDeTitre;
                formatDuBlocDeTitre.setAlignment(Qt::AlignHCenter);
                formatDuBlocDeTitre.setBottomMargin(100);
                formatDuBlocDeTitre.setTopMargin(100);

                QTextCharFormat formatDesCaracteresDuTitre;
                formatDesCaracteresDuTitre.setFontWeight(QFont::Bold);
                formatDesCaracteresDuTitre.setFontPointSize(30);

                c.movePosition(QTextCursor::Start);

                c.insertBlock(formatDUnBlocNormal, formatDesCaracteresNormaux);
                c.insertText(r.value("nom").toString());

                c.insertBlock();
                c.insertText(
                            tr("%1, du %3 au %4")
                            .arg(r.value("lieu").toString())
                            .arg(QLocale().toString(r.value("debut").toDate()))
                            .arg(QLocale().toString(r.value("fin").toDate()))
                            );

                c.insertBlock(formatDuBlocDeTitre, formatDesCaracteresDuTitre);
                c.insertText(titre);

                c.insertBlock(formatDUnBlocNormal, formatDesCaracteresNormaux);
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
