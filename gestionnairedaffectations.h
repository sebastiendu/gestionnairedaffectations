#ifndef GESTIONNAIREDAFFECTATIONS_H
#define GESTIONNAIREDAFFECTATIONS_H

#include "sqlquerymodel.h"
#include <QGuiApplication>
#include <QDateTime>
#include <QSortFilterProxyModel>
#include "settings.h"
#include <map>
#include <QProcess>
#include <QTemporaryFile>
#include <QUrl>
#include "toursparpostemodel.h"
#include "modeledelalistedespostesdelevenementparheure.h"
#include "sqltablemodel.h"

class GestionnaireDAffectations : public QGuiApplication
{
    Q_OBJECT
    Q_PROPERTY(Settings* settings MEMBER m_settings NOTIFY settingsChanged)
    Q_PROPERTY(int id_evenement READ getIdEvenement WRITE setIdEvenement NOTIFY idEvenementChanged)
    Q_PROPERTY(int id_personne MEMBER m_id_personne NOTIFY idPersonneChanged)
    Q_PROPERTY(int id_disponibilite MEMBER m_id_disponibilite NOTIFY idDisponibiliteChanged)
    Q_PROPERTY(int id_poste MEMBER m_id_poste NOTIFY idPosteChanged)
    Q_PROPERTY(int id_tour MEMBER m_id_tour NOTIFY idTourChanged)
    Q_PROPERTY(int id_affectation MEMBER m_id_affectation NOTIFY idAffectationChanged)
    Q_PROPERTY(QDateTime heure MEMBER m_heure NOTIFY heureChanged)
    Q_PROPERTY(SqlQueryModel* liste_des_evenements MEMBER m_liste_des_evenements NOTIFY liste_des_evenementsChanged)
    Q_PROPERTY(SqlQueryModel* liste_des_affectations_de_la_disponibilite MEMBER m_liste_des_affectations_de_la_disponibilite NOTIFY liste_des_affectations_de_la_disponibiliteChanged)
    Q_PROPERTY(QSortFilterProxyModel* proxy_de_la_liste_des_disponibilites_de_l_evenement MEMBER m_proxy_de_la_liste_des_disponibilites_de_l_evenement NOTIFY proxy_de_la_liste_des_disponibilites_de_l_evenementChanged)
    Q_PROPERTY(SqlQueryModel* liste_des_disponibilites_de_l_evenement MEMBER m_liste_des_disponibilites_de_l_evenement NOTIFY liste_des_disponibilites_de_l_evenementChanged)
    Q_PROPERTY(SqlQueryModel* liste_des_postes_de_l_evenement MEMBER m_liste_des_postes_de_l_evenement NOTIFY liste_des_postes_de_l_evenementChanged)
    Q_PROPERTY(SqlQueryModel* fiche_de_la_disponibilite MEMBER m_fiche_de_la_disponibilite NOTIFY ficheDeLaDisponibiliteChanged)
    Q_PROPERTY(SqlQueryModel* fiche_personne MEMBER m_fiche_personne)
    Q_PROPERTY(SqlQueryModel* fiche_poste_tour MEMBER m_liste_des_tours_du_poste NOTIFY fiche_posteTourChanged)
    Q_PROPERTY(SqlQueryModel* fiche_de_l_affectation_de_la_disponibilite_au_tour MEMBER m_fiche_de_l_affectation_de_la_disponibilite_au_tour NOTIFY fiche_de_l_affectation_de_la_disponibilite_au_tourChanged)
    Q_PROPERTY(SqlQueryModel* fiche_de_l_affectation MEMBER m_fiche_de_l_affectation NOTIFY fiche_de_l_affectationChanged)
    Q_PROPERTY(SqlQueryModel* fiche_du_tour MEMBER m_fiche_du_tour NOTIFY ficheDuTourChanged)
    Q_PROPERTY(SqlTableModel* fiche_du_poste MEMBER m_fiche_du_poste NOTIFY fiche_du_posteChanged)
    Q_PROPERTY(SqlQueryModel* affectations_du_tour MEMBER m_affectations_du_tour NOTIFY affectationsDuTourChanged)
    Q_PROPERTY(SqlQueryModel* lotsDejaCrees MEMBER m_lotsDejaCrees NOTIFY lotDejaCreesChanged)
    Q_PROPERTY(ModeleDeLaListeDesPostesDeLEvenementParHeure *proxy_de_la_liste_des_postes_de_l_evenement_par_heure MEMBER m_proxy_de_la_liste_des_postes_de_l_evenement_par_heure NOTIFY proxy_de_la_liste_des_postes_de_l_evenement_par_heureChanged)
    Q_PROPERTY(QSortFilterProxyModel* proxy_de_la_liste_des_tours_de_l_evenement MEMBER m_proxy_de_la_liste_des_tours_de_l_evenement NOTIFY proxy_de_la_liste_des_tours_de_l_evenementChanged)

    Q_PROPERTY(SqlQueryModel* responsables MEMBER m_responsables NOTIFY responsablesChanged)

    Q_PROPERTY(SqlQueryModel* candidatures_en_attente MEMBER m_candidatures_en_attente NOTIFY candidatureEnAttenteChanged)
    Q_PROPERTY(SqlQueryModel* personnes_doublons MEMBER m_personnes_doublons)

    Q_PROPERTY(ToursParPosteModel *toursParPosteModel MEMBER m_toursParPosteModel NOTIFY toursParPosteModelChanged)

    Q_PROPERTY(SqlQueryModel* sequence_emploi_du_temps MEMBER m_sequence_emploi_du_temps NOTIFY sequenceEmploiDuTempsChanged)

    Q_PROPERTY(SqlQueryModel* remplissage_par_heure MEMBER m_remplissage_par_heure NOTIFY remplissage_par_heureChanged)

public:
    GestionnaireDAffectations(int & argc, char ** argv);
    ~GestionnaireDAffectations();
    Q_INVOKABLE bool baseEstOuverte();
    Q_INVOKABLE bool ouvrirLaBase(QString password="");
    Q_INVOKABLE QString messageDErreurDeLaBase();
    Q_INVOKABLE int getEvenementModelIndex();

    Q_INVOKABLE void setIdEvenement(int); // TODO : remplacer ces accesseurs par des QPROPERTIES READ/WRITE
    Q_INVOKABLE void setIdPoste(int);
    Q_INVOKABLE void setIdPosteTour(int id_poste); // Permet de selectionner le poste les tours en ayant l'id du poste
    Q_INVOKABLE void setIdTourPoste(int id_tour); // Permet de selectionner le tour et le poste en connaissant l'id du tour
    Q_INVOKABLE void setIdAffectation(int);


    Q_INVOKABLE void setIdTour(int);
    Q_INVOKABLE void setIdDisponibilite(int);

    Q_INVOKABLE void enregistrerNouvelEvenement(QString, QDateTime, QDateTime, int heureDebut, int heureFin, QString, int id_evenement_precedent);
    Q_INVOKABLE void supprimerEvenement();
    Q_INVOKABLE void enregistrerPlanEvenement(QUrl url);
    Q_INVOKABLE void setDebutEvenement(QDateTime date, int heure, int minutes);
    Q_INVOKABLE void setFinEvenement(QDateTime date, int heure, int minutes);
    Q_INVOKABLE void updateEvenement(QString nom, QString lieu, bool archive);

    Q_INVOKABLE bool insererPoste(QString nom, QString description, bool autonome, float posx, float posy);

    Q_INVOKABLE void modifierTourDebut(QDateTime date, int heure, int minutes, int id);
    Q_INVOKABLE void modifierTourFin(QDateTime date, int heure, int minutes, int id);
    Q_INVOKABLE void modifierTourMinMax(QString type, int nombre, int id);
    Q_INVOKABLE void insererTour(QDateTime dateFinPrecedente, int min,int max);
    Q_INVOKABLE void supprimerTour(int id);
    Q_INVOKABLE void annulerAffectation(QString commentaire);
    Q_INVOKABLE void creerAffectation(QString commentaire);
    Q_INVOKABLE void inscrireBenevole(QString nomBenevole, QString prenomBenevole, QString adresseBenevole,
                                      QString codePostalBenevole, QString communeBenevole, QString courrielBenevole,
                                      QString numPortableBenevole,QString numDomicileBenevole,QString professionBenevole,
                                      QString datenaissanceBenevole, QString languesBenevole,QString competencesBenevole,
                                      QString commentaireBenevole, QString joursEtHeures, QString listeAmis, QString typePoste,
                                      QString commentaireDisponibilite);
    Q_INVOKABLE void ajouterResponsable(int id);
    Q_INVOKABLE void rejeterResponsable(int id);

    Q_INVOKABLE QString creerLotDAffectations(bool possibles, bool proposees);
    Q_INVOKABLE QString creerLotDeSolicitation(QString);

    Q_INVOKABLE void validerCandidature();
    Q_INVOKABLE void rejeterCandidature();
    Q_INVOKABLE void setIdDoublons(int id);
    Q_INVOKABLE void setIdPersonne(int id);

    Q_INVOKABLE void genererFichesDePostes();
    Q_INVOKABLE void genererCarteBenevoles();
    Q_INVOKABLE void genererTableauRemplissage();
    Q_INVOKABLE void genererFichesProblemes();
    Q_INVOKABLE void genererExportGeneral();



    int age(QDate dateDeNaissance,QDate dateRepere);
    void faireUnRetourALaLigne(QProcess* unPandoc);
    void afficherEntete(QProcess* unPandoc, QSqlQuery uneQuery);
    bool terminerGenerationEtat(QProcess* unPandoc, QTemporaryFile *unFichier);


    int getIdEvenement();
signals:
    void warning(const QString &msg, const QString &info, const QString &detail);
    void critical(const QString &msg, const QString &info, const QString &detail);
    void fatal(const QString &msg, const QString &info, const QString &detail);
    void info(const QString &msg, const QString &info, const QString &detail);
    void heureChanged();
    void settingsChanged();
    void liste_des_evenementsChanged();
    void proxy_de_la_liste_des_disponibilites_de_l_evenementChanged();
    void liste_des_postes_de_l_evenementChanged();
    void ficheDeLaDisponibiliteChanged();
    void proxy_de_la_liste_des_postes_de_l_evenement_par_heureChanged();
    void fiche_de_l_affectationChanged();
    void fiche_de_l_affectation_de_la_disponibilite_au_tourChanged();
    void affectationsDuTourChanged();
    void ficheDuTourChanged();
    void fiche_du_posteChanged();
    void fiche_posteTourChanged();
    void proxy_de_la_liste_des_tours_de_l_evenementChanged();
    void tableauTourChanged(); // FIXME: remplacer par fiche_posteTourChanged
    void planMisAJour();
    void lotDejaCreesChanged();
    void toursParPosteModelChanged();
    void sequenceEmploiDuTempsChanged();
    void candidatureEnAttenteChanged();
    void responsablesChanged();
    void fermerFenetreProprietesEvenement();
    void inscriptionOk();
    void candidatureValidee();
    void candidatureRejetee();
    void tableauResponsablesChanged();
    void liste_des_disponibilites_de_l_evenementChanged();
    void liste_des_affectations_de_la_disponibiliteChanged();
    void idEvenementChanged(int);
    void idPersonneChanged(int);
    void idDisponibiliteChanged(int);
    void idPosteChanged(int);
    void idTourChanged(int);
    void idAffectationChanged(int);
    void remplissage_par_heureChanged();

private slots:
    void mettreAJourLesModelesQuiDependentDeIdEvenement(int id_evenement);
    void mettreAJourLesModelesQuiDependentDeIdPersonne(int id_personne);
    void mettreAJourLesModelesQuiDependentDeIdDisponibilite(int id_disponibilite);
    void mettreAJourLesModelesQuiDependentDeIdPoste(int id_poste);
    void mettreAJourLesModelesQuiDependentDeIdTour(int id_tour);
    void mettreAJourLesModelesQuiDependentDeIdAffectation(int id_affectation);
    void mettreAJourModelPlan();

private:
    Settings *m_settings;
    QSqlDatabase db;

    int
    m_id_evenement,
    m_id_personne,
    m_id_disponibilite,
    m_id_poste,
    m_id_tour,
    m_id_affectation;
    // TODO: id_doublon, id_responsable, id_lot

    QDateTime m_heure;

    SqlQueryModel
    *m_liste_des_evenements,
    *m_candidatures_en_attente,
    *m_personnes_doublons,
    *m_liste_des_disponibilites_de_l_evenement,
    *m_liste_des_postes_de_l_evenement,
    *m_responsables,
    *m_liste_des_tours_de_l_evenement,
    *m_liste_des_tours_du_poste,
    *m_liste_des_affectations_de_la_disponibilite,
    *m_affectations_du_tour,
    *m_lotsDejaCrees,

    *m_fiche_personne,
    *m_fiche_de_la_disponibilite,
    *m_fiche_du_tour,
    *m_fiche_de_l_affectation,
    *m_fiche_de_l_affectation_de_la_disponibilite_au_tour,

    *m_remplissage_par_heure,
    *m_sequence_emploi_du_temps;

    SqlTableModel *m_fiche_du_poste;

    QSortFilterProxyModel
    *m_proxy_de_la_liste_des_disponibilites_de_l_evenement,
    *m_proxy_de_la_liste_des_tours_de_l_evenement;

    ModeleDeLaListeDesPostesDeLEvenementParHeure *m_proxy_de_la_liste_des_postes_de_l_evenement_par_heure;

    ToursParPosteModel *m_toursParPosteModel;

    QList<SqlQueryModel *>
    m_liste_des_modeles_qui_dependent_de_id_evenement,
    m_liste_des_modeles_qui_dependent_de_id_personne,
    m_liste_des_modeles_qui_dependent_de_id_disponibilite,
    m_liste_des_modeles_qui_dependent_de_id_poste,
    m_liste_des_modeles_qui_dependent_de_id_tour,
    m_liste_des_modeles_qui_dependent_de_id_affectation;

    static void gestionDesMessages(QtMsgType type, const QMessageLogContext &context, const QString &msg);
};

#endif // GESTIONNAIREDAFFECTATIONS_H
