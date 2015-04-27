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
    Q_INVOKABLE void setIdDisponibilite(int);
    Q_INVOKABLE void enregistrerNouvelEvenement(QString, QDateTime, QDateTime, QString, int id_evenement_precedent);
    Q_INVOKABLE void selectionnerMarqueur();
    Q_INVOKABLE void ajouterUnPoste(Poste);
    Q_INVOKABLE void supprimerUnPoste(int);
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


public slots:
 //   void mettreAJourModelPlan(); : TODO : Mettre à jour le plan

private:
    QSqlDatabase db;
    SqlQueryModel *m_liste_des_evenements;
    SqlQueryModel *m_postes;
    QSortFilterProxyModel *m_benevoles_disponibles;
    SqlQueryModel *m_benevoles_disponibles_sql;
    SqlQueryModel *m_fiche_benevole;
    SqlQueryModel *m_fiche_poste;
    SqlQueryModel *m_postes_tours_affectations;
    int m_id_disponibilite;
    int m_id_poste;
    QDateTime m_heureMin, m_heureMax, m_heure;
    Settings *m_settings;
    std::map<int,Poste> listeDePoste;
    // Plan monPlan;
};

#endif // GESTIONNAIREDAFFECTATIONS_H
