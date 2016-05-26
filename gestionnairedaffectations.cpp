#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QtQml>
#include <QtDebug>
#include <QQuickView>
#include <QXmlSimpleReader>
#include <QSqlField>
#include <QTextDocumentWriter>
#include <QPrinter>
#include "gestionnairedaffectations.h"
#include "cartesdesbenevoles.h"
#include "fichesdespostes.h"
#include "tableauderemplissage.h"
#include "listedesdisponibilitessansaffectation.h"

GestionnaireDAffectations::GestionnaireDAffectations(int & argc, char ** argv):
    QGuiApplication(argc,argv),
    m_id_evenement(0),
    m_id_personne(0),
    m_id_disponibilite(0),
    m_id_poste(0),
    m_id_tour(0),
    m_id_affectation(0)
{
    QCoreApplication::setOrganizationName("Les Développements Durables");
    QCoreApplication::setOrganizationDomain("ldd.fr");
    QCoreApplication::setApplicationName("Laguntzaile");

    //qInstallMessageHandler(gestionDesMessages);

    m_settings = new Settings(this);

    m_liste_des_evenements = new SqlQueryModel(this);
    m_personnes_doublons = new SqlQueryModel(this);
    m_toursParPosteModel = new ToursParPosteModel(this);

    m_fiche_personne = new SqlQueryModel(this);

    m_liste_des_postes_de_l_evenement         = new SqlQueryModel(this);
    m_liste_des_disponibilites_de_l_evenement = new SqlQueryModel(this);
    m_lotsDejaCrees                           = new SqlQueryModel(this);
    m_remplissage_par_heure                   = new SqlQueryModel(this);
    m_liste_des_tours_de_l_evenement          = new SqlQueryModel(this);
    m_candidatures_en_attente                 = new SqlQueryModel(this);
    m_sequence_emploi_du_temps                = new SqlQueryModel(this);

    m_liste_des_affectations_de_la_disponibilite = new SqlQueryModel(this);
    m_fiche_de_l_affectation_de_la_disponibilite_au_tour = new SqlQueryModel(this);

    m_liste_des_tours_du_poste = new SqlQueryModel(this);
    m_responsables             = new SqlQueryModel(this);

    m_affectations_du_tour = new SqlQueryModel(this);

    m_proxy_de_la_liste_des_tours_de_l_evenement = new QSortFilterProxyModel(this);
    m_proxy_de_la_liste_des_disponibilites_de_l_evenement = new QSortFilterProxyModel(this);
    m_proxy_de_la_liste_des_postes_de_l_evenement_par_heure = new ModeleDeLaListeDesPostesDeLEvenementParHeure(this);

    if(!m_settings->contains("database/databaseName")) {
        if(!m_settings->contains("database/hostName")) {
            m_settings->setValue("database/hostName", "localhost");
        }
        if(!m_settings->contains("database/port")) {
            m_settings->setValue("database/port", "5432");
        }
        m_settings->setValue("database/databaseName", "laguntzaile");
        if(!m_settings->contains("database/userName")) {
            QString name = qgetenv("USER");
            if (name.isEmpty()) {
                name = qgetenv("USERNAME");
            }
            m_settings->setValue("database/userName", name);
        }
        if(!m_settings->contains("database/rememberPassword")) {
            m_settings->setValue("database/rememberPassword", false);
        }
    }

    db = QSqlDatabase::addDatabase("QPSQL");
    if (m_settings->value("database/rememberPassword").toBool()) {
        ouvrirLaBase();
    }
    connect(this,SIGNAL(idEvenementChanged(int)),this,SLOT(mettreAJourLesModelesQuiDependentDeIdEvenement(int)));
    connect(this,SIGNAL(idPersonneChanged(int)),this,SLOT(mettreAJourLesModelesQuiDependentDeIdPersonne(int)));
    connect(this,SIGNAL(idDisponibiliteChanged(int)),this,SLOT(mettreAJourLesModelesQuiDependentDeIdDisponibilite(int)));
    connect(this,SIGNAL(idPosteChanged(int)),this,SLOT(mettreAJourLesModelesQuiDependentDeIdPoste(int)));
    connect(this,SIGNAL(idTourChanged(int)),this,SLOT(mettreAJourLesModelesQuiDependentDeIdTour(int)));
    connect(this,SIGNAL(idAffectationChanged(int)),this,SLOT(mettreAJourLesModelesQuiDependentDeIdAffectation(int)));
    connect(this,SIGNAL(heureChanged()),this,SLOT(mettreAJourModelPlan()));

    emit idEvenementChanged(getIdEvenement());

}

GestionnaireDAffectations::~GestionnaireDAffectations()
{
    QSqlDatabase().close();
}

void GestionnaireDAffectations::gestionDesMessages(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
    GestionnaireDAffectations *inst = (GestionnaireDAffectations*) instance();
    QString info = QString("%1:%2").arg(QString(context.file).split('/').last(), QString::number(context.line));
    QString detail = context.function;
    switch (type) {
    case QtDebugMsg:
        break;
    case QtWarningMsg:
        fprintf(stderr, "AVERTISSEMENT : ");
        emit inst->warning(msg, info, detail);
        break;
    case QtCriticalMsg:
        fprintf(stderr, "ERREUR CRITIQUE : ");
        emit inst->critical(msg, info, detail);
        break;
    case QtFatalMsg:
        fprintf(stderr, "ERREUR FATALE : ");
        emit inst->fatal(msg, info, detail);
        break;
    default: // QtInfoMsg
        fprintf(stderr, "INFORMATION : ");
        emit inst->info(msg, info, detail);
    }
    fprintf(stderr, "%s\n\t%s\t%s\n\n", qPrintable(msg), qPrintable(info), qPrintable(detail));
    fflush(stderr);
}

bool GestionnaireDAffectations::initialiserModele(SqlQueryModel *modele, const QString &requete)
{
    bool r = false;
    QSqlQuery query;
    QStringList balises;
    balises << ":id_evenement"
            << ":id_personne"
            << ":id_disponibilite"
            << ":id_poste"
            << ":id_tour"
            << ":id_affectation"
               ;
    if (query.prepare(requete)) {
        modele->setQuery(query);
        for (int i = 0; i < balises.size(); ++i) {
            if (requete.contains(balises[i])) {
                query.bindValue(balises[i], 0);
                m_liste_des_modeles_qui_dependent[balises[i]].append(modele);
            }
        }
        if (query.exec()) {
            r = true;
        } else {
            qCritical() << tr("Echec d'execution de la requête :\n%1\n%2")
                           .arg(requete)
                           .arg(query.lastError().text());
        }
    } else {
        qCritical() << tr("Echec de préparation de la requête :\n%1\n%2")
                       .arg(requete)
                       .arg(query.lastError().text());
    }
    return r;
}

QString GestionnaireDAffectations::messageDErreurDeLaBase() {
    return db.lastError().text();
}

bool GestionnaireDAffectations::baseEstOuverte() {
    return db.isOpen();
}

bool GestionnaireDAffectations::ouvrirLaBase(QString password) {
    db.setHostName(m_settings->value("database/hostName").toString());
    db.setPort(m_settings->value("database/port").toInt());
    db.setDatabaseName(m_settings->value("database/databaseName").toString());
    db.setUserName(m_settings->value("database/userName").toString());
    db.setPassword(
                m_settings->value("database/rememberPassword").toBool()
                ? m_settings->value("database/password").toString()
                : password
                  );

    if(db.open()) {

        m_fiche_de_l_evenement = new SqlTableModel(this, db);
        m_fiche_de_l_evenement->setTable("evenement");

        m_fiche_de_la_personne = new SqlTableModel(this, db);
        m_fiche_de_la_personne->setTable("personne");

        m_fiche_de_la_disponibilite = new SqlTableModel(this, db);
        m_fiche_de_la_disponibilite->setTable("disponibilite");

        m_fiche_du_poste = new SqlTableModel(this, db);
        m_fiche_du_poste->setTable("poste");

        m_fiche_du_tour = new SqlTableModel(this, db);
        m_fiche_du_tour->setTable("tour");

        m_fiche_de_l_affectation = new SqlTableModel(this, db);
        m_fiche_de_l_affectation->setTable("affectation");

        initialiserModele(m_liste_des_evenements,
                          "select * from liste_des_evenements");

        initialiserModele(m_fiche_personne,
                          "select *"
                          " from fiche_benevole"
                          " where id_personne = :id_personne"
                          "  and id_evenement = :id_evenement");

        initialiserModele(m_liste_des_disponibilites_de_l_evenement,
                          "select *"
                          " from benevoles_disponibles"
                          " where id_evenement = :id_evenement");
        m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setSourceModel(m_liste_des_disponibilites_de_l_evenement);
        m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setFilterCaseSensitivity(Qt::CaseInsensitive);
        m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setFilterKeyColumn(-1);

        initialiserModele(m_liste_des_postes_de_l_evenement,
                          "select *"
                          " from poste "
                          "  join nombre_d_affectations_par_poste on id_poste = poste.id"
                          " where id_evenement = :id_evenement");

        initialiserModele(m_liste_des_tours_de_l_evenement,
                          "select *"
                          " from poste_et_tour"
                          " where id_evenement = :id_evenement"
                          " order by nom, debut");
        m_proxy_de_la_liste_des_tours_de_l_evenement->setSourceModel(m_liste_des_tours_de_l_evenement);
        m_proxy_de_la_liste_des_tours_de_l_evenement->setFilterCaseSensitivity(Qt::CaseInsensitive);
        m_proxy_de_la_liste_des_tours_de_l_evenement->setFilterKeyColumn(-1);

        initialiserModele(m_liste_des_tours_du_poste,
                          "select *"
                          " from tours"
                          " where id_poste = :id_poste"
                          " order by debut");

        initialiserModele(m_fiche_de_l_affectation_de_la_disponibilite_au_tour,
                          "select id"
                          " from affectation"
                          " where id_disponibilite=:id_disponibilite"
                          "  and id_tour=:id_tour");

        initialiserModele(m_liste_des_affectations_de_la_disponibilite,
                          "select *"
                          " from tours_benevole"
                          " where id_disponibilite = :id_disponibilite"
                          " order by debut, fin");

        initialiserModele(m_affectations_du_tour,
                          "select *"
                          " from affectations"
                          " where id_tour = :id_tour"
                          " order by"
                          "  statut_affectation = 'possible' desc,"
                          "  statut_affectation = 'proposee' desc,"
                          "  statut_affectation = 'validee'  desc,"
                          "  statut_affectation = 'acceptee' desc,"
                          "  statut_affectation = 'rejetee'  desc,"
                          "  statut_affectation = 'annulee'  desc"
                          );

        initialiserModele(m_remplissage_par_heure,
                          "select * from remplissage_par_heure"
                          " where id_evenement = :id_evenement"
                          " order by heure");

        initialiserModele(m_candidatures_en_attente,
                          "select * from candidatures_en_attente"
                          " where id_evenement = :id_evenement");

        initialiserModele(m_lotsDejaCrees,
                          "select id_evenement, date_de_creation, titre, traite, id, cle"
                          " from lot"
                          " where id_evenement = :id_evenement");

        initialiserModele(m_responsables,
                          "select *"
                          " from responsable"
                          "  join personne on id_personne = personne.id"
                          " where id_poste = :id_poste");

        initialiserModele(m_sequence_emploi_du_temps,
                          "select *"
                          " from libelle_sequence_evenement"
                          " where id_evenement=:id_evenement");

    } else {
        qCritical() << "Impossible d'ouvrir la connexion à la base :" << db.lastError().text();
    }
    return db.isOpen();
}

int GestionnaireDAffectations::getIdEvenement() {
    if (m_id_evenement == 0) {
        QSettings settings;
        m_id_evenement = settings.value("id_evenement", 1).toInt();
    }
    return m_id_evenement;
}

void GestionnaireDAffectations::mettreAJourLesModelesQuiDependent(QString balise, int valeur)
{
    for (int i = 0; i < m_liste_des_modeles_qui_dependent[balise].size(); ++i) {
        m_liste_des_modeles_qui_dependent[balise][i]->query().bindValue(balise, valeur);
        m_liste_des_modeles_qui_dependent[balise][i]->reload();
    }
}

void GestionnaireDAffectations::setIdEvenement(int id) {
    QSettings settings;
    settings.setValue("id_evenement", id);
    m_id_evenement = id;
    emit idEvenementChanged(id);
}

void GestionnaireDAffectations::setIdPersonne(int id) {
    m_id_personne = id;
    emit idPersonneChanged(id);
}

void GestionnaireDAffectations::setIdDisponibilite(int id) {
    m_id_disponibilite = id;
    emit idDisponibiliteChanged(id);
}

void GestionnaireDAffectations::setIdPoste(int id) {
    m_id_poste = id;
    emit idPosteChanged(id);
}

void GestionnaireDAffectations::setIdTour(int id) {
    m_id_tour = id;
    emit idTourChanged(id);
}

void GestionnaireDAffectations::setIdAffectation(int id)
{
    m_id_affectation = id;
    emit idAffectationChanged(id);
}

bool GestionnaireDAffectations::enregistrerEvenement()
{
    bool r = false;
    if (m_fiche_de_l_evenement->data(0, "id").toBool()) {
        if (m_fiche_de_l_evenement->submitAll()) {
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_de_l_evenement->lastError();
        }
    } else {
        if (m_fiche_de_l_evenement->submitAll()) {
            setIdEvenement(m_fiche_de_l_evenement->lastInsertId().toInt());
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_de_l_evenement->lastError();
        }
    }
    if (r) {
        m_liste_des_evenements->reload();
    }
    return r;
}

bool GestionnaireDAffectations::supprimerEvenement()
{
    bool r = false;
    if (m_fiche_de_l_evenement->removeRow(0) && m_fiche_de_l_evenement->submitAll()) {
        m_liste_des_evenements->reload();
        r = true;
    } else {
        qCritical() << __FUNCTION__ << m_fiche_de_l_evenement->lastError();
    }
    return r;
}

bool GestionnaireDAffectations::enregistrerPersonne()
{
    bool r = false;
    if (m_fiche_de_la_personne->data(0, "id").toBool()) {
        if (m_fiche_de_la_personne->submitAll()) {
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_de_la_personne->lastError();
        }
    } else {
        if (m_fiche_de_la_personne->submitAll()) {
            setIdPersonne(m_fiche_de_la_personne->lastInsertId().toInt());
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_de_la_personne->lastError();
        }
    }
    if (r) {
        // m_liste_des_personnes->reload(); // TODO
    }
    return r;
}

bool GestionnaireDAffectations::supprimerPersonne()
{
    bool r = false;
    if (m_fiche_de_la_personne->removeRow(0) && m_fiche_de_la_personne->submitAll()) {
        // m_liste_des_personnes->reload(); // TODO
        r = true;
    } else {
        qCritical() << __FUNCTION__ << m_fiche_de_la_personne->lastError();
    }
    return r;
}

bool GestionnaireDAffectations::enregistrerDisponibilite()
{
    bool r = false;
    if (m_fiche_de_la_disponibilite->data(0, "id").toBool()) {
        if (m_fiche_de_la_disponibilite->submitAll()) {
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_de_la_disponibilite->lastError();
        }
    } else {
        m_fiche_de_la_disponibilite->setData(0, "id_evenement", m_id_evenement);
        m_fiche_de_la_disponibilite->setData(0, "id_personne", m_id_personne);
        if (m_fiche_de_la_disponibilite->submitAll()) {
            setIdDisponibilite(m_fiche_de_la_disponibilite->lastInsertId().toInt());
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_de_la_disponibilite->lastError();
        }
    }
    if (r) {
        m_liste_des_disponibilites_de_l_evenement->reload();
    }
    return r;
}

bool GestionnaireDAffectations::supprimerDisponibilite()
{
    bool r = false;
    if (m_fiche_de_la_disponibilite->removeRow(0) && m_fiche_de_la_disponibilite->submitAll()) {
        m_liste_des_disponibilites_de_l_evenement->reload();
        r = true;
    } else {
        qCritical() << __FUNCTION__ << m_fiche_de_la_disponibilite->lastError();
    }
    return r;
}

bool GestionnaireDAffectations::enregistrerPoste() {
    bool r = false;
    if (m_fiche_du_poste->data(0, "id").toBool()) {
        if (m_fiche_du_poste->submitAll()) {
            r = true;
        } else {
            qCritical() << "Echec lors de l'enregistrement du poste :" << m_fiche_du_poste->lastError();
        }
    } else {
        m_fiche_du_poste->setData(0, "id_evenement", getIdEvenement());
        if (m_fiche_du_poste->submitAll()) {
            setIdPoste(m_fiche_du_poste->lastInsertId().toInt());
            r = true;
        } else {
            qCritical() << "Echec lors de l'enregistrement du nouveau poste :" << m_fiche_du_poste->lastError();
        }
    }
    if (r) {
        m_liste_des_postes_de_l_evenement->reload();
    }
    return r;
}

bool GestionnaireDAffectations::supprimerPoste()
{
    bool r = false;
    if (m_fiche_du_poste->removeRow(0) && m_fiche_du_poste->submitAll()) {
        m_liste_des_postes_de_l_evenement->reload();
        r = true;
    } else {
        qCritical() << "Echec lors de la suppression du poste :" << m_fiche_du_poste->lastError();
    }
    return r;
}

bool GestionnaireDAffectations::enregistrerTour()
{
    bool r = false;
    if (m_fiche_du_tour->data(0, "id").toBool()) {
        if (m_fiche_du_tour->submitAll()) {
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_du_tour->lastError();
        }
    } else {
        m_fiche_du_tour->setData(0, "id_poste", m_id_poste);
        if (m_fiche_du_tour->submitAll()) {
            setIdTour(m_fiche_du_tour->lastInsertId().toInt());
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_du_tour->lastError();
        }
    }
    if (r) {
        m_liste_des_tours_de_l_evenement->reload();
        m_liste_des_tours_du_poste->reload();
    }
    return r;
}

bool GestionnaireDAffectations::supprimerTour()
{
    bool r = false;
    if (m_fiche_du_tour->removeRow(0) && m_fiche_du_tour->submitAll()) {
        m_liste_des_tours_de_l_evenement->reload();
        m_liste_des_tours_du_poste->reload();
        r = true;
    } else {
        qCritical() << __FUNCTION__ << m_fiche_du_tour->lastError();
    }
    return r;
}

bool GestionnaireDAffectations::enregistrerAffectation()
{
    bool r = false;
    if (m_fiche_de_l_affectation->data(0, "id").toBool()) {
        if (m_fiche_de_l_affectation->submitAll()) {
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_de_l_affectation->lastError();
        }
    } else {
        m_fiche_de_l_affectation->setData(0, "id_tour", m_id_tour);
        m_fiche_de_l_affectation->setData(0, "id_disponibilite", m_id_disponibilite);
        m_fiche_de_l_affectation->setData(0, "commentaire", "");
        if (m_fiche_de_l_affectation->submitAll()) {
            setIdAffectation(m_fiche_de_l_affectation->lastInsertId().toInt());
            r = true;
        } else {
            qCritical() << __FUNCTION__ << m_fiche_de_l_affectation->lastError();
        }
    }
    if (r) {
        m_liste_des_affectations_de_la_disponibilite->reload();
        m_fiche_de_l_affectation_de_la_disponibilite_au_tour->reload();
        emit fiche_de_l_affectation_de_la_disponibilite_au_tourChanged(); // FIXME: reload() devrait l'avoir déjà fait
    }
    return r;
}

bool GestionnaireDAffectations::supprimerAffectation()
{
    bool r = false;
    if (m_fiche_de_l_affectation->removeRow(0) && m_fiche_de_l_affectation->submitAll()) {
        m_liste_des_affectations_de_la_disponibilite->reload();
        r = true;
    } else {
        qCritical() << __FUNCTION__ << m_fiche_de_l_affectation->lastError();
    }
    return r;
}


int GestionnaireDAffectations::getEvenementModelIndex() {
    return m_liste_des_evenements->getIndexFromId(getIdEvenement());
}

void GestionnaireDAffectations::enregistrerPlanEvenement(QUrl url)
{
    QFile file(url.toLocalFile());
    QXmlSimpleReader xmlReader;
    QXmlInputSource source(&file);
    if(xmlReader.parse(&source)) {
        QSqlQuery query;
        if (query.prepare("update evenement set plan=:plan where id=:id_evenement")) {
            file.seek(0);
            query.bindValue(":plan", QString(file.readAll()));
            query.bindValue(":id_evenement", getIdEvenement());
            if (query.exec()) {
                // setIdEvenement(m_id_evenement);
                emit planMisAJour();
            } else {
                qCritical() << "Echec d'execution de la requête d'enregistrement du plan :" << query.lastError();
            }
        } else {
            qCritical() << "Echec de préparation de la requête d'enregistrement du plan :" << query.lastError();
        }
    } else {
        qCritical() << "Le fichier" << url.toLocalFile() << "n'est pas un document SVG valide";
    }
    file.close();
}

void GestionnaireDAffectations::mettreAJourModelPlan(){
    m_proxy_de_la_liste_des_postes_de_l_evenement_par_heure->setHeure(m_heure);
}

void GestionnaireDAffectations::mettreAJourLesModelesQuiDependentDeIdEvenement(int id_evenement)
{
    mettreAJourLesModelesQuiDependent(":id_evenement", id_evenement);

    m_fiche_de_l_evenement->setFilter(QString("id=%1").arg(id_evenement)); // TODO: factoriser
    m_fiche_de_l_evenement->select();
    emit fiche_de_l_evenementChanged();

    m_toursParPosteModel->setIdEvenement(id_evenement);

    m_proxy_de_la_liste_des_postes_de_l_evenement_par_heure->setIdEvenement(id_evenement);
}

void GestionnaireDAffectations::mettreAJourLesModelesQuiDependentDeIdPersonne(int id_personne)
{
    mettreAJourLesModelesQuiDependent(":id_personne", id_personne);

    m_fiche_de_la_personne->setFilter(QString("id=%1").arg(id_personne)); // TODO: factoriser
    m_fiche_de_la_personne->select();
    emit fiche_de_la_personneChanged();
}

void GestionnaireDAffectations::mettreAJourLesModelesQuiDependentDeIdDisponibilite(int id_disponibilite)
{
    mettreAJourLesModelesQuiDependent(":id_disponibilite", id_disponibilite);

    m_fiche_de_la_disponibilite->setFilter(QString("id=%1").arg(id_disponibilite)); // TODO: factoriser
    m_fiche_de_la_disponibilite->select();
    emit fiche_de_la_disponibiliteChanged();
}

void GestionnaireDAffectations::mettreAJourLesModelesQuiDependentDeIdPoste(int id_poste)
{
    mettreAJourLesModelesQuiDependent(":id_poste", id_poste);

    m_fiche_du_poste->setFilter(QString("id=%1").arg(id_poste));
    if (m_fiche_du_poste->select()) {
        emit fiche_du_posteChanged();
    } else {
        qCritical() << "Echec d'execution de la requête de la fiche du poste" << id_poste << ":" << m_fiche_du_poste->lastError();
    }
}

void GestionnaireDAffectations::mettreAJourLesModelesQuiDependentDeIdTour(int id_tour)
{
    mettreAJourLesModelesQuiDependent(":id_tour", id_tour);

    m_fiche_du_tour->setFilter(QString("id=%1").arg(id_tour));
    if (m_fiche_du_tour->select()) {
        emit fiche_du_tourChanged();
    } else {
        qCritical() << "Echec d'execution de la requête de la fiche du tour" << id_tour << ":" << m_fiche_du_tour->lastError();
    }
}

void GestionnaireDAffectations::mettreAJourLesModelesQuiDependentDeIdAffectation(int id_affectation)
{
    mettreAJourLesModelesQuiDependent(":id_affectation", id_affectation);

    m_fiche_de_l_affectation->setFilter(QString("id=%1").arg(id_affectation)); // TODO: factoriser
    m_fiche_de_l_affectation->select();
    emit fiche_de_l_affectationChanged();
}

void GestionnaireDAffectations::ajouterResponsable(int id){
    QSqlQuery query;
    query.prepare("INSERT INTO responsable (id_personne, id_poste) VALUES (:id_personne, :id_poste)");
    query.bindValue(":id_personne",id);
    query.bindValue(":id_poste", m_id_poste);
    query.exec();
    qDebug() << query.lastError().text();

    tableauResponsablesChanged();
}

void GestionnaireDAffectations::rejeterResponsable(int id){
    QSqlQuery query;
    query.prepare("DELETE FROM responsable WHERE id_personne = :id_personne AND id_poste = :id_poste");
    query.bindValue(":id_personne",id);
    query.bindValue(":id_poste", m_id_poste);
    query.exec();

    m_responsables->reload();

    qDebug() << "Rejeté: " << id;

    tableauResponsablesChanged();
}



void GestionnaireDAffectations::annulerAffectation(QString commentaire){

    QSqlQuery query;

    if (query.prepare("update affectation set statut='annulee', commentaire=:commentaire where id=:id_affectation;")) {
        query.bindValue(":id_affectation", m_id_affectation);
        query.bindValue(":commentaire", commentaire);
        if (query.exec()) {
            m_liste_des_disponibilites_de_l_evenement->reload();
            m_liste_des_tours_de_l_evenement->reload();
            m_affectations_du_tour->reload();
            m_liste_des_affectations_de_la_disponibilite->reload();
        } else {
            qCritical() << "Impossible d'executer la requête d'annulation de l'affectation : " << query.lastError();
        }
    } else {
        qCritical() << "Impossible de préparer la requête d'annulation de l'affectation : " << query.lastError();
    }
}

void GestionnaireDAffectations::creerAffectation(QString commentaire){

    QSqlQuery query;

    if (query.prepare("INSERT INTO affectation"
                      "(id_disponibilite, id_tour, commentaire)"
                      "VALUES"
                      "(:id_disponibilite, :id_tour, :commentaire)"
                      )) {
        query.bindValue(":id_disponibilite", m_id_disponibilite);
        query.bindValue(":id_tour", m_id_tour);
        query.bindValue(":commentaire", commentaire);
        if (query.exec()) {
            m_id_affectation = query.lastInsertId().toInt();
            emit idAffectationChanged(m_id_affectation);
            m_liste_des_disponibilites_de_l_evenement->reload();
            m_liste_des_tours_de_l_evenement->reload();
            m_affectations_du_tour->reload();
        } else {
            qCritical() << "Impossible d'executer la requête de création de l'affectation : " << query.lastError();
        }
    } else {
        qCritical() << "Impossible de préparer la requête de création de l'affectation : " << query.lastError();
    }
}

void GestionnaireDAffectations::modifierTourDebut(QDateTime date, int heure, int minutes, int id) {

    QDateTime dateEtHeure;
    qDebug() << "C++" << date;

    QSqlQuery query;

    dateEtHeure = date.addSecs(heure*3600 + minutes*60);

    qDebug() << "C++" << dateEtHeure;

    query.prepare("UPDATE tour SET debut = :debut WHERE id = :id");
    query.bindValue(":debut",dateEtHeure);
    query.bindValue(":id",id);

    qDebug() << id;

    if(query.exec())
    {
        m_liste_des_tours_du_poste->reload();
        tableauTourChanged();
    }
    else
    {
        qCritical() << query.lastError().text();
    }


}



void GestionnaireDAffectations::modifierTourFin(QDateTime date, int heure, int minutes, int id) {

    QDateTime dateEtHeure;
    qDebug() << "C++" << date;

    QSqlQuery query;

    dateEtHeure = date.addSecs(heure*3600 + minutes*60);

    qDebug() << "C++" << dateEtHeure;

    query.prepare("UPDATE tour SET fin = :fin WHERE id_poste = :poste AND id = :id");
    query.bindValue(":poste",m_id_poste);
    query.bindValue(":fin",dateEtHeure);
    query.bindValue(":id",id);

    if(query.exec())
    {

        m_liste_des_tours_du_poste->reload();

        tableauTourChanged();
    }
    else
    {
        qCritical() << query.lastError().text();
    }

}

void GestionnaireDAffectations::modifierTourMinMax(QString type, int nombre, int id) {

    QSqlQuery query;

    if(type == "min" || type == "max")
    {
        if(type == "min")
        {
            query.prepare("UPDATE tour SET min = :nombre WHERE id_poste = :poste AND id = :id");
        }
        else
        {
            query.prepare("UPDATE tour SET max = :nombre WHERE id_poste = :poste AND id = :id");
        }

        query.bindValue(":poste",m_id_poste);
        query.bindValue(":nombre",nombre);
        query.bindValue(":id",id);

        if(!query.exec())
        {
            qCritical() << query.lastError().text();
        }
        else {
            m_liste_des_tours_de_l_evenement->reload();
        }

    }
    else {
        qDebug() << "Erreur venant du developpeur";
    }

}

void GestionnaireDAffectations::inscrireBenevole(QString nomBenevole, QString prenomBenevole, QString adresseBenevole,
                                                 QString codePostalBenevole, QString communeBenevole, QString courrielBenevole,
                                                 QString numPortableBenevole,QString numDomicileBenevole,QString professionBenevole,
                                                 QString datenaissanceBenevole, QString languesBenevole,QString competencesBenevole,
                                                 QString commentaireBenevole, QString joursEtHeures, QString listeAmis, QString typePoste,
                                                 QString commentaireDisponibilite)
{


    QSqlQuery query;
    QDateTime dateNaiss;
    dateNaiss.fromString(datenaissanceBenevole,"yyyy-MM-dd");


    qDebug() << datenaissanceBenevole;
    qDebug() << languesBenevole;
    qDebug() << competencesBenevole;
    qDebug() << commentaireBenevole;

    if(adresseBenevole == "") adresseBenevole = " ";
    if(codePostalBenevole == "") codePostalBenevole = " ";
    if(communeBenevole == "") communeBenevole = " ";
    if(numPortableBenevole == "") numPortableBenevole = " ";
    if(numDomicileBenevole == "") numDomicileBenevole = " ";
    if(courrielBenevole == "") courrielBenevole = " ";
    if(professionBenevole == "") numDomicileBenevole = " ";
    if(datenaissanceBenevole == "") datenaissanceBenevole = " ";
    if(competencesBenevole == "") competencesBenevole = " ";

    if(languesBenevole == "") languesBenevole = " ";
    if(commentaireBenevole == "") commentaireBenevole = " ";

    query.prepare("INSERT INTO personne (nom ,prenom, adresse , code_postal,ville,portable,domicile,email ,date_naissance, profession ,competences,avatar,langues,commentaire) VALUES (:nom , :prenom, :adresse , :code_postal,:ville, :portable, :domicile, :email , :date_naissance,  :profession , :competences, :avatar, :langues, :commentaire)");
    query.bindValue(":nom",nomBenevole);
    query.bindValue(":prenom",prenomBenevole);
    query.bindValue(":adresse",adresseBenevole);
    query.bindValue(":code_postal",codePostalBenevole);
    query.bindValue(":ville",communeBenevole);
    query.bindValue(":portable",numPortableBenevole);
    query.bindValue(":domicile",numDomicileBenevole);
    query.bindValue(":email",courrielBenevole);
    query.bindValue(":profession",professionBenevole);
    query.bindValue(":date_naissance",datenaissanceBenevole);
    query.bindValue(":competences",competencesBenevole);
    query.bindValue(":avatar","a");
    query.bindValue(":langues",languesBenevole);
    query.bindValue(":commentaire",commentaireBenevole);
    if(!query.exec())
    {
        qCritical() << query.lastError().text();
    }
    else {
        query.prepare("INSERT INTO disponibilite (id_personne,id_evenement,date_inscription,jours_et_heures_dispo, liste_amis,type_poste,commentaire,statut) VALUES (:id_personne,:id_evenement,:date_inscription,:jours_et_heures_dispo, :liste_amis,:type_poste,:commentaire,:statut)");
        query.bindValue(":id_personne",query.lastInsertId());
        query.bindValue(":id_evenement", getIdEvenement());
        query.bindValue(":date_inscription",QDateTime::currentDateTime());
        query.bindValue(":jours_et_heures_dispo",joursEtHeures);
        query.bindValue(":liste_amis",listeAmis);
        query.bindValue(":type_poste",typePoste);
        query.bindValue(":commentaire",commentaireDisponibilite);
        query.bindValue(":statut","validee");

        if(!query.exec())
        {
            qCritical() << query.lastError().text();
        }
        else {
            m_candidatures_en_attente->reload();
            inscriptionOk();
        }
    }

    qDebug() << query.lastQuery();
    qDebug() << query.lastError().text(); // On affiche l'erreur
    qDebug() << datenaissanceBenevole;
    qDebug() << dateNaiss.toString();

}

void GestionnaireDAffectations::validerCandidature(){

    QSqlQuery query;
    query.prepare("UPDATE disponibilite SET statut = 'validee' WHERE id = :id");
    query.bindValue(":id", m_id_disponibilite);
    query.exec();

    m_liste_des_disponibilites_de_l_evenement->reload();
    m_candidatures_en_attente->reload();

    candidatureValidee();
}

void GestionnaireDAffectations::rejeterCandidature(){
    QSqlQuery query;
    query.prepare("UPDATE disponibilite SET statut = 'rejetee' WHERE id = :id");
    query.bindValue(":id", m_id_disponibilite);
    query.exec();

    m_liste_des_disponibilites_de_l_evenement->reload();
    m_candidatures_en_attente->reload();

    candidatureRejetee();
}

void GestionnaireDAffectations::setIdDoublons(int id_doublon) {

    QSqlQuery query;
    query.prepare("select * from personnes_doublons where idnouveau = :id_doublon;");
    query.bindValue(":id_doublon",id_doublon);
    query.exec();
    m_personnes_doublons->setQuery(query);
}

QString GestionnaireDAffectations::creerLotDAffectations(bool possibles, bool proposees)
{
    QString adresseEmail; // L'adresse email qui sera retournée après génération

    QVariant prefixe = m_settings->value("email/prefixe");

    QVariant domaine = m_settings->value("email/domaine");

    if (prefixe.isValid() && domaine.isValid()) {
        if (possibles or proposees) {
            QSqlDatabase database = QSqlDatabase::database();
            if (database.transaction()) {
                QStringList titre;
                if (possibles) titre << "possibles";
                if (proposees) titre << "déjà proposées";
                QSqlQuery query;
                if (query.prepare("insert into lot(id_evenement, titre) values(:id_evenement, :titre) returning cle")) {
                    query.bindValue(":id_evenement", getIdEvenement());
                    query.bindValue(":titre", "Affectations " + titre.join(" ou "));
                    if (query.exec()) {
                        QVariant id = query.lastInsertId();
                        query.next();
                        QVariant cle = query.value(0);
                        adresseEmail = prefixe.toString() + '+' + id.toString() + '_' + cle.toString() + '@' + domaine.toString();
                        QStringList conditions;
                        if (possibles) conditions << "affectation.statut='possible'";
                        if (proposees) conditions << "affectation.statut='proposee'";
                        if (query.prepare(
                                    "insert into lot_personne(id_lot, id_personne)"
                                    " select distinct :id_lot::integer, id_personne"
                                    " from affectation"
                                    " join disponibilite on id_disponibilite = disponibilite.id"
                                    " where " + conditions.join(" or ") +
                                    " and id_evenement = :id_evenement" +
                                    " and (" + conditions.join(" or ") + ")"
                                    )) {
                            query.bindValue(":id_lot", id.toInt());
                            query.bindValue(":id_evenement", getIdEvenement());
                            if (query.exec()) {
                                database.commit();

                                m_lotsDejaCrees->reload();

                            } else {
                                qCritical() << "Impossible d'executer la requête de population du lot d'affectations : " << query.lastError();
                                database.rollback();
                            }
                        } else {
                            qCritical() << "Impossible de préparer la requête de population du lot d'affectations : " << query.lastError();
                            database.rollback();
                        }
                    } else {
                        qCritical() << "Impossible d'executer la requête de création du lot d'affectations : " << query.lastError();
                        database.rollback();
                    }
                } else {
                    qCritical() << "Impossible de préparer la requête de création du lot d'affectations : " << query.lastError();
                    database.rollback();
                }
            } else {
                qCritical() << "Impossible de démarrer la transaction de création du lot d'affectations : " << database.lastError();
            }
        } else {
            qWarning() << "Vous devez selectionner au moins un ensemble de destinataires";
        }
    } else {
        qWarning() << "Les paramètres de courriel (préfixe et domaine) ne sont pas renseignés";
    }
    return adresseEmail;
}


QString GestionnaireDAffectations::creerLotDeSolicitation(QString evenementsSelectionnes)
{
    QString adresseEmail; // L'adresse email qui sera retournée après génération
    QStringList listeEvenements = evenementsSelectionnes.split("|");



    QVariant prefixe = m_settings->value("email/prefixe");

    QVariant domaine = m_settings->value("email/domaine");

    if (prefixe.isValid() && domaine.isValid()) {
        if (listeEvenements.count() != 0) {
            QSqlDatabase database = QSqlDatabase::database();
            if (database.transaction()) {

                QStringList nomEvenements;

                for(int i=0; i<listeEvenements.count();i++)
                {
                    nomEvenements << (m_liste_des_evenements->getDataFromModel((listeEvenements[i]).toInt(),"nom")).toString();
                    qDebug() << "Tour numero " << i << ", nom: " << (m_liste_des_evenements->getDataFromModel((listeEvenements[i]).toInt(),"nom")).toString() << " max: " << listeEvenements.count();
                }

                qDebug() << nomEvenements.join(" ou ");

                QSqlQuery query;
                if (query.prepare("insert into lot(id_evenement, titre) values(:id_evenement, :titre) returning cle")) {
                    query.bindValue(":id_evenement", getIdEvenement());
                    query.bindValue(":titre", "Bénévoles ayant participé à " + nomEvenements.join(" ou "));
                    if (query.exec()) {
                        QVariant id = query.lastInsertId();
                        query.next();
                        QVariant cle = query.value(0); //
                        adresseEmail = prefixe.toString() + '+' + id.toString() + '_' + cle.toString() + '@' + domaine.toString();

                        QStringList conditions;

                        for(int i=0; i<listeEvenements.count();i++)
                        {
                            conditions << "id_evenement = "+(m_liste_des_evenements->getDataFromModel((listeEvenements[i]).toInt(),"id")).toString();
                        }


                        if (query.prepare(
                                    "insert into lot_personne(id_lot, id_personne)"
                                    " select ?, id_personne"
                                    " from disponibilite"
                                    " where " + conditions.join(" or ") + " LIMIT 1"
                                    )) {
                            query.addBindValue(id.toInt());
                            if (query.exec()) {
                                database.commit();

                                m_lotsDejaCrees->reload();

                            } else {
                                qCritical() << "Impossible d'executer la requête de population du lot de bénévoles : " << query.lastError();
                                database.rollback();
                            }
                        } else {
                            qCritical() << "Impossible de préparer la requête de population du lot de bénévoles : " << query.lastError();
                            database.rollback();
                        }
                    } else {
                        qCritical() << "Impossible d'executer la requête de création du lot de bénévoles : " << query.lastError();
                        database.rollback();
                    }
                } else {
                    qCritical() << "Impossible de préparer la requête de création du lot de bénévoles : " << query.lastError();
                    database.rollback();
                }
            } else {
                qCritical() << "Impossible de démarrer la transaction de création du lot de bénévoles : " << database.lastError();
            }
        } else {
            qWarning() << "Vous devez selectionner au moins un ensemble de bénévoles";
        }
    } else {
        qWarning() << "Les paramètres de courriel (préfixe et domaine) ne sont pas renseignés";
    }
    return adresseEmail;
}

void GestionnaireDAffectations::genererLesFichesDesPostesODT()
{
    FichesDesPostes document(getIdEvenement(), this);
    document.ouvrirODT();
}

void GestionnaireDAffectations::genererLesFichesDesPostesPDF()
{
    FichesDesPostes document(getIdEvenement(), this);
    document.ouvrirPDF();
}

void GestionnaireDAffectations::genererLesCartesDesBenevolesODT()
{
    CartesDesBenevoles document(getIdEvenement(), this);
    document.ouvrirODT();
}
void GestionnaireDAffectations::genererLesCartesDesBenevolesPDF()
{
    CartesDesBenevoles document(getIdEvenement(), this);
    document.ouvrirPDF();
}

void GestionnaireDAffectations::genererTableauDeRemplissage()
{
    TableauDeRemplissage document(getIdEvenement(), this);
    document.ouvrirPDF();
}

void GestionnaireDAffectations::genererLaListeDesDisponibilitesSansAffectation()
{
    ListeDesDisponibilitesSansAffectation document(getIdEvenement(), this);
    document.ouvrirPDF();
}

void GestionnaireDAffectations::genererExportCSV(QString nomVue, QString filtre)
{
    SqlTableModel table(this);
    table.setTable(nomVue);
    table.setFilter(filtre);
    if (table.select()) {
        table.ouvrirCSV();
    } else {
        qCritical() << table.lastError();
    }
}

void GestionnaireDAffectations::genererExportGeneralDesTours()
{
    genererExportCSV("export_general_des_tours", QString("id_evenement = %1").arg(getIdEvenement()));
}

void GestionnaireDAffectations::genererExportGeneralDesPersonnes()
{
    genererExportCSV("export_general_des_personnes", QString("id_evenement = %1").arg(getIdEvenement()));
}
