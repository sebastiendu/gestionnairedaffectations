#include "cartesdesbenevoles.h"
#include <QSqlQuery>
#include <QSqlRecord>
#include <QTextCursor>
#include <QLocale>
#include <QDate>
#include <QDebug>
#include <QSqlError>

CartesDesBenevoles::CartesDesBenevoles(int idEvenement, QObject*parent=0)
    : Etat(tr("Cartes des bénévoles"), idEvenement, parent)
{
    QSqlQuery query;
    if (query.prepare("select *"
                      " from carte_de_benevole_inscriptions_postes"
                      " where id_evenement=:id_evenement")) {
        query.bindValue(":id_evenement", idEvenement);
        if (query.exec()) {

            QTextCursor c(this);

            QTextBlockFormat formatDuBlocDuNomDeLaPersonne;
            formatDuBlocDuNomDeLaPersonne.setPageBreakPolicy(QTextFormat::PageBreak_AlwaysBefore);
            formatDuBlocDuNomDeLaPersonne.setAlignment(Qt::AlignCenter);
            formatDuBlocDuNomDeLaPersonne.setBottomMargin(20);

            QTextCharFormat formatDesCaracteresDuNomDeLaPersonne;
            formatDesCaracteresDuNomDeLaPersonne.setFontWeight(QFont::Bold);
            formatDesCaracteresDuNomDeLaPersonne.setFontPointSize(14);

            QTextBlockFormat formatDuBlocDeLaDate;
            formatDuBlocDeLaDate.setTopMargin(50);
            formatDuBlocDeLaDate.setAlignment(Qt::AlignLeft);

            QTextCharFormat formatDesCaracteresDeLaDate;
            formatDesCaracteresDeLaDate.setFontWeight(QFont::Bold);
            formatDesCaracteresDeLaDate.setFontCapitalization(QFont::Capitalize);

            QTextBlockFormat formatDuBlocDeLAffectation;

            QTextCharFormat formatDesCaracteresDeLAffecation;
            //formatDesCaracteresDeLAffecation.setUnderlineStyle(QTextCharFormat::SingleUnderline);

            if (query.first()) {
                QSqlRecord r = query.record();
                do {
                    int id_personne = r.value("id_personne").toInt();
                    QStringList tel{
                                r.value("domicile").toString(),
                                r.value("portable").toString()
                    };
                    tel.removeAll("");
                    c.movePosition(QTextCursor::End);
                    c.insertBlock(formatDuBlocDuNomDeLaPersonne, formatDesCaracteresDuNomDeLaPersonne);
                    c.insertText(
                                tr("%1 %2, %3")
                                .arg(r.value("prenom_personne").toString())
                                .arg(r.value("nom_personne").toString())
                                .arg(r.value("ville").toString())
                                );
                    if (!tel.isEmpty()) {
                        c.insertText(tr(" (%1)").arg(tel.join(" — ")));
                    }
                    // TODO: plan de l'évènement avec indication de l'emplacement des postes listés
                    // TODO: description des postes
                    do {
                        QDate jour = r.value("debut_tour").toDate();
                        c.movePosition(QTextCursor::End);
                        c.insertBlock(formatDuBlocDeLaDate, formatDesCaracteresDeLaDate);
                        c.insertText(QLocale().toString(jour));
                        c.movePosition(QTextCursor::End);
                        do {
                            c.insertBlock(formatDuBlocDeLAffectation, formatDesCaracteresDeLAffecation);
                            c.insertText(tr("De %1 à %2 : %3")
                                         .arg(r.value("debut_tour").toTime().toString("H:mm"))
                                         .arg(r.value("fin_tour").toTime().toString("H:mm"))
                                         .arg(r.value("nom_poste").toString())
                                         );
                            query.next();
                            r = query.record();
                        } while (query.isValid()
                                 && r.value("id_personne").toInt() == id_personne
                                 && r.value("debut_tour").toDate() == jour);
                    } while (query.isValid()
                             && r.value("id_personne").toInt() == id_personne);
                } while (query.isValid());
            } else {
                qWarning() << tr("Aucune affectation trouvée");
            }
        } else {
            qCritical() << query.lastError();
        }
    } else {
        qCritical() << query.lastError();
    }
}
