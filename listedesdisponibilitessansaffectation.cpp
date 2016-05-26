#include "listedesdisponibilitessansaffectation.h"
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlField>
#include <QTextCursor>
#include <QLocale>
#include <QDate>
#include <QDebug>
#include <QSqlError>

ListeDesDisponibilitesSansAffectation::ListeDesDisponibilitesSansAffectation(int idEvenement, QObject *parent)
    : Etat(tr("Liste des personnes disponibles sans affectation"), idEvenement, parent)
{
    QSqlQuery query;
    if (query.prepare("select * from liste_des_disponibilites_sans_affectation where id_evenement = :id_evenement")) {
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

            QTextBlockFormat formatDuBlocDuTitreDuChamp;
            formatDuBlocDuTitreDuChamp.setTopMargin(10);

            QTextCharFormat formatDesCaracteresDuTitreDuChamp;
            formatDesCaracteresDuTitreDuChamp.setFontPointSize(6);

            QTextBlockFormat formatDuBlocDeLaValeurDuChamp;

            QTextCharFormat formatDesCaracteresDeLaValeurDuChamp;
            formatDesCaracteresDeLaValeurDuChamp.setFontPointSize(12);

            QStringList listeDesChamps[] =
            {
                { "nom", tr("Nom") },
                { "prenom", tr("Prénom") },
                { "adresse", tr("Adresse") },
                { "code_postal", tr("Code Postal") },
                { "ville", tr("Ville") },
                { "portable", tr("Portable") },
                { "domicile", tr("Domicile") },
                { "email", tr("Courriel") },
                { "date_naissance", tr("Date de naissance") }, // TODO : préciser l'âge
                { "profession", tr("Profession") },
                { "competences", tr("Compétences") },
                { "langues", tr("Langues") },
                { "commentaire", tr("Commentaire") },
                { "date_inscription", tr("Date d'inscription") },
                { "liste_amis", tr("Liste des amis") },
                { "jours_et_heures_dispo", tr("Jours et heures disponible") },
                { "type_poste", tr("Type de poste") },
                { "commentaire_disponibilite", tr("Commentaire disponibilité") }
            };

            if (query.first()) {
                c.movePosition(QTextCursor::End);
                do {
                    QSqlRecord r = query.record();
                    c.insertBlock(formatDuBlocDuNomDeLaPersonne, formatDesCaracteresDuNomDeLaPersonne);
                    c.insertText(tr("%1 %2")
                                 .arg(r.value("prenom").toString())
                                 .arg(r.value("nom").toString())
                                 );
                    if (!r.value("ville").toString().isEmpty()) {
                        c.insertText(tr(", %1").arg(r.value("ville").toString()));
                    }
                    for (auto champ: listeDesChamps) {
                        QString valeur =
                                r.field(champ[0]).type() == QVariant::DateTime
                                ? QLocale().toString(r.value(champ[0]).toDateTime())
                            :                                 r.field(champ[0]).type() == QVariant::Date
                            ? QLocale().toString(r.value(champ[0]).toDate())
                            : r.value(champ[0]).toString().trimmed();
                        if (!valeur.isEmpty()) {
                            c.insertBlock(formatDuBlocDuTitreDuChamp, formatDesCaracteresDuTitreDuChamp);
                            c.insertText(champ[1]);
                            c.insertBlock(formatDuBlocDeLaValeurDuChamp, formatDesCaracteresDeLaValeurDuChamp);
                            c.insertText(valeur);
                        }
                    }
                } while (query.next());
            } else {
                qWarning() << tr("Aucune disponibilite sans affectation trouvée");
            }
        } else {
            qCritical() << query.lastError();
        }
    } else {
        qCritical() << query.lastError();
    }

}
