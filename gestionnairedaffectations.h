#ifndef GESTIONNAIREDAFFECTATIONS_H
#define GESTIONNAIREDAFFECTATIONS_H

#include "sqlquerymodel.h"
#include <QGuiApplication>
#include <QDateTime>
#include <QSortFilterProxyModel>
#include "settings.h"
#include "poste.h"
#include <map>
#include <plan.h>


class GestionnaireDAffectations : public QGuiApplication
{
    Q_OBJECT
    Q_PROPERTY(int idEvenement READ idEvenement WRITE setIdEvenement)
    Q_PROPERTY(QDateTime heure MEMBER m_heure NOTIFY heureChanged)
    Q_PROPERTY(QDateTime heureMin MEMBER m_heureMin NOTIFY heureMinChanged)
    Q_PROPERTY(QDateTime heureMax MEMBER m_heureMax NOTIFY heureMaxChanged)
    Q_PROPERTY(Settings* settings MEMBER m_settings NOTIFY settingsChanged)
    Q_PROPERTY(SqlQueryModel* liste_des_evenements MEMBER m_liste_des_evenements NOTIFY liste_des_evenementsChanged)
    Q_PROPERTY(QSortFilterProxyModel* benevoles_disponibles MEMBER m_benevoles_disponibles NOTIFY benevoles_disponiblesChanged)
    Q_PROPERTY(SqlQueryModel* postes MEMBER m_postes NOTIFY postesChanged)
    Q_PROPERTY(SqlQueryModel* fiche_benevole MEMBER m_fiche_benevole NOTIFY fiche_benevoleChanged)
    Q_PROPERTY(SqlQueryModel* fiche_poste MEMBER m_fiche_poste NOTIFY fiche_posteChanged)
    Q_PROPERTY(SqlQueryModel* fiche_poste_tour MEMBER m_fiche_poste_tour NOTIFY fiche_posteTourChanged)
    Q_PROPERTY(SqlQueryModel* tour_benevoles MEMBER m_tour_benevole NOTIFY tourChanged)
    Q_PROPERTY(SqlQueryModel* affectations MEMBER m_affectations NOTIFY affectationsChanged)
    Q_PROPERTY(QSortFilterProxyModel* planCourant MEMBER m_plan NOTIFY planChanged)
    Q_PROPERTY(SqlQueryModel* planComplet MEMBER m_planComplet NOTIFY planCompletChanged)
    Q_PROPERTY(QSortFilterProxyModel* poste_et_tour MEMBER m_poste_et_tour NOTIFY posteEtTourChanged)



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
    Q_INVOKABLE void setIdPosteTour(int);
    Q_INVOKABLE void setIdTour(int);
    Q_INVOKABLE void setIdDisponibilite(int);
    Q_INVOKABLE void setIdAffectation(int);
    Q_INVOKABLE void enregistrerNouvelEvenement(QString, QDateTime, QDateTime, QString, int id_evenement_precedent);
    Q_INVOKABLE void selectionnerMarqueur();

    Q_INVOKABLE void insererPoste(QString,QString,float,float);
    Q_INVOKABLE void supprimerPoste(int);
    Q_INVOKABLE void rafraichirStatistiquePoste(int n, QString nom);
    Q_INVOKABLE void modifierPositionPoste(float x,float y);
    Q_INVOKABLE void modifierTourDebut(QDateTime debut, int id);
    Q_INVOKABLE void modifierTourFin(QDateTime fin, int id);
    Q_INVOKABLE void desaffecterBenevole();
    Q_INVOKABLE void affecterBenevole();
    //   Q_INVOKABLE void faireInscription(int); : TODO : Permettre l'inscription d'un  bénévole


    Q_INVOKABLE float getRatioX();
    Q_INVOKABLE float getRatioY();
    Q_INVOKABLE void setRatioX(float x);
    Q_INVOKABLE void setRatioY(float y);
    Q_INVOKABLE int getIdPoste();
    Q_INVOKABLE int getNombreDeTours();
    Q_INVOKABLE int getNombreDAffectations();
    Q_INVOKABLE QString getNomPoste();



    Q_INVOKABLE void genererFichesDePostes();
    Q_INVOKABLE void genererCarteBenevoles();
    Q_INVOKABLE void genererTableauRemplissage();
    Q_INVOKABLE void genererFichesProblemes();
    Q_INVOKABLE void genererExportGeneral();

    int age(QDate dateDeNaissance,QDate dateRepere);
    void faireUnRetourALaLigne(QProcess* unPandoc);
    void afficherEntete(QProcess* unPandoc, QSqlQuery uneQuery);
    bool terminerGenerationEtat(QProcess* unPandoc, QTemporaryFile *unFichier);
 //   Q_INVOKABLE void faireInscription(int); : TODO : Permettre l'inscription d'un  bénévole

signals:
    void heureChanged();
    void heureMinChanged();
    void heureMaxChanged();
    void settingsChanged();
    void liste_des_evenementsChanged();
    void benevoles_disponiblesChanged();
    void postesChanged();
    void fiche_benevoleChanged();
    void fiche_posteChanged();
    void planChanged();
    void planCompletChanged();
    void tourChanged();
    void fiche_posteTourChanged();
    void affectationsChanged();
    void posteEtTourChanged();

public slots:
    void mettreAJourModelPlan();

private:
    QSqlDatabase db;
    SqlQueryModel *m_liste_des_evenements;
    SqlQueryModel *m_postes;
    QSortFilterProxyModel *m_benevoles_disponibles;
    SqlQueryModel *m_benevoles_disponibles_sql;
    SqlQueryModel *m_fiche_benevole;
    SqlQueryModel *m_fiche_poste;
    SqlQueryModel *m_fiche_poste_tour;
    SqlQueryModel *m_tour_benevole;
    SqlQueryModel *m_affectations;
    SqlQueryModel *m_postes_tours_affectations;
    int m_id_disponibilite;
    int m_id_poste;
    int m_id_tour;
    int m_id_affectation;
    QDateTime m_heureMin, m_heureMax, m_heure;
    Settings *m_settings;
    std::map<int,Poste> listeDePoste;
    QSortFilterProxyModel *m_plan;
    SqlQueryModel *m_planComplet;
    SqlQueryModel *m_poste_et_tour_sql;
    QSortFilterProxyModel *m_poste_et_tour;

    // Variables Temporaires necessaires pour transmettre des informations d'une fenetre QML à une autre
    float ratioX = -1; // Stocke temporairement la position x cliquée sur la carte ( entre 0 et 1 , -1 si rien n'a été cliqué )
    float ratioY = -1; // Stocke temporairement la position y cliquée sur la carte ( entre 0 et 1 , -1 si rien n'a été cliqué )
    QString nomPoste; // Le nom du poste courant
    int nombreDeTours; // Le nombre de tours associés au poste
    int nombreDAffectations;


};

#endif // GESTIONNAIREDAFFECTATIONS_H
