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

class GestionnaireDAffectations : public QGuiApplication
{
    Q_OBJECT
    Q_PROPERTY(int idEvenement READ idEvenement WRITE setIdEvenement NOTIFY idEvenementChanged)
    Q_PROPERTY(QDateTime heure MEMBER m_heure NOTIFY heureChanged)
    Q_PROPERTY(QDateTime heureMin MEMBER m_heureMin NOTIFY heureMinChanged)
    Q_PROPERTY(QDateTime heureMax MEMBER m_heureMax NOTIFY heureMaxChanged)
    Q_PROPERTY(Settings* settings MEMBER m_settings NOTIFY settingsChanged)
    Q_PROPERTY(int id_poste MEMBER m_id_poste NOTIFY idPosteChanged)
    Q_PROPERTY(SqlQueryModel* liste_des_evenements MEMBER m_liste_des_evenements NOTIFY liste_des_evenementsChanged)
    Q_PROPERTY(QSortFilterProxyModel* benevoles_disponibles MEMBER m_benevoles_disponibles NOTIFY benevoles_disponiblesChanged)
    Q_PROPERTY(SqlQueryModel* benevoles_disponibles_sql MEMBER m_benevoles_disponibles_sql NOTIFY benevoles_disponibles_sqlChanged)
    Q_PROPERTY(SqlQueryModel* postes MEMBER m_postes NOTIFY postesChanged)
    Q_PROPERTY(SqlQueryModel* fiche_de_la_disponibilite MEMBER m_fiche_de_la_disponibilite NOTIFY ficheDeLaDisponibiliteChanged)
    Q_PROPERTY(SqlQueryModel* fiche_personne MEMBER m_fiche_personne)
    Q_PROPERTY(SqlQueryModel* fiche_poste MEMBER m_fiche_poste NOTIFY fiche_posteChanged)
    Q_PROPERTY(SqlQueryModel* fiche_poste_tour MEMBER m_fiche_poste_tour NOTIFY fiche_posteTourChanged)
    Q_PROPERTY(SqlQueryModel* affectation MEMBER m_affectation NOTIFY affectationChanged)
    Q_PROPERTY(SqlQueryModel* tour MEMBER m_tour NOTIFY tourChanged)
    Q_PROPERTY(SqlQueryModel* affectations_du_tour MEMBER m_affectations_du_tour NOTIFY affectationsDuTourChanged)
    Q_PROPERTY(SqlQueryModel* affectations_acceptees_validees_ou_proposees_du_tour MEMBER m_affectations_acceptees_validees_ou_proposees_du_tour NOTIFY affectationsAccepteesValideesOuProposeesDuTourChanged)
    Q_PROPERTY(SqlQueryModel* lotsDejaCrees MEMBER m_lotsDejaCrees NOTIFY lotDejaCreesChanged)
    Q_PROPERTY(QSortFilterProxyModel* planCourant MEMBER m_plan NOTIFY planChanged)
    Q_PROPERTY(SqlQueryModel* planComplet MEMBER m_planComplet NOTIFY planCompletChanged)
    Q_PROPERTY(QSortFilterProxyModel* poste_et_tour MEMBER m_poste_et_tour NOTIFY posteEtTourChanged)
    Q_PROPERTY(SqlQueryModel* horaires MEMBER m_horaires NOTIFY horaireChanged)
    Q_PROPERTY(QSortFilterProxyModel* etat_tour_heure MEMBER m_etat_tour_heure  NOTIFY etatTourHeureChanged)
    Q_PROPERTY(QDateTime heureCourante MEMBER m_heure_courante NOTIFY heureCouranteChanged)

    Q_PROPERTY(SqlQueryModel* responsables MEMBER m_responsables NOTIFY responsablesChanged)

    Q_PROPERTY(SqlQueryModel* candidatures_en_attente MEMBER m_candidatures_en_attente NOTIFY candidatureEnAttenteChanged)
    Q_PROPERTY(SqlQueryModel* personnes_doublons MEMBER m_personnes_doublons)

    Q_PROPERTY(ToursParPosteModel *toursParPosteModel MEMBER m_toursParPosteModel NOTIFY toursParPosteModelChanged)

    Q_PROPERTY(SqlQueryModel* sequence_emploi_du_temps MEMBER m_sequence_emploi_du_temps NOTIFY sequenceEmploiDuTempsChanged)

public:
    GestionnaireDAffectations(int & argc, char ** argv);
    int idEvenement();
    void setIdEvenement(int);
    ~GestionnaireDAffectations();
    Q_INVOKABLE bool baseEstOuverte();
    Q_INVOKABLE bool ouvrirLaBase(QString password="");
    Q_INVOKABLE QString messageDErreurDeLaBase();
    Q_INVOKABLE void setIdEvenementFromModelIndex(int);
    Q_INVOKABLE int getEvenementModelIndex();

    Q_INVOKABLE void setIdPoste(int);
    Q_INVOKABLE void setIdPosteTour(int); // Permet de selectionner le poste les tours en ayant l'id du poste
    Q_INVOKABLE void setIdTourPoste(int); // Permet de selectionner le tour et le poste en connaissant l'id du tour
    Q_INVOKABLE void setIdAffectation(int);


    Q_INVOKABLE void setIdTour(int);
    Q_INVOKABLE void setIdDisponibilite(int);
    Q_INVOKABLE void setResponsables();

    Q_INVOKABLE void enregistrerNouvelEvenement(QString, QDateTime, QDateTime, int heureDebut, int heureFin, QString, int id_evenement_precedent);
    Q_INVOKABLE void supprimerEvenement();
    Q_INVOKABLE void enregistrerPlanEvenement(QUrl url);
    Q_INVOKABLE void setDebutEvenement(QDateTime date, int heure, int minutes);
    Q_INVOKABLE void setFinEvenement(QDateTime date, int heure, int minutes);
    Q_INVOKABLE void updateEvenement(QString nom, QString lieu, bool archive);


    Q_INVOKABLE void insererPoste(QString,QString,bool, float,float);
    Q_INVOKABLE void supprimerPoste(int);
    Q_INVOKABLE void rafraichirStatistiquePoste(int n, QString nom);
    Q_INVOKABLE void modifierPositionPoste(float x,float y);
    Q_INVOKABLE void modifierNomPoste(QString nom);
    Q_INVOKABLE void modifierDescriptionPoste(QString nom);
    Q_INVOKABLE void rechargerPlan();


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

    Q_INVOKABLE float getRatioX();
    Q_INVOKABLE float getRatioY();
    Q_INVOKABLE void setRatioX(float x);
    Q_INVOKABLE void setRatioY(float y);
    Q_INVOKABLE int getIdPoste();
    Q_INVOKABLE int getNombreDeTours();
    Q_INVOKABLE int getNombreDAffectations();
    Q_INVOKABLE QString getNomPoste();


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


signals:
    void warning(const QString &msg, const QString &info, const QString &detail);
    void critical(const QString &msg, const QString &info, const QString &detail);
    void fatal(const QString &msg, const QString &info, const QString &detail);
    void info(const QString &msg, const QString &info, const QString &detail);
    void heureChanged();
    void heureMinChanged();
    void heureMaxChanged();
    void settingsChanged();
    void liste_des_evenementsChanged();
    void benevoles_disponiblesChanged();
    void postesChanged();
    void ficheDeLaDisponibiliteChanged();
    void fiche_posteChanged();
    void planChanged();
    void planCompletChanged();
    void affectationChanged();
    void affectationsDuTourChanged();
    void tourChanged();
    void fiche_posteTourChanged();
    void affectationsAccepteesValideesOuProposeesDuTourChanged();
    void posteEtTourChanged();
    void horaireChanged();
    void tableauTourChanged(); // Signal emis lorsque le tableau des tours de l'onglet Poste&Tours es t
    void erreurBD(QString erreur);
    void idEvenementChanged();
    void planMisAJour();
    void heureCouranteChanged();
    void etatTourHeureChanged();
    void lotDejaCreesChanged();
    void toursParPosteModelChanged();
    void sequenceEmploiDuTempsChanged();
    void candidatureEnAttenteChanged();
    void ficheEvenementChanged();
    void responsablesChanged();
    void fermerFenetreProprietesEvenement();
    void inscriptionOk();
    void candidatureValidee();
    void candidatureRejetee();
    void tableauResponsablesChanged();
    void benevoles_disponibles_sqlChanged();
    void idPosteChanged();

public slots:
    void mettreAJourModelPlan();
    void setHeureEtatTour();

private:
    QSqlDatabase db;
    SqlQueryModel *m_liste_des_evenements;
    SqlQueryModel *m_postes;
    QSortFilterProxyModel *m_benevoles_disponibles;
    SqlQueryModel *m_benevoles_disponibles_sql;
    SqlQueryModel *m_fiche_de_la_disponibilite;
    SqlQueryModel *m_fiche_personne; // Est associé à une personne
    SqlQueryModel *m_fiche_poste;
    SqlQueryModel *m_fiche_poste_tour;
    SqlQueryModel *m_affectation;
    SqlQueryModel *m_tour;
    SqlQueryModel *m_affectations_du_tour;
    SqlQueryModel *m_affectations_acceptees_validees_ou_proposees_du_tour;
    SqlQueryModel *m_postes_tours_affectations;
    SqlQueryModel *m_lotsDejaCrees;
    int m_id_disponibilite;
    int m_id_poste;
    int m_id_tour;
    int m_id_affectation;
    QDateTime m_heureMin, m_heureMax, m_heure, m_heure_courante;
    Settings *m_settings;
    QSortFilterProxyModel *m_plan;
    SqlQueryModel *m_planComplet;
    SqlQueryModel *m_poste_et_tour_sql;
    SqlQueryModel *m_horaires;
    QSortFilterProxyModel *m_poste_et_tour;
    QSortFilterProxyModel *m_etat_tour_heure;
    SqlQueryModel *m_etat_tour_heure_sql;
    SqlQueryModel *m_candidatures_en_attente;
    SqlQueryModel *m_personnes_doublons;

    SqlQueryModel *m_responsables;

    ToursParPosteModel *m_toursParPosteModel;
    SqlQueryModel *m_sequence_emploi_du_temps;


    // Variables Temporaires necessaires pour transmettre des informations d'une fenetre QML à une autre
    float ratioX; // Stocke temporairement la position x cliquée sur la carte ( entre 0 et 1 , -1 si rien n'a été cliqué )
    float ratioY; // Stocke temporairement la position y cliquée sur la carte ( entre 0 et 1 , -1 si rien n'a été cliqué )
    QString nomPoste; // Le nom du poste courant
    int nombreDeTours; // Le nombre de tours associés au poste
    int nombreDAffectations;

    static void gestionDesMessages(QtMsgType type, const QMessageLogContext &context, const QString &msg);
};

#endif // GESTIONNAIREDAFFECTATIONS_H
