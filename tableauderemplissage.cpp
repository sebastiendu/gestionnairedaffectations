#include "tableauderemplissage.h"
#include <QSqlQuery>
#include <QSqlRecord>
#include <QTextCursor>
#include <QLocale>
#include <QDate>
#include <QDebug>
#include <QSqlError>

TableauDeRemplissage::TableauDeRemplissage(int idEvenement, QObject *parent)
    : Etat(tr("Tableau de remplissage"), idEvenement, parent)
{
    QSqlQuery query;
    if (query.prepare("select *"
                      " from tableau_de_remplissage"
                      " where id_evenement=:id_evenement")) {
        query.bindValue(":id_evenement", idEvenement);
        if (query.exec()) {
            // FIXME : ce rapport devrait être une feuille de calcul

            QString symboleAcceptee = "●";
            QString symboleProposee = "◍";
            QString symbolePossible = "○";
            QString symboleManquante = "◌";

            QTextCursor c(this);

            QTextBlockFormat formatDuTitreDeLaLegende;
            formatDuTitreDeLaLegende.setBottomMargin(10);

            QTextCharFormat formatDesCaracteresDuTitreDeLaLegende;
            formatDesCaracteresDuTitreDeLaLegende.setUnderlineStyle(QTextCharFormat::SingleUnderline);

            QTextBlockFormat formatDesBlocsDeLaLegende;

            QTextCharFormat formatDesCaracteresDeLaLegende;

            QTextListFormat formatDeLaListeDeLaLegende;

            QTextBlockFormat formatDuBlocJour;
            formatDuBlocJour.setPageBreakPolicy(QTextFormat::PageBreak_AlwaysBefore);
            formatDuBlocJour.setAlignment(Qt::AlignCenter);
            formatDuBlocJour.setBottomMargin(20);

            QTextCharFormat formatDesCaracteresDuJour;
            formatDesCaracteresDuJour.setFontCapitalization(QFont::Capitalize);
            formatDesCaracteresDuJour.setFontPointSize(14);
            formatDesCaracteresDuJour.setFontWeight(QFont::Bold);

            QTextBlockFormat formatDuBlocTour;
            formatDuBlocTour.setTopMargin(20);

            QTextCharFormat formatDesCaracteresDuTour;
            formatDesCaracteresDuTour.setFontWeight(QFont::Bold);

            QTextBlockFormat formatDuBlocDesResponsables;

            QTextCharFormat formatDesCaracteresDesResponsables;

            QTextBlockFormat formatDuBlocDuRemplissage;

            QTextCharFormat formatDesCaracteresDuRemplissage;

            if (query.first()) {
                c.movePosition(QTextCursor::End);
                c.insertBlock(formatDuTitreDeLaLegende, formatDesCaracteresDuTitreDeLaLegende);
                c.insertText(tr("Légende"));
                c.insertBlock(formatDesBlocsDeLaLegende, formatDesCaracteresDeLaLegende);
                c.insertList(formatDeLaListeDeLaLegende);
                c.insertText(tr("%1 affectation acceptée ou validée").arg(symboleAcceptee));
                c.insertText("\n");
                c.insertText(tr("%1 affectation proposée, en attente d'acceptation").arg(symboleProposee));
                c.insertText("\n");
                c.insertText(tr("%1 affectation possible, à proposer ou valider").arg(symbolePossible));
                c.insertText("\n");
                c.insertText(tr("%1 affectation manquante, reste à créer").arg(symboleManquante));
                QSqlRecord r = query.record();
                do {
                    QDate jour = r.value("debut_tour").toDate();
                    c.insertBlock(formatDuBlocJour, formatDesCaracteresDuJour);
                    c.insertText(QLocale().toString(jour));
                    do {
                        int
                                min = r.value("min").toInt(),
                                max = r.value("max").toInt(),
                                possibles = r.value("nombre_affectations_possibles").toInt(),
                                proposees = r.value("nombre_affectations_proposees").toInt(),
                                acceptees = r.value("nombre_affectations_validees_ou_acceptees").toInt(),
                                trouvees = acceptees + proposees + possibles,
                                manquantes = trouvees < min ? min - trouvees : 0,
                                enTrop = max < trouvees ? trouvees - max : 0;
                        QString responsables = r.value("liste_responsables").toString();
                        c.insertBlock(formatDuBlocTour, formatDesCaracteresDuTour);
                        c.insertText(tr("De %1 à %2 / %3")
                                     .arg(r.value("debut_tour").toTime().toString("H:mm"))
                                     .arg(r.value("fin_tour").toTime().toString("H:mm"))
                                     .arg(r.value("nom_poste").toString())
                                     );
                        if (!responsables.isEmpty()) {
                            c.insertBlock(formatDuBlocDesResponsables, formatDesCaracteresDesResponsables);
                            c.insertText(tr("Responsable(s) : %1").arg(responsables));
                        }
                        c.insertBlock(formatDuBlocDuRemplissage, formatDesCaracteresDuRemplissage);
                        c.insertText(symboleAcceptee.repeated(acceptees));
                        c.insertText(symboleProposee.repeated(proposees));
                        c.insertText(symbolePossible.repeated(possibles));
                        c.insertText(symboleManquante.repeated(manquantes));
                        if (enTrop) c.insertText(tr(" (%n affectation(s) en trop)", "", enTrop));
                        query.next();
                        r = query.record();
                    } while (query.isValid()
                             && r.value("debut_tour").toDate() == jour);
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
