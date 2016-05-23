#include "fichesdespostes.h"
#include <QSqlQuery>
#include <QSqlRecord>
#include <QTextCursor>
#include <QLocale>
#include <QDate>
#include <QDebug>
#include <QSqlError>

FichesDesPostes::FichesDesPostes(int idEvenement, QObject *parent)
    : Etat(tr("Fiches des postes"), idEvenement, parent)
{
    QSqlQuery query;
    if (query.prepare("select *"
                      " from fiche_de_poste_benevoles_par_tour"
                      " where id_evenement=:id_evenement")) {
        query.bindValue(":id_evenement", idEvenement);
        if (query.exec()) {

            QTextCursor c(this);

            QTextBlockFormat formatDuBlocDuNomDuPoste;
            formatDuBlocDuNomDuPoste.setPageBreakPolicy(QTextFormat::PageBreak_AlwaysBefore);
            formatDuBlocDuNomDuPoste.setAlignment(Qt::AlignCenter);
            formatDuBlocDuNomDuPoste.setBottomMargin(20);

            QTextCharFormat formatDesCaracteresDuNomDuPoste;
            formatDesCaracteresDuNomDuPoste.setFontWeight(QFont::Bold);
            formatDesCaracteresDuNomDuPoste.setFontPointSize(14);

            QTextBlockFormat formatDuBlocDeLaDate;
            formatDuBlocDeLaDate.setTopMargin(50);

            QTextCharFormat formatDesCaracteresDeLaDate;
            formatDesCaracteresDeLaDate.setFontWeight(QFont::Bold);
            formatDesCaracteresDeLaDate.setFontCapitalization(QFont::Capitalize);

            QTextBlockFormat formatDuBlocDeLHeure;
            formatDuBlocDeLHeure.setTopMargin(20);

            QTextCharFormat formatDesCaracteresDeLHeure;
            formatDesCaracteresDeLHeure.setFontWeight(QFont::Bold);

            QTextBlockFormat formatDuBlocDeLAffectation;

            QTextCharFormat formatDesCaracteresDeLAffecation;

            if (query.first()) {
                QSqlRecord r = query.record();
                do {
                    int id_poste = r.value("id_poste").toInt();
                    c.movePosition(QTextCursor::End);
                    c.insertBlock(formatDuBlocDuNomDuPoste, formatDesCaracteresDuNomDuPoste);
                    c.insertText(r.value("nom_poste").toString());
                    // TODO : description poste
                    // TODO : position sur le plan
                    do {
                        QDate jour = r.value("debut_tour").toDate();
                        c.movePosition(QTextCursor::End);
                        c.insertBlock(formatDuBlocDeLaDate, formatDesCaracteresDeLaDate);
                        c.insertText(QLocale().toString(jour));
                        do {
                            int id_tour = r.value("id_tour").toInt();
                            c.movePosition(QTextCursor::End);
                            c.insertBlock(formatDuBlocDeLHeure, formatDesCaracteresDeLHeure);
                            c.insertText(tr("De %1 à %2")
                                         .arg(r.value("debut_tour").toTime().toString("H:mm"))
                                         .arg(r.value("fin_tour").toTime().toString("H:mm"))
                                         );
                            do {
                                QStringList tel { r.value("domicile").toString(), r.value("portable").toString() };
                                tel.removeAll("");
                                // TODO : liste numérotée
                                c.movePosition(QTextCursor::End);
                                c.insertBlock(formatDuBlocDeLAffectation, formatDesCaracteresDeLAffecation);
                                c.insertText(tr("%1 %2")
                                             .arg(r.value("prenom_personne").toString())
                                             .arg(r.value("nom_personne").toString())
                                             );
                                if (!r.value("ville").toString().isEmpty()) {
                                    c.insertText(tr(", %1").arg(r.value("ville").toString()));
                                }
                                if (!tel.isEmpty()) {
                                    c.insertText(tr(" (%1)").arg(tel.join(" — ")));
                                }
                                query.next();
                                r = query.record();
                            } while (query.isValid()
                                     && r.value("id_tour").toInt() == id_tour);
                            // TODO : compléter la liste avec des lignes vides numérotées (jusqu'à tour.min en noir et jusqu'à tour.max en gris) pour compléter à la main
                        } while (query.isValid()
                                 && r.value("id_poste").toInt() == id_poste
                                 && r.value("debut_tour").toDate() == jour);
                    } while (query.isValid()
                             && r.value("id_poste").toInt() == id_poste);
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
