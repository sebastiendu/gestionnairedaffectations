#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QtQml>
#include <QtDebug>
#include <QQuickView>
#include <QXmlSimpleReader>
#include "gestionnairedaffectations.h"

GestionnaireDAffectations::GestionnaireDAffectations(int & argc, char ** argv):
    QGuiApplication(argc,argv)
{
    QCoreApplication::setOrganizationName("Les Développements Durables");
    QCoreApplication::setOrganizationDomain("ldd.fr");
    QCoreApplication::setApplicationName("Laguntzaile");

    //    qmlRegisterType<Settings>("fr.ldd.qml", 1, 0, "Settings");
    //    qmlRegisterType<SqlQueryModel>("fr.ldd.qml", 1, 0, "SqlQueryModel");
    //    qmlRegisterType<QSortFilterProxyModel>("fr.ldd.qml", 1, 0, "QSortFilterProxyModel");
    //    qmlRegisterType<ToursParPosteModel>("fr.ldd.qml", 1, 0, "ToursParPosteModel");

    //qInstallMessageHandler(gestionDesMessages);

    m_settings = new Settings;

    m_id_disponibilite=0;
    m_id_poste=0;
    ratioX  =-1;
    ratioY = -1;
    m_liste_des_evenements = new SqlQueryModel;
    m_postes = new SqlQueryModel;
    m_fiche_de_l_affectation = new SqlQueryModel;
    m_fiche_de_l_affectation_de_la_disponibilite_au_tour = new SqlQueryModel;
    m_fiche_du_tour = new SqlQueryModel;
    m_liste_des_affectations_de_la_disponibilite = new SqlQueryModel;
    m_affectations_du_tour = new SqlQueryModel;
    m_liste_des_disponibilites_de_l_evenement = new SqlQueryModel;
    m_proxy_de_la_liste_des_disponibilites_de_l_evenement = new QSortFilterProxyModel(this);
    m_fiche_de_la_disponibilite = new SqlQueryModel;
    m_fiche_personne = new SqlQueryModel;
    m_fiche_poste = new SqlQueryModel;
    m_fiche_poste_tour = new SqlQueryModel;
    m_liste_des_tours_de_l_evenement = new SqlQueryModel;
    m_proxy_de_la_liste_des_tours_de_l_evenement = new QSortFilterProxyModel(this);
    m_planComplet = new SqlQueryModel;
    m_plan = new QSortFilterProxyModel(this);
    m_horaires = new SqlQueryModel;
    m_etat_tour_heure = new QSortFilterProxyModel(this);
    m_etat_tour_heure_sql = new SqlQueryModel;
    m_lotsDejaCrees = new SqlQueryModel;
    m_candidatures_en_attente =  new SqlQueryModel;
    m_personnes_doublons = new SqlQueryModel;
    m_responsables = new SqlQueryModel;
    m_sequence_emploi_du_temps = new SqlQueryModel;
    m_remplissage_par_heure = new SqlQueryModel;

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

    connect(this,SIGNAL(heureChanged()),this,SLOT(mettreAJourModelPlan()));
    connect(this,SIGNAL(heureCouranteChanged()),this,SLOT(setHeureEtatTour()));
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

        // Initialiser les modèles

        QSqlQuery query;

        query.prepare("select * from liste_des_evenements ORDER BY id DESC");
        query.exec();
        m_liste_des_evenements->setQuery(query);

        query.prepare("select * from poste where id_evenement=? order by nom ");
        query.addBindValue(idEvenement());
        query.exec();
        m_postes->setQuery(query);

        qDebug() << "Id evenement: " << idEvenement();

        query.prepare("select * from benevoles_disponibles where id_evenement=?");
        query.addBindValue(idEvenement());
        query.exec();
        m_liste_des_disponibilites_de_l_evenement->setQuery(query);
        m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setSourceModel(m_liste_des_disponibilites_de_l_evenement);
        m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setFilterCaseSensitivity(Qt::CaseInsensitive);
        m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setFilterKeyColumn(-1);

        query.prepare("select * from fiche_benevole where id_disponibilite=:id_disponibilite");
        query.bindValue(":id_disponibilite", m_id_disponibilite);
        query.exec();
        m_fiche_de_la_disponibilite->setQuery(query);


        query.prepare("select * from poste_et_tour where id_poste= :poste AND id_evenement = :id_evenement AND debut <= :debut AND fin >= :fin ORDER BY debut ASC"); //AND debut <= :debut AND fin >= :fin"
        query.bindValue(":poste",m_id_poste);
        query.bindValue(":id_evenement",idEvenement());
        query.bindValue(":debut",m_heure.toString("yyyy-MM-d h:m:s"));
        query.bindValue(":fin",m_heure.toString("yyyy-MM-d h:m:s"));

        query.exec();
        m_fiche_poste->setQuery(query);

        query.prepare("select debut from poste_et_tour where id_evenement = :id GROUP BY debut ORDER BY debut ASC;");
        query.bindValue(":id",idEvenement());
        query.exec();
        m_horaires->setQuery(query);

        query.prepare("select * from tours where id_poste= :poste ORDER BY debut ASC;");
        query.bindValue(":poste",m_id_poste);
        query.exec();
        m_fiche_poste_tour->setQuery(query);

        query.prepare("select * from affectations where id_affectation=:id_affectation");
        query.bindValue(":id_affectation",m_id_affectation);
        query.exec();
        m_fiche_de_l_affectation->setQuery(query);

        if (query.prepare("select * from affectations"
                          " where id_disponibilite=:id_disponibilite"
                          " and id_tour=:id_tour")) {
            query.bindValue(":id_disponibilite", m_id_disponibilite);
            query.bindValue(":id_tour", m_id_tour);
            if (query.exec()) {
                m_fiche_de_l_affectation_de_la_disponibilite_au_tour->setQuery(query);
            } else {
                qCritical() << "Echec d'execution de la requête de la fiche de l'affectation de la disponibilite au tour :" << query.lastError();
            }
        } else {
            qCritical() << "Echec de préparation de la requête de la liste de l'affectation de la disponibilite au tour :" << query.lastError();
        }


        if (query.prepare("select * from tours_benevole where id_disponibilite = :id_disponibilite order by debut, fin")) {
            query.bindValue(":id_disponibilite", m_id_disponibilite);
            if (query.exec()) {
                m_liste_des_affectations_de_la_disponibilite->setQuery(query);
            } else {
                qCritical() << "Echec d'execution de la requête de la liste des affectations de la disponibilite :" << query.lastError();
            }
        } else {
            qCritical() << "Echec de préparation de la requête de la liste des affectations de la disponibilite :" << query.lastError();
        }

        if (query.prepare("select * from poste_et_tour where id_tour = :id_tour")) {
            query.bindValue(":id_tour", m_id_tour);
            if (query.exec()) {
                m_fiche_du_tour->setQuery(query);
            } else {
                qCritical() << "Echec d'execution de la requête de lecture de la fiche du tour :" << query.lastError();
            }
        } else {
            qCritical() << "Echec de préparation de la requête de lecture de la fiche du tour :" << query.lastError();
        }

        if (query.prepare("select * from affectations"
                          " where id_tour = :tour"
                          " order by"
                          " statut_affectation = 'possible' desc,"
                          " statut_affectation = 'proposee' desc,"
                          " statut_affectation = 'validee' desc,"
                          " statut_affectation = 'acceptee' desc,"
                          " statut_affectation = 'rejetee' desc,"
                          " statut_affectation = 'annulee' desc"
                          )) {
            query.bindValue(":tour",m_id_tour);
            if (query.exec()) {
                m_affectations_du_tour->setQuery(query);
            } else {
                qCritical() << "Echec d'execution de la requête des affectations du tour :" << query.lastError();
            }
        } else {
            qCritical() << "Echec de préparation de la requête des affectations du tour :" << query.lastError();
        }

        if (query.prepare("select * from remplissage_par_heure"
                          " where id_evenement = :id_evenement"
                          " order by heure")) {
            query.bindValue(":id_evenement", idEvenement());
            if (query.exec()) {
                m_remplissage_par_heure->setQuery(query);
            } else {
                qCritical() << "Echec d'execution de la requête du remplissage par heure :" << query.lastError();
            }
        } else {
            qCritical() << "Echec de préparation de la requête du remplissage par heure :" << query.lastError();
        }

        query.prepare("select * from poste where id_evenement= :evt;");
        query.bindValue(":evt",idEvenement());
        query.exec();
        m_planComplet->setQuery(query);

        qDebug() << query.lastError().text() ;

        query.prepare("select * from candidatures_en_attente WHERE id_evenement = :id_evenement;");
        query.bindValue(":id_evenement",idEvenement());
        query.exec();
        m_candidatures_en_attente->setQuery(query);


        query.prepare("select * from poste_et_tour where id_evenement= :id_evenement ORDER BY nom, debut ASC;");
        query.bindValue(":id_evenement",idEvenement());
        query.exec();
        m_liste_des_tours_de_l_evenement->setQuery(query);
        m_proxy_de_la_liste_des_tours_de_l_evenement->setSourceModel(m_liste_des_tours_de_l_evenement);
        m_proxy_de_la_liste_des_tours_de_l_evenement->setFilterCaseSensitivity(Qt::CaseInsensitive);
        m_proxy_de_la_liste_des_tours_de_l_evenement->setFilterKeyColumn(-1);

        query.prepare("SELECT distinct t.debut, t.fin, nom FROM poste left join tour on id_poste=poste.id left join taux_de_remplissage_tour as t on t.id_tour = tour.id WHERE (t.debut < :debut  AND fin > :fin) or t.debut is null AND id_evenement = :evt ORDER BY nom ;");
        query.bindValue(":evt",idEvenement());
        query.bindValue(":debut",m_heure_courante.toString("yyyy-MM-d h:m:s"));
        query.bindValue(":fin",m_heure_courante.toString("yyyy-MM-d h:m:s"));
        query.exec();
        m_etat_tour_heure_sql->setQuery(query);

        query.prepare("select date_de_creation, titre, traite, id, cle from lot;");
        query.exec();
        m_lotsDejaCrees->setQuery(query);

        /*   m_etat_tour_heure->setSourceModel(m_etat_tour_heure_sql);
        m_etat_tour_heure->setFilterCaseSensitivity(Qt::CaseInsensitive);
        m_etat_tour_heure->setFilterKeyColumn(-1); */

        query.prepare("select debut, fin from evenement where id=?");
        query.addBindValue(idEvenement());
        query.exec();
        if (query.next()) {
            setProperty("heureMin", query.value("debut").toDateTime());
            setProperty("heureMax", query.value("fin").toDateTime());
            setProperty("heure", query.value("debut").toDateTime());
        }


        m_toursParPosteModel = new ToursParPosteModel(this);
        m_toursParPosteModel->setIdEvenement(idEvenement());

        if (query.prepare("select * from libelle_sequence_evenement where id_evenement=?")) {
            query.addBindValue(idEvenement());
            if (query.exec()) {
                m_sequence_emploi_du_temps->setQuery(query);
            } else {
                qCritical() << "Impossible d'executer la requète de chargement des séquences de l'emploi du temps :" << db.lastError().text();
            }
        } else {
            qCritical() << "Impossible de préparer la requète de chargement des séquences de l'emploi du temps :" << db.lastError().text();
        }

    } else {
        qCritical() << "Impossible d'ouvrir la connexion à la base :" << db.lastError().text();
    }
    return db.isOpen();
}


int GestionnaireDAffectations::idEvenement() { // Retourne la valeur de la cle "id_evenement", qui ne peux être accédée que via un QSettings
    QSettings settings;
    return settings.value("id_evenement", 1).toInt();
}

void GestionnaireDAffectations::setIdEvenement(int id) {
    QSettings settings;
    settings.setValue("id_evenement", id);
    emit idEvenementChanged();
}

void GestionnaireDAffectations::setDebutEvenement(QDateTime date, int heure, int minutes)
{
    QDateTime dateEtHeure;

    QSqlQuery query;

    dateEtHeure = date.addSecs(heure*3600 + minutes*60);


    query.prepare("UPDATE evenement SET debut = :debut WHERE id = :id");
    query.bindValue(":debut",dateEtHeure.toUTC());
    query.bindValue(":id",idEvenement());

    if(query.exec())
    {
        query = m_liste_des_evenements->query();
        query.exec();
        m_liste_des_evenements->setQuery(query);

        liste_des_evenementsChanged();
    }
    else
    {
        qCritical() << query.lastError().text();
    }
}

void GestionnaireDAffectations::setFinEvenement(QDateTime date, int heure, int minutes)
{
    QDateTime dateEtHeure;

    QSqlQuery query;

    dateEtHeure = date.addSecs(heure*3600 + minutes*60);


    query.prepare("UPDATE evenement SET fin = :fin WHERE id = :id");
    query.bindValue(":fin",dateEtHeure);
    query.bindValue(":id",idEvenement());

    if(query.exec())
    {
        query = m_liste_des_evenements->query();
        query.exec();
        m_liste_des_evenements->setQuery(query);

        liste_des_evenementsChanged();
    }
    else
    {
        qCritical() << query.lastError().text();
    }
}

void GestionnaireDAffectations::updateEvenement(QString nom, QString lieu, bool archive)
{
    QSqlQuery query;
    query.prepare("UPDATE evenement SET nom = :nom, lieu = :lieu, archive = :archive WHERE id = :id");
    query.bindValue(":nom",nom);
    query.bindValue(":lieu",lieu);
    query.bindValue(":archive",archive);
    query.bindValue(":id",idEvenement());

    if(query.exec())
    {
        query = m_liste_des_evenements->query();
        query.exec();
        m_liste_des_evenements->setQuery(query);

        liste_des_evenementsChanged();
        fermerFenetreProprietesEvenement();
    }
    else
    {
        qCritical() << query.lastError().text();
    }
}

void GestionnaireDAffectations::setIdEvenementFromModelIndex(int index) {

    qDebug() << "L'id recu:" << index;

    this->setIdEvenement(m_liste_des_evenements->getIdFromIndex(index));

    qDebug() << "L'id mis en index: " << m_liste_des_evenements->getIdFromIndex(index);

    QSqlQuery query = m_liste_des_disponibilites_de_l_evenement->query(); // On fait un select des bénévoles participant à un événement avec un id précis
    query.bindValue(0,idEvenement()); // Cet id correspond à l'id evenement
    query.exec(); // On execute la requette
    m_liste_des_disponibilites_de_l_evenement->setQuery(query); // On remplace la requete ayant un id indéfini par une requete avec un id précis (idEvenement)

    query = m_postes->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_postes->setQuery(query);

    query = m_liste_des_evenements->query();
    query.exec();
    m_liste_des_evenements->setQuery(query);

    query = m_fiche_de_la_disponibilite->query();
    query.bindValue(0,0);
    query.exec();
    m_fiche_de_la_disponibilite->setQuery(query);

    query = m_fiche_poste->query();
    query.bindValue(0,0);
    query.exec();
    m_fiche_poste->setQuery(query);

    query = m_fiche_de_l_affectation->query();
    query.bindValue(0,0);
    query.exec();
    m_fiche_de_l_affectation->setQuery(query);

    query = m_fiche_de_l_affectation_de_la_disponibilite_au_tour->query();
    query.bindValue(0,0);
    query.exec();
    m_fiche_de_l_affectation_de_la_disponibilite_au_tour->setQuery(query);

    query = m_fiche_du_tour->query(); // FIXME: est-ce vraiment nécessaire ?
    query.bindValue(0,0);
    query.exec();
    m_fiche_du_tour->setQuery(query);

    query = m_liste_des_affectations_de_la_disponibilite->query(); // FIXME: est-ce vraiment nécessaire ?
    query.bindValue(0,0);
    query.exec();
    m_liste_des_affectations_de_la_disponibilite->setQuery(query);

    query = m_affectations_du_tour->query();
    query.bindValue(0,0);
    query.exec();
    m_affectations_du_tour->setQuery(query);

    query = m_planComplet->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_planComplet->setQuery(query);

    query = m_liste_des_tours_de_l_evenement->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_liste_des_tours_de_l_evenement->setQuery(query);


    query = m_etat_tour_heure_sql ->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_etat_tour_heure_sql ->setQuery(query);

    query = m_horaires->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_horaires->setQuery(query);

    query = m_candidatures_en_attente->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_candidatures_en_attente->setQuery(query);

    query = m_candidatures_en_attente->query();
    query.exec();
    m_candidatures_en_attente->setQuery(query);

    query.prepare("select debut, fin from evenement where id=?");
    query.addBindValue(idEvenement());
    query.exec();
    if (query.next()) {
        setProperty("heureMin", query.value("debut").toDateTime());
        setProperty("heureMax", query.value("fin").toDateTime());
        setProperty("heure", query.value("debut").toDateTime());
    }

}

int GestionnaireDAffectations::getEvenementModelIndex() {
    return m_liste_des_evenements->getIndexFromId(idEvenement());
}

void GestionnaireDAffectations::setIdPoste(int id) {
    m_id_poste = id;
    QSqlQuery query = m_fiche_poste->query();
    query.bindValue(":poste", m_id_poste);
    query.bindValue(":id_evenement",idEvenement());
    query.bindValue(":debut",m_heure.toString("yyyy-MM-d h:m:s"));
    query.bindValue(":fin",m_heure.toString("yyyy-MM-d h:m:s"));
    query.exec();
    m_fiche_poste->setQuery(query);

    qDebug() << "id du poste changé en: " << id;
    emit idPosteChanged();

}

void GestionnaireDAffectations::setIdPosteTour(int id) {
    m_id_poste = id;
    QSqlQuery query;
    query.prepare("select * from tours where id_poste= :poste ORDER BY debut ASC;");
    query.bindValue(":poste", id);
    query.exec();
    m_fiche_poste_tour->setQuery(query);
}

void GestionnaireDAffectations::setIdTourPoste(int id) {
    QSqlQuery query;
    query.prepare("select * from poste_et_tour WHERE id_tour = :tour;");
    query.bindValue(":tour", id);
    query.exec();
    m_fiche_poste_tour->setQuery(query);
}

void GestionnaireDAffectations::setIdAffectation(int id)
{
    qDebug() << "modification de m_id_affectation en" << id;
    m_id_affectation = id;
    QSqlQuery query = m_fiche_de_l_affectation->query();
    query.bindValue(":id_affectation", m_id_affectation);
    query.exec();
    m_fiche_de_l_affectation->setQuery(query);

    emit id_affectationChanged();

    qDebug() << "m_id_affectation changé en" << id;
}


void GestionnaireDAffectations::setResponsables() {
    QSqlQuery query;
    query.prepare("SELECT * FROM responsable JOIN personne ON responsable.id_personne=personne.id WHERE responsable.id_poste = :id_poste ");
    query.bindValue(":id_poste", m_id_poste);
    query.exec();
    qDebug() << m_id_poste;
    m_responsables->setQuery(query);
}

void GestionnaireDAffectations::setIdTour(int id) {
    qDebug() << "modification de m_id_tour en" << id;
    m_id_tour = id;

    QSqlQuery query = m_fiche_du_tour->query();
    query.bindValue(":id_tour", m_id_tour);
    query.exec();
    m_fiche_du_tour->setQuery(query);

    query = m_affectations_du_tour->query();
    query.bindValue(":tour", m_id_tour);
    query.exec();
    m_affectations_du_tour->setQuery(query);

    query = m_fiche_de_l_affectation_de_la_disponibilite_au_tour->query();
    query.bindValue(":id_tour", m_id_tour);
    query.exec();
    m_fiche_de_l_affectation_de_la_disponibilite_au_tour->setQuery(query);

    emit id_tourChanged();

    qDebug() << "m_id_tour changé en" << id;
}

void GestionnaireDAffectations::setIdDisponibilite(int id) {
    qDebug() << "m_id_disponibilite va changer vers" << id;
    m_id_disponibilite = id;

    QSqlQuery query = m_fiche_de_la_disponibilite->query();
    query.bindValue(":id_disponibilite", m_id_disponibilite);
    query.exec();
    m_fiche_de_la_disponibilite->setQuery(query);

    query = m_liste_des_affectations_de_la_disponibilite->query();
    query.bindValue(":id_disponibilite", m_id_disponibilite);
    query.exec();
    m_liste_des_affectations_de_la_disponibilite->setQuery(query);

    query = m_fiche_de_l_affectation_de_la_disponibilite_au_tour->query();
    query.bindValue(":id_disponibilite", m_id_disponibilite);
    query.exec();
    m_fiche_de_l_affectation_de_la_disponibilite_au_tour->setQuery(query);

    emit id_disponibiliteChanged();

    qDebug() << "m_id_disponibilite vaut maintenant" << id;
}

void GestionnaireDAffectations::setIdPersonne(int id) {
    QSqlQuery query;
    query.prepare("SELECT * FROM fiche_benevole WHERE id_personne = :id_personne AND id_evenement = :id_evenement");
    query.bindValue(":id_personne", id);
    query.bindValue(":id_evenement", idEvenement());
    query.exec();
    m_fiche_personne->setQuery(query);
}


void GestionnaireDAffectations::enregistrerNouvelEvenement(QString nom, QDateTime debut, QDateTime fin, int heureDebut, int heureFin, QString lieu, int id_evenement_precedent) {

    QDateTime dateEtHeureDebut;
    dateEtHeureDebut = debut.addSecs(heureDebut*3600);

    QDateTime dateEtHeureFin;
    dateEtHeureFin = fin.addSecs(heureFin*3600);

    QSqlQuery query;
    query.prepare("insert into evenement (nom, debut, fin, lieu, id_evenement_precedent) values (?,?,?,?,?)");
    query.addBindValue(nom);
    query.addBindValue(dateEtHeureDebut);
    query.addBindValue(dateEtHeureFin);
    query.addBindValue(lieu);
    query.addBindValue(id_evenement_precedent);
    if (query.exec()) {

        m_liste_des_evenements->query().exec();

        setIdEvenementFromModelIndex(0);
    }
    else {
        qDebug() << "Insertion: " << query.lastError().text();
    }



}

void GestionnaireDAffectations::supprimerEvenement() {

    QSqlQuery query;
    query.prepare("DELETE FROM evenement WHERE id = :id");
    query.bindValue(":id", idEvenement());
    query.exec();

    m_liste_des_evenements->query().exec();
    setIdEvenementFromModelIndex(0);


}

void GestionnaireDAffectations::enregistrerPlanEvenement(QUrl url)
{
    QFile file(url.toLocalFile());
    QXmlSimpleReader xmlReader;
    QXmlInputSource source(&file);
    if(xmlReader.parse(&source)) {
        QSqlQuery query;
        if (query.prepare("update evenement set plan=:plan where id=:id")) {
            file.seek(0);
            query.bindValue(":plan", QString(file.readAll()));
            query.bindValue(":id", idEvenement());
            if (query.exec()) {
                // setIdEvenement(idEvenement());
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

void GestionnaireDAffectations::setHeureEtatTour() {

    QSqlQuery query;
    query.prepare("SELECT distinct t.debut, t.fin, nom FROM poste left join tour on id_poste=poste.id left join taux_de_remplissage_tour as t on t.id_tour = tour.id WHERE (t.debut < :debut  AND t.fin > :fin) or t.debut is null AND id_evenement = :evt ORDER BY nom ;");
    query.bindValue(":evt",idEvenement());
    query.bindValue(":debut",m_heure_courante.toString("yyyy-MM-d h:m:s"));
    query.bindValue(":fin",m_heure_courante.toString("yyyy-MM-d h:m:s"));
    query.exec();

    m_etat_tour_heure_sql = new SqlQueryModel;
    m_etat_tour_heure_sql->setQuery(query);


    m_etat_tour_heure = new QSortFilterProxyModel();
    m_etat_tour_heure->setSourceModel(m_etat_tour_heure_sql);
    m_plan->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_plan->setFilterKeyColumn(-1);

}

void GestionnaireDAffectations::mettreAJourModelPlan(){

    QSqlQuery query;

    query.prepare("select * from poste_et_tour where id_evenement= :evt AND debut <= :debut AND fin >= :fin order by debut ");
    query.bindValue(":evt",idEvenement());
    query.bindValue(":debut",m_heure.toString("yyyy-MM-d h:m:s"));
    query.bindValue(":fin",m_heure.toString("yyyy-MM-d h:m:s"));
    query.exec();
    m_postes = new SqlQueryModel;
    m_postes->setQuery(query);


    m_plan = new QSortFilterProxyModel();
    m_plan->setSourceModel(m_postes);
    m_plan->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_plan->setFilterKeyColumn(-1);

    emit planChanged();

    qDebug() << "Nombre de colonne dans plan:" << m_plan->rowCount();
    qDebug() << m_plan->index(1,1);

    qDebug() << "La date:" << m_heure.toString("yyyy-MM-d h:m:s");
    qDebug() << "Nombre de postes à ce moment: " << m_postes->rowCount();
}


void GestionnaireDAffectations::ajouterResponsable(int id){
    QSqlQuery query;
    query.prepare("INSERT INTO responsable (id_personne, id_poste) VALUES (:id_personne, :id_poste)");
    query.bindValue(":id_personne",id);
    query.bindValue(":id_poste", m_id_poste);
    query.exec();
    qDebug() << query.lastError().text();

    setResponsables();

    tableauResponsablesChanged();
}

void GestionnaireDAffectations::rejeterResponsable(int id){
    QSqlQuery query;
    query.prepare("DELETE FROM responsable WHERE id_personne = :id_personne AND id_poste = :id_poste");
    query.bindValue(":id_personne",id);
    query.bindValue(":id_poste", m_id_poste);
    query.exec();
    setResponsables();

    qDebug() << "Rejeté: " << id;

    tableauResponsablesChanged();
}

void GestionnaireDAffectations::insererPoste(QString poste, QString description, bool autonome, float posx, float posy) {
    QSqlQuery query;
    query.prepare("INSERT INTO poste (id_evenement,nom,description,posx,posy,autonome) VALUES (:id_evenement, :poste, :description, :posx, :posy, :autonome);");
    query.bindValue(":id_evenement",idEvenement());
    query.bindValue(":poste",poste);
    query.bindValue(":autonome",autonome);
    query.bindValue(":description",description);
    query.bindValue(":posx",posx);
    query.bindValue(":posy",posy);
    query.exec();
    qDebug() << query.lastError().text();

    rechargerPlan();
}

void GestionnaireDAffectations::modifierPositionPoste(float ancienX,float ancienY) {


    if(ancienX == ratioX && ancienY == ratioY)
    {
        qDebug() << "Pas de requetes, la position n'a pas changée";
    }
    else
    {
        QSqlQuery query;
        query.prepare("UPDATE poste SET posx= :newx , posy = :newy WHERE id = :id");
        query.bindValue(":newx",ratioX);
        query.bindValue(":newy",ratioY);
        query.bindValue(":id",m_id_poste);

        query.exec();
        qDebug() << query.lastError().text();

    }

}


void GestionnaireDAffectations::supprimerPoste(int id){

    QSqlQuery query;

    query.prepare("DELETE FROM poste WHERE id = :id;");
    query.bindValue(":id",id);
    query.exec();
    qDebug() << query.lastError().text(); // Si erreur, on l'affiche dans la console

    setIdPoste(-1);
    rechargerPlan();
}


void GestionnaireDAffectations::modifierNomPoste(QString nom) {

    QSqlQuery query;
    query.prepare("UPDATE poste SET nom = :nom WHERE id = :id");
    query.bindValue(":nom",nom);
    query.bindValue(":id",m_id_poste);
    query.exec();

    qDebug() << "nom du poste " << m_id_poste << "modifié en " << nom;
    rechargerPlan();


}

void GestionnaireDAffectations::modifierDescriptionPoste(QString description) {

    QSqlQuery query;
    query.prepare("UPDATE poste SET description = :description WHERE id = :id");
    query.bindValue(":description",description);
    query.bindValue(":id",m_id_poste);
    query.exec();

    qDebug() << query.lastError().text();

}

void GestionnaireDAffectations::rechargerPlan(){

    QSqlQuery query;
    query = m_planComplet->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_planComplet->setQuery(query);

    planCompletChanged();
}

void GestionnaireDAffectations::annulerAffectation(QString commentaire){

    QSqlQuery query;

    if (query.prepare("update affectation set statut='annulee', commentaire=:commentaire where id=:id_affectation;")) {
        query.bindValue(":id_affectation", m_id_affectation);
        query.bindValue(":commentaire", commentaire);
        if (query.exec()) {
            m_liste_des_disponibilites_de_l_evenement->reload();
            m_fiche_de_la_disponibilite->reload();
            m_liste_des_tours_de_l_evenement->reload();
            m_fiche_du_tour->reload();
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
            m_liste_des_disponibilites_de_l_evenement->reload();
            m_fiche_de_la_disponibilite->reload();
            m_liste_des_tours_de_l_evenement->reload();
            m_fiche_du_tour->reload();
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
        query.prepare("select * from tours where id_poste= :poste ORDER BY debut ASC;");
        query.bindValue(":poste", m_id_poste);
        query.exec();
        m_fiche_poste_tour->setQuery(query);

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

        query.prepare("select * from tours where id_poste= :poste ORDER BY debut ASC;");
        query.bindValue(":poste", m_id_poste);
        query.exec();
        m_fiche_poste_tour->setQuery(query);

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
            query = m_liste_des_tours_de_l_evenement->query();
            query.bindValue(0,idEvenement());
            query.exec();
            m_liste_des_tours_de_l_evenement->setQuery(query);
        }

    }
    else {
        qDebug() << "Erreur venant du developpeur";
    }

}

void GestionnaireDAffectations::insererTour(QDateTime dateFinPrecedente, int min,int max){

    QDateTime dateQuatreHeuresApres;
    dateQuatreHeuresApres = dateFinPrecedente.addSecs(4*3600);

    QSqlQuery query;
    query.prepare("INSERT INTO tour (id_poste, debut, fin, min, max) VALUES (:id_poste, :debut, :fin, :min, :max);");
    query.bindValue(":id_poste",m_id_poste);
    query.bindValue(":debut",dateFinPrecedente);
    query.bindValue(":fin",dateQuatreHeuresApres);
    query.bindValue(":min",min);
    query.bindValue(":max",max);

    if(!query.exec())
    {
        qDebug() << query.lastError().text();
    }
    else {
        // On recharge la fiche du poste
        query.prepare("select * from tours where id_poste= :poste ORDER BY debut ASC;");
        query.bindValue(":poste", m_id_poste);
        query.exec();
        m_fiche_poste_tour->setQuery(query);

        // On recharge la liste des postes
        query = m_liste_des_tours_de_l_evenement->query();
        query.bindValue(":id_evenement",idEvenement());
        query.exec();
        m_liste_des_tours_de_l_evenement->setQuery(query);
        m_proxy_de_la_liste_des_tours_de_l_evenement->setSourceModel(m_liste_des_tours_de_l_evenement);
        m_proxy_de_la_liste_des_tours_de_l_evenement->setFilterCaseSensitivity(Qt::CaseInsensitive);
        m_proxy_de_la_liste_des_tours_de_l_evenement->setFilterKeyColumn(-1);

        tableauTourChanged();
    }

}

void GestionnaireDAffectations::supprimerTour(int id){

    QSqlQuery query;

    query.prepare("DELETE FROM tour WHERE id = :id;");
    query.bindValue(":id",id);
    query.exec();
    qDebug() << query.lastError().text(); // Si erreur, on l'affiche dans la console

    query.prepare("select * from tours where id_poste= :poste ORDER BY debut ASC;");
    query.bindValue(0,m_id_poste);
    query.exec();
    m_fiche_poste_tour->setQuery(query);

    tableauTourChanged();
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
        query.bindValue(":id_evenement",idEvenement());
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
            query = m_candidatures_en_attente->query();
            query.bindValue(0,idEvenement());
            query.exec();
            m_candidatures_en_attente->setQuery(query);
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

    query.prepare("select * from benevoles_disponibles where id_evenement=?");
    query.addBindValue(idEvenement());
    query.exec();
    m_liste_des_disponibilites_de_l_evenement->setQuery(query);
    m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setSourceModel(m_liste_des_disponibilites_de_l_evenement);
    m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setFilterKeyColumn(-1);

    query.prepare("select * from candidatures_en_attente WHERE id_evenement = :id_evenement;");
    query.bindValue(":id_evenement",idEvenement());
    query.exec();
    m_candidatures_en_attente->setQuery(query);

    candidatureValidee();

}

void GestionnaireDAffectations::rejeterCandidature(){
    QSqlQuery query;
    query.prepare("UPDATE disponibilite SET statut = 'rejetee' WHERE id = :id");
    query.bindValue(":id", m_id_disponibilite);
    query.exec();

    query.prepare("select * from benevoles_disponibles where id_evenement=?");
    query.addBindValue(idEvenement());
    query.exec();
    m_liste_des_disponibilites_de_l_evenement->setQuery(query);
    m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setSourceModel(m_liste_des_disponibilites_de_l_evenement);
    m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_proxy_de_la_liste_des_disponibilites_de_l_evenement->setFilterKeyColumn(-1);

    query.prepare("select * from candidatures_en_attente WHERE id_evenement = :id_evenement;");
    query.bindValue(":id_evenement",idEvenement());
    query.exec();
    m_candidatures_en_attente->setQuery(query);

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
                    query.bindValue(":id_evenement", idEvenement());
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
                            query.bindValue(":id_evenement", idEvenement());
                            if (query.exec()) {
                                database.commit();

                                query.prepare("select id_evenement, date_de_creation, titre, traite, id, cle from lot;");
                                query.exec();
                                m_lotsDejaCrees->setQuery(query);

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
                    query.bindValue(":id_evenement", idEvenement());
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

                                query.prepare("select date_de_creation, titre, traite, id, cle from lot;");
                                query.exec();
                                m_lotsDejaCrees->setQuery(query);

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


float GestionnaireDAffectations::getRatioX() { return this->ratioX ; }
float GestionnaireDAffectations::getRatioY() { return this->ratioY ;}
void GestionnaireDAffectations::setRatioX(float x) {this->ratioX = x ;}
void GestionnaireDAffectations::setRatioY(float y) {this->ratioY = y;}


int GestionnaireDAffectations::getNombreDeTours() { return this->nombreDeTours ; }
int GestionnaireDAffectations::getNombreDAffectations() { return this->nombreDAffectations ;}
QString GestionnaireDAffectations::getNomPoste() { return this->nomPoste ;}
int GestionnaireDAffectations::getIdPoste() { return this->m_id_poste ;}


void GestionnaireDAffectations::rafraichirStatistiquePoste(int id, QString nom) {

    m_id_poste = id;
    QSqlQuery query;

    query.prepare("SELECT nombre_tours,nombre_affectations FROM statistiques_postes WHERE id_poste = :id");
    query.bindValue(":id",m_id_poste);
    query.exec();

    if(query.first())
    {
        // La requete a réussie
        nombreDeTours = query.value(0).toInt();
        nombreDAffectations = query.value(1).toInt();
        nomPoste = nom;
    }
    else
    {
        // La requete a renvoyé 0 lignes, on ne considère pas qu'elle a raté mais qu'aucun tour n'a été associé au poste.
        nombreDeTours = 0;
        nombreDAffectations = 0;
        nomPoste = nom;
    }

    qDebug() << query.lastError().text(); // Si erreur, on l'affiche dans la console


}


// ==============================================
// =============GENERATION DES ETATS ============
// ==============================================


void GestionnaireDAffectations::genererFichesDePostes()
{
    // FICHIER //
    QTemporaryFile* f = new QTemporaryFile("Fiches_De_Postes_XXXXXX");
    f->open();
    qDebug("reussi !");
    // REQUETE //
    QSqlQuery query;
    query.prepare("select * from fiche_de_poste_benevoles_par_tour where id_evenement= :evt");
    query.bindValue(":evt",idEvenement());
    query.exec();

    // PANDOC //
    QProcess* pandoc = new QProcess(this);
    pandoc->setProgram("pandoc");
    QStringList arguments;
    arguments << "-f" << "markdown" << "-t" << "odt" << "-o" << f->fileName() << "-";
    pandoc->setArguments(arguments);
    pandoc->start();
    pandoc->waitForStarted();

    // INITIALISATIONS //
    int id_poste = -2;
    int id_tourPrecedent = -1;
    QString dateTourCourant = QString("-1");
    QString dateTourPrecedent = QString("-2");

    // TRAITEMENTS //
    afficherEntete(pandoc,query);

    while (query.next())
    {
        if (query.record().value("id_poste").toInt() != id_poste)
        {
            dateTourCourant = "-1";  // On réinitialise les deux variables à des valeurs différentes pour
            dateTourPrecedent = "-2";// l'affichage de la date
            //(id_poste!=-2?pandoc->write("\n -------- \n"):id_poste=id_poste);
            id_poste = query.record().value("id_poste").toInt();
            id_tourPrecedent = -1;


            pandoc->write("\n\n"); // Pour forcer la fin du tableau
            faireUnRetourALaLigne(pandoc);
            pandoc->write("\n### ");
            pandoc->write(query.record().value("nom_poste").toString().toUtf8());
            pandoc->write("\n\n");
        }

        if (query.record().value("id_tour").toInt() != id_tourPrecedent)
        {
            id_tourPrecedent = query.record().value("id_tour").toInt();

            dateTourCourant = query.record().value("debut_tour").toDateTime().toString("dMMYYYY");

            if (dateTourCourant != dateTourPrecedent)
            {
                dateTourPrecedent = dateTourCourant;
                pandoc->write("\n\n"); // Pour forcer la fin du tableau
                faireUnRetourALaLigne(pandoc);
                pandoc->write("\n\n##       ");
                pandoc->write(query.record().value("debut_tour").toDateTime().toString("dddd d MMMM yyyy").toUtf8());
                pandoc->write("\n\n");
                //pandoc->write(" de ")
            }
            pandoc->write("\n\n "); // PAS TOUCHER A CA ... //
            pandoc->write(" \n\n ");// CA MARCHE ...     //
            pandoc->write("              ● ");
            pandoc->write(query.record().value("debut_tour").toDateTime().toString("H:mm").toUtf8());
            pandoc->write(" → ");
            pandoc->write(query.record().value("fin_tour").toDateTime().toString("H:mm").toUtf8());
            pandoc->write("\n\n");

            pandoc->write("Nom|Prénom|Portable\n");
            pandoc->write("---|---|---\n");
        }

        pandoc->write(query.record().value("nom_personne").toString().toUtf8());
        pandoc->write("|");
        pandoc->write(query.record().value("prenom_personne").toString().toUtf8());
        pandoc->write("|");
        pandoc->write(query.record().value("portable").toString().toUtf8());
        pandoc->write("\n");
    }

    pandoc->closeWriteChannel();
    pandoc->waitForFinished();

    qDebug() << pandoc->readAll();

    QProcess* lowriter = new QProcess(this);
    lowriter->start("lowriter", QStringList() << f->fileName());
    lowriter->waitForFinished();

    qDebug() << lowriter->readAll();

}


void GestionnaireDAffectations::genererCarteBenevoles()
{
    // FICHIER //
    QTemporaryFile* f = new QTemporaryFile("Carte_de_benevoles_XXXXXX.odt");
    f->open();

    // REQUETE //
    QSqlQuery query;
    query.prepare("select * from carte_de_benevole_inscriptions_postes where id_evenement= :evt");
    query.bindValue(":evt",idEvenement());
    query.exec();

    // PANDOC //
    QProcess* pandoc = new QProcess(this);
    pandoc->setProgram("pandoc");
    QStringList arguments;
    arguments << "-f" << "markdown" << "-t" << "odt" << "-o" << f->fileName() << "-";
    pandoc->setArguments(arguments);
    pandoc->start();
    pandoc->waitForStarted();

    // INITIALISATIONS //
    int id_personne = -2;
    QString jourCourant = "-2";

    // TRAITEMENTS //
    afficherEntete(pandoc,query);


    while (query.next())
    {
        if (query.record().value("id_personne").toInt() != id_personne)
        {
            id_personne = query.record().value("id_personne").toInt();

            jourCourant = "-1";

            pandoc->write("\n\n"); // Pour forcer la fin du tableau
            faireUnRetourALaLigne(pandoc);
            faireUnRetourALaLigne(pandoc);
            pandoc->write("\n");
            pandoc->write("# ");
            pandoc->write(query.record().value("nom_personne").toString().toUtf8());
            pandoc->write(" ");
            pandoc->write(query.record().value("prenom_personne").toString().toUtf8());
            pandoc->write("\n");

            if (query.record().value("domicile").toString().toUtf8() != "")
            {
                pandoc->write(QString("[").append(query.record().value("domicile").toString()).append("]").append("(callto:").append(query.record().value("portable").toString()).append(")\n\n").toUtf8());

                if (query.record().value("portable").toString().toUtf8() != "")
                {
                    pandoc->write(" | ");
                }
            }
            if (query.record().value("portable").toString().toUtf8() != "")
            {
                pandoc->write(QString("[").append(query.record().value("portable").toString()).append("]").append("(callto:").append(query.record().value("portable").toString()).append(")\n\n").toUtf8());
                pandoc->write("\n\n");
            }
            else
            {
                pandoc->write("\n\n");
            }
        }

        if (query.record().value("debut_tour").toDateTime().toString("d") != jourCourant)
        {
            pandoc->write("\n");
            jourCourant = query.record().value("debut_tour").toDateTime().toString("d");

            pandoc->write("##");
            pandoc->write(query.record().value("debut_tour").toDateTime().toString("dddd d MMMM yyyy").toUtf8());
            pandoc->write("\n");
            pandoc->write("Poste|Debut|Fin\n");
            pandoc->write("---|---|---\n");

        }
        pandoc->write(query.record().value("nom_poste").toString().toUtf8());
        pandoc->write("|");
        pandoc->write(query.record().value("debut_tour").toDateTime().toString("H:mm").toUtf8());
        pandoc->write("|");
        pandoc->write(query.record().value("fin_tour").toDateTime().toString("H:mm").toUtf8());
        pandoc->write("\n");
    }

    pandoc->closeWriteChannel();
    pandoc->waitForFinished();


    qDebug() << pandoc->readAll();

    QProcess* lowriter = new QProcess(this);
    lowriter->start("lowriter", QStringList() << f->fileName());
    lowriter->waitForFinished();

    qDebug() << f->fileName();

    qDebug() << lowriter->readAll();
}

void GestionnaireDAffectations::genererTableauRemplissage()
{
    // FICHIER //
    QTemporaryFile* f = new QTemporaryFile("Tableau_De_Remplissage_XXXXXX.odt");
    f->open();

    // REQUETE //
    QSqlQuery query; // Création d'une requete
    query.prepare("select * from tableau_de_remplissage where id_evenement= :evt"); // Alimentation de la requete
    query.bindValue(":evt",idEvenement()); // Affectation des parametres de la requete
    query.exec(); //Execution de la requete

    // PANDOC //
    QProcess* pandoc = new QProcess(this); // Mise en place de la commande pandoc
    pandoc->setProgram("pandoc");
    QStringList arguments; // Définition des arguments de la commande pandoc
    arguments << "-f" << "markdown" << "-t" << "odt" << "-o" << f->fileName() << "-";
    pandoc->setArguments(arguments);
    pandoc->start();
    pandoc->waitForStarted();


    int idPostePrecedent = -2; // Intialisation d'une valeur d'id_Poste imossible à trouver à bd en premiere occurence

    QString jourRequetePrecedente = "-1"; // Initlisation d'une valeur de jourRequetePrecedente impossible à trouver un BD
    QString nomEvenementCourant;
    QString jourCourant;
    QString nomPosteCourant;
    QString lieuEvenementCourant;

    // calcul de la différence entre le nb de participants inscrits et nb necessaire
    int difference, nbAffectationCourant, minNecessaireCourant, maxNecessaireCourant, idPosteCourant; // calcul de la différence entre le nb de participants inscrits et nb necessaire

    afficherEntete(pandoc,query);
    query.previous(); // Ne pas oublier la première ligne

    while (query.next())
    {
        nbAffectationCourant = query.record().value("nombre_affectations").toInt();
        minNecessaireCourant = query.record().value("min").toInt();
        maxNecessaireCourant = query.record().value("max").toInt();
        idPosteCourant = query.record().value("id_poste").toInt();
        jourCourant = query.record().value("debut_tour").toDateTime().toString("d/MM");
        nomPosteCourant = query.record().value("nom_poste").toString();

        if (jourCourant != jourRequetePrecedente)
        {
            jourRequetePrecedente = jourCourant;
            idPostePrecedent = -1; // On réinitialise pour ne pas l'oublier
            pandoc->write("\n\n##");
            pandoc->write(query.record().value("debut_tour").toDateTime().toString("d MMMM yyyy").toUtf8());
            pandoc->write("\n");
            pandoc->write("Tour|Poste|Min|Max|Inscrits|Remplissage\n");
            pandoc->write("---|---|---|---|---|---\n");
        }

        // Colonne Tour
        pandoc->write(query.record().value("debut_tour").toDateTime().toString("H:mm").toUtf8());
        pandoc->write(" → ");
        pandoc->write(query.record().value("fin_tour").toDateTime().toString("H:mm").toUtf8());
        pandoc->write("|");

        // Colonne Poste
        if(idPosteCourant != idPostePrecedent)
        {
            idPostePrecedent = idPosteCourant;
            pandoc->write(nomPosteCourant.toUtf8());
        }
        else
        {
            pandoc->write("-");
        }

        pandoc->write("|");

        //Colonne Min
        if (minNecessaireCourant > nbAffectationCourant)
        {
            pandoc->write("**");
            pandoc->write(QString().setNum(minNecessaireCourant).toUtf8());
            pandoc->write("**");
        }

        else
            pandoc->write(QString().setNum(minNecessaireCourant).toUtf8());

        pandoc->write("|");

        //Colonne Max
        if (maxNecessaireCourant < nbAffectationCourant)
        {
            pandoc->write("**");
            pandoc->write(QString().setNum(maxNecessaireCourant).toUtf8());
            pandoc->write("**");
        }
        else
            pandoc->write(QString().setNum(maxNecessaireCourant).toUtf8());

        pandoc->write("|");


        //Colonne Nombre d'inscrits
        if (nbAffectationCourant < minNecessaireCourant || nbAffectationCourant > maxNecessaireCourant)
        {
            pandoc->write("**");
            pandoc->write(QString().setNum(nbAffectationCourant).toUtf8());
            pandoc->write("**");
        }

        else
            pandoc->write(QString().setNum(nbAffectationCourant).toUtf8());

        pandoc->write("|");

        // Colone manque
        QString rondNoir = QString("●");
        QString rondBlanc = QString("○");
        QString etatRemplissage = QString("null");

        if (nbAffectationCourant >= minNecessaireCourant && nbAffectationCourant <= maxNecessaireCourant)
        {
            etatRemplissage = "ok";
        }

        else if (nbAffectationCourant < minNecessaireCourant)
        {
            etatRemplissage = "manque";
            difference = (minNecessaireCourant-nbAffectationCourant);
        }

        else if (nbAffectationCourant > maxNecessaireCourant)
        {
            etatRemplissage = "trop";
            difference = (maxNecessaireCourant);

        }

        if (etatRemplissage == "ok")
        {
            if (nbAffectationCourant < 10)
            {
                for (int i = 0 ; i < nbAffectationCourant ; i++)
                    pandoc->write(rondNoir.toUtf8());
            }
            else
            {
                for (int i = 0 ; i < 10 ; i++)
                    pandoc->write(rondNoir.toUtf8());
            }
        }

        else if (etatRemplissage == "manque")
        {
            if (minNecessaireCourant < 10)
            {
                for (int i = 0; i< nbAffectationCourant ; i++)
                    pandoc->write(rondNoir.toUtf8());

                for (int j = nbAffectationCourant ; j < minNecessaireCourant ; j++)
                    pandoc->write(rondBlanc.toUtf8());
            }

            else if (minNecessaireCourant >= 10)
            {
                int nbRondsNoirs = nbAffectationCourant * 10 / minNecessaireCourant;
                for (int i = 0 ; i < nbRondsNoirs ; i++)
                    pandoc->write(rondNoir.toUtf8());

                for (int j = nbRondsNoirs ; j < 10 ; j++)
                    pandoc->write(rondBlanc.toUtf8());
            }

        }

        else if (etatRemplissage == "trop")
        {
            if (maxNecessaireCourant < 10)
            {
                for (int i = 0; i < maxNecessaireCourant ; i++)
                    pandoc->write(rondNoir.toUtf8());

                for (int j = maxNecessaireCourant ; j < nbAffectationCourant ; j++)
                    pandoc->write("**#**");

            }

            else if (maxNecessaireCourant >= 10)
            {
                int nbRondsNoirs = maxNecessaireCourant * 10 / minNecessaireCourant;
                int nbDieses = nbAffectationCourant / maxNecessaireCourant;
                (nbDieses == 0?nbDieses=1:nbDieses=nbDieses); // Si l'arrondi est fait en dessous, on s'assure d'avoir au moins un diese

                for (int i = 0 ; i < 10-nbDieses ; i++)
                    pandoc->write(rondNoir.toUtf8());

                for (int j = 0 ; j < nbDieses ; j++)
                    pandoc->write("**#**");
            }
        }
        pandoc->write("\n");
    } // Fin du parcours

    terminerGenerationEtat(pandoc,f);
}

void GestionnaireDAffectations::genererFichesProblemes()
{
    // FICHIER //

    QTemporaryFile* f = new QTemporaryFile("Fiche_bénévoles_sans_tour_de_travail_XXXXXX.odt");
    f->open();

    // REQUETE //
    QSqlQuery query;
    query.prepare("select * from fiches_a_probleme where id_evenement= :evt");
    query.bindValue(":evt",idEvenement());
    query.exec();

    // PANDOC //
    QProcess* pandoc = new QProcess(this);
    pandoc->setProgram("pandoc");
    QStringList arguments;
    arguments << "-f" << "markdown" << "-t" << "odt" << "-o" << f->fileName() << "-";
    pandoc->setArguments(arguments);
    pandoc->start();
    pandoc->waitForStarted();

    // INITISALISATION //

    QString nomEvenementCourant;
    QString lieuEvenementCourant;
    QString nomPersonneCourant;
    QString prenomPersonneCourant;
    QString adressePersonneCourant;
    QString codePostalPersonneCourant;
    QString villePersonneCourant;
    QString portablePersonneCourant;
    QString domicilePersonneCourant;
    QString emailPersonneCourant;
    int agePersonneCourant;
    QString professionPersonneCourant;
    QString competencesPersonneCourant;
    QString languesPersonneCourant;
    QString amisPersonneCourant;
    QString typePostePersonneCourant;
    QString commentairePersonneCourant;
    QDate dateDebutEvenement;
    QDate dateNaissancePersonneCourant;
    QString dateEtHeureDispo;

    afficherEntete(pandoc,query);

    while (query.next())
    {

        nomPersonneCourant = query.record().value("nom_personne").toString();
        prenomPersonneCourant = query.record().value("prenom_personne").toString();
        adressePersonneCourant = query.record().value("adresse").toString();
        codePostalPersonneCourant = query.record().value("code_postal").toString();
        villePersonneCourant = query.record().value("ville").toString();
        portablePersonneCourant = query.record().value("portable").toString();
        domicilePersonneCourant = query.record().value("domicile").toString();
        emailPersonneCourant = query.record().value("email").toString();
        dateNaissancePersonneCourant = query.record().value("date_naissance").toDate();
        professionPersonneCourant = query.record().value("profession").toString();
        competencesPersonneCourant = query.record().value("competences").toString();
        languesPersonneCourant = query.record().value("langues").toString();
        amisPersonneCourant = query.record().value("liste_amis").toString();
        typePostePersonneCourant = query.record().value("type_poste").toString();
        commentairePersonneCourant = query.record().value("commentaire_disponibilite").toString();
        dateEtHeureDispo = query.record().value("jours_et_heures_dispo").toString();

        faireUnRetourALaLigne(pandoc);
        pandoc->write("\n###");
        pandoc->write(nomPersonneCourant.toUtf8());

        if (prenomPersonneCourant != "")
            pandoc->write(QString(" ").append(prenomPersonneCourant).toUtf8());

        pandoc->write("\n\n");

        if (adressePersonneCourant != "")
        {
            /*pandoc->write(QString("* Adresse :").toUtf8());
            pandoc->write(QString("\n\n").toUtf8());
            pandoc->write(QString("          ").append(adressePersonneCourant).toUtf8());*/
            //pandoc->write("###");
            pandoc->write(adressePersonneCourant.toUtf8());
            pandoc->write(QString("\n\n").toUtf8());
            pandoc->write(codePostalPersonneCourant.append(" ").append(villePersonneCourant).toUtf8());
            pandoc->write("\n\n");
        }
        if (portablePersonneCourant != "")
            pandoc->write((QString("[").append(portablePersonneCourant).append("]").append("(callto:").append(portablePersonneCourant).append(")\n\n")).toUtf8());

        if (domicilePersonneCourant != "")
            pandoc->write((QString("[").append(domicilePersonneCourant).append("]").append("(callto:").append(domicilePersonneCourant).append(")\n\n")).toUtf8());

        if (emailPersonneCourant != "")
            pandoc->write((QString("[").append(emailPersonneCourant).append("]").append("(mailto:").append(emailPersonneCourant).append(")\n\n")).toUtf8());

        if (!dateNaissancePersonneCourant.isNull())
        {
            QDate dateNais = query.record().value("date_naissance").toDate();
            QDate dateRepere = query.record().value("debut_evenement").toDate();
            int agePersonneCourant = age(dateNais,dateRepere);


            pandoc->write(QString("                    ● ").toUtf8());

            pandoc->write(QString().setNum(agePersonneCourant).toUtf8());

            pandoc->write(QString(" ans ").toUtf8());

            pandoc->write(QString(" (né(e) le ").toUtf8());

            pandoc->write(dateNaissancePersonneCourant.toString("d/MM/yyyy)").toUtf8());

            pandoc->write(QString("\n\n").toUtf8());

        }


        if (professionPersonneCourant != "")
            pandoc->write(QString("                    ● Profession : ").append(professionPersonneCourant).append("\n\n").toUtf8());

        if (competencesPersonneCourant != "")
            pandoc->write(QString("                    ● Competences : ").append(competencesPersonneCourant).append("\n\n").toUtf8());

        if (languesPersonneCourant != "")
            pandoc->write(QString("                    ● Langues: ").append(languesPersonneCourant).append("\n\n").toUtf8());

        if (amisPersonneCourant != "")
            pandoc->write(QString("                    ● Disponibilités : ").append(dateEtHeureDispo).append("\n\n").toUtf8());

        if (amisPersonneCourant != "")
            pandoc->write(QString("                    ● Affinités : ").append(amisPersonneCourant).append("\n\n").toUtf8());

        if (typePostePersonneCourant != "")
            pandoc->write(QString("                    ● Type de poste souhaité : ").append(typePostePersonneCourant).append("\n\n").toUtf8());

        if (commentairePersonneCourant != "")
            pandoc->write(QString("                    ● Commentaire : ").append(commentairePersonneCourant).append("\n\n").toUtf8());
    }

    terminerGenerationEtat(pandoc,f);
}

void GestionnaireDAffectations::genererExportGeneral()
{
    // FICHIER //
    QTemporaryFile* f = new QTemporaryFile("Export_General_XXXXXX.odt");
    f->open();



    // REQUETE //
    QSqlQuery query;
    query.prepare("select * from export_general_personnes where id_evenement= :evt");
    query.bindValue(":evt",idEvenement());
    query.exec();



    // PANDOC //
    QProcess* pandoc = new QProcess(this);
    pandoc->setProgram("pandoc");
    QStringList arguments;
    arguments << "-f" << "markdown" << "-t" << "odt" << "-o" << f->fileName() << "-";
    pandoc->setArguments(arguments);
    pandoc->start();
    pandoc->waitForStarted();



    // INITISALISATION //
    QString nomEvenementCourant;
    QString lieuEvenementCourant;
    int idPersonneCourant = -1;
    int idPersonnePrecedent = -2;

    QString nomPersonneCourant;
    QString prenomPersonneCourant;
    QString domicilePersonneCourant;
    QString portablePersonneCourant;
    QString emailPersonneCourant;
    QString postePersonneCourant;
    QString debutTourPersonneCourant;
    QString finTourPersonneCourant;
    bool premierTourDeBoucle = true;
    bool estRentreDansLaBoucle = false; // Comme je triche un peu pour laisser les trois cases vides dans le tableau, je m'assure quand même que ce dernier a été construit...

    // TRAITEMENT //

    afficherEntete(pandoc,query);
    pandoc->write("\n");
    pandoc->write("\n");
    pandoc->write("\n");
    pandoc->write("#");
    pandoc->write("                          Personnes \n\n");
    faireUnRetourALaLigne(pandoc);


    while (query.next())
    {
        estRentreDansLaBoucle = true;
        nomPersonneCourant = query.record().value("nom_personne").toString();
        prenomPersonneCourant = query.record().value("prenom_personne").toString();
        domicilePersonneCourant = query.record().value("domicile").toString();
        portablePersonneCourant = query.record().value("portable").toString();
        emailPersonneCourant = query.record().value("email").toString();
        postePersonneCourant = query.record().value("nom_poste").toString();


        idPersonneCourant = query.record().value("id_personne").toInt();

        debutTourPersonneCourant = query.record().value("debut_tour").toDateTime().toString("H:mm");
        finTourPersonneCourant = query.record().value("fin_tour").toDateTime().toString("H:mm");

        if (idPersonnePrecedent != idPersonneCourant)
        {
            idPersonnePrecedent = idPersonneCourant;
            // Donnees

            if (!premierTourDeBoucle)
            {
                // Laisser des places vides dans le tableau
                pandoc->write(" ");
                pandoc->write("|");
                pandoc->write(" ");
                pandoc->write("\n");

                pandoc->write(" ");
                pandoc->write("|");
                pandoc->write(" ");
                pandoc->write("\n");

                pandoc->write(" ");
                pandoc->write("|");
                pandoc->write(" ");
                pandoc->write("\n");
                // -----
            }
            premierTourDeBoucle = false;

            pandoc->write("\n");
            pandoc->write("\n");
            pandoc->write("###");
            pandoc->write(nomPersonneCourant.toUtf8());
            pandoc->write(" ");
            pandoc->write(prenomPersonneCourant.toUtf8());
            pandoc->write("\n");
            pandoc->write("####");


            if (domicilePersonneCourant != "")
                pandoc->write(QString("[").append(domicilePersonneCourant).append("]").append("(callto:").append(domicilePersonneCourant).append(")").toUtf8());

            if (portablePersonneCourant != "")
            {
                if (domicilePersonneCourant != "")
                {
                    pandoc->write(QString(" — ").append(QString("[")).append(portablePersonneCourant).append("]").append("(callto:").append(portablePersonneCourant).append(")").toUtf8());
                }

                else
                {
                    pandoc->write(QString("[").append(portablePersonneCourant).append("]").append("(callto:").append(portablePersonneCourant).append(")").toUtf8());
                }
            }

            if (emailPersonneCourant != "")
            {
                if (domicilePersonneCourant != "" || portablePersonneCourant != "")
                {
                    pandoc->write(QString(" — ").append(QString("[")).append(emailPersonneCourant).append("]").append("(callto:").append(emailPersonneCourant).append(")").toUtf8());
                }

                else
                {
                    pandoc->write(QString("[").append(emailPersonneCourant).append("]").append("(callto:").append(emailPersonneCourant).append(")").toUtf8());
                }
            }
            pandoc->write("\n\n");

            estRentreDansLaBoucle = true;
            pandoc->write("Poste|Tour\n");
            pandoc->write("---|---\n");
        }



        pandoc->write(postePersonneCourant.toUtf8());
        pandoc->write("|");

        if (query.record().value("debut_tour").toDateTime().toString("d/MM") != "")
        {
            pandoc->write("Le ");
            pandoc->write(query.record().value("debut_tour").toDateTime().toString("d/MM").toUtf8());
            pandoc->write(" ");
            pandoc->write(debutTourPersonneCourant.toUtf8());
            pandoc->write("→");
            pandoc->write(finTourPersonneCourant.toUtf8());

        }

        else
            pandoc->write(" ");

        pandoc->write("\n");


    }

    if (estRentreDansLaBoucle)
    {
        // Laisser de la place dans le dernier tableau
        pandoc->write(" ");
        pandoc->write("|");
        pandoc->write(" ");
        pandoc->write("\n");

        pandoc->write(" ");
        pandoc->write("|");
        pandoc->write(" ");
        pandoc->write("\n");

        pandoc->write(" ");
        pandoc->write("|");
        pandoc->write(" ");
        pandoc->write("\n");
        // -----------------
    }

    // Deuxieme requete //
    QSqlQuery query2;
    query2.prepare("select * from export_general_tours where id_evenement= :evt");
    query2.bindValue(":evt",idEvenement());
    query2.exec();

    // Initilisation //

    QString jourRequeteCourant = QString("-1");
    QString jourRequetePrecedent = QString("0");

    QString posteRequeteCourant = QString("0");
    //QString posteRequetePrecedent = QString("-1");

    int idTourCourant=-1;
    int idTourPrecedent=-2;
    QString debutTourCourant;
    QString finTourCourant;
    QString mailPersonneCourant;

    // TRAITEMENT //
    pandoc->write("\n");
    pandoc->write("\n");
    faireUnRetourALaLigne(pandoc);
    pandoc->write("\n");
    pandoc->write("#");
    pandoc->write("                         Tours \n\n");
    while (query2.next())
    {
        jourRequeteCourant = query2.record().value("debut_tour").toDateTime().toString("dddd d MMMM yyyy");
        if (jourRequeteCourant != jourRequetePrecedent)
        {
            jourRequetePrecedent = jourRequeteCourant;
            pandoc->write("\n");
            pandoc->write("\n");
            pandoc->write("#");
            pandoc->write("  Le ");
            pandoc->write(jourRequeteCourant.toUtf8());
            pandoc->write("\n");
        }
        idTourCourant = query2.record().value("id_tour").toInt();
        if (idTourCourant != idTourPrecedent)
        {
            idTourPrecedent = idTourCourant;
            posteRequeteCourant = query2.record().value("nom_poste").toString();
            debutTourCourant = query2.record().value("debut_tour").toDateTime().toString("H:mm");
            finTourCourant = query2.record().value("fin_tour").toDateTime().toString("H:mm");

            pandoc->write("\n");
            pandoc->write("\n");
            pandoc->write("###");
            pandoc->write("       ");
            pandoc->write(posteRequeteCourant.toUtf8());
            pandoc->write(" ");
            pandoc->write(debutTourCourant.toUtf8());
            pandoc->write("→");
            pandoc->write(finTourCourant.toUtf8());
            pandoc->write("\n");
            pandoc->write("\n");
            //pandoc->write("Nom|Prenom|Domicile|Portable|Mail|Age\n");
            //pandoc->write("---|---|---|---|---|---\n");
        }

        nomPersonneCourant = query2.record().value("nom_personne").toString(); // Initialisé dans le premier etat
        prenomPersonneCourant = query2.record().value("prenom_personne").toString(); // Initialisé dans le premier etat
        domicilePersonneCourant = query2.record().value("domicile").toString(); // Initialisé dans le premier etat
        portablePersonneCourant = query2.record().value("portable").toString(); // Initialisé dans le premier etat
        mailPersonneCourant = query2.record().value("email").toString();
        int agePersonneCourant = -1;

        if (!query2.record().value("date_naissance").toDate().isNull())
            agePersonneCourant = age(query2.record().value("date_naissance").toDate(),query2.record().value("debut_evenement").toDate());

        faireUnRetourALaLigne(pandoc);

        pandoc->write("  ●");
        pandoc->write(nomPersonneCourant.toUtf8());

        if (prenomPersonneCourant != "")
            pandoc->write(QString(" ").append(prenomPersonneCourant).toUtf8());

        if (domicilePersonneCourant != "")
            pandoc->write(QString(" — ").append(QString("[")).append(domicilePersonneCourant).append("]").append("(callto:").append(domicilePersonneCourant).append(")").toUtf8());

        if (portablePersonneCourant != "")
            pandoc->write(QString(" — ").append(QString("[")).append(portablePersonneCourant).append("]").append("(callto:").append(portablePersonneCourant).append(")").toUtf8());

        if (mailPersonneCourant != "")
            pandoc->write(QString(" — ").append(QString("[")).append(mailPersonneCourant).append("]").append("(mailto:").append(mailPersonneCourant).append(")").toUtf8());


        if (agePersonneCourant != -1)
            pandoc->write(QString(" — ").append(QString().setNum(agePersonneCourant).append(" ans")).toUtf8());
        else
            pandoc->write(" ");
        pandoc->write("\n");
    }

    terminerGenerationEtat(pandoc,f);
}

int GestionnaireDAffectations::age(QDate dateDeNaissance,QDate dateRepere)
{
    bool avant;

    if (dateRepere.month() > dateDeNaissance.month())
    {
        avant = true;
    }
    else if (dateRepere.month() < dateDeNaissance.month())
    {
        avant = false;
    }
    else if(dateRepere.month() == dateDeNaissance.month())
    {
        if (dateRepere.day() >= dateDeNaissance.day())
        {
            avant = true;
        }
        else if (dateRepere.day() < dateDeNaissance.day())
            avant = false;
    }
    int ageCourant = dateRepere.year() - dateDeNaissance.year();
    (avant?ageCourant=ageCourant:ageCourant--);

    return ageCourant;
}

void GestionnaireDAffectations::faireUnRetourALaLigne(QProcess* unPandoc)
{
    unPandoc->write(" \n\n ");
}

void GestionnaireDAffectations::afficherEntete(QProcess* unPandoc, QSqlQuery uneQuery)
{
    if (uneQuery.next())
    {
        unPandoc->write("#");
        unPandoc->write(uneQuery.record().value("nom_evenement").toString().toUtf8());
        unPandoc->write(" — ");

        unPandoc->write(uneQuery.record().value("lieu_evenement").toString().toUtf8());
        unPandoc->write("\n\n");

        unPandoc->write("###");
        unPandoc->write("Du ");

        if (uneQuery.record().value("debut_evenement").toDateTime().toString("d") == "1")
        {
            unPandoc->write(uneQuery.record().value("debut_evenement").toDateTime().toString("d").toUtf8());
            unPandoc->write("er ");
            unPandoc->write(uneQuery.record().value("debut_evenement").toDateTime().toString("MMMM yyyy").toUtf8());
        }

        else
        {
            unPandoc->write(uneQuery.record().value("debut_evenement").toDateTime().toString("d MMMM yyyy").toUtf8());
        }


        unPandoc->write(" au ");


        if (uneQuery.record().value("fin_evenement").toDateTime().toString("d") == "1") // Si la date est le "1" alors on suffixe par "-er"
        {
            unPandoc->write(uneQuery.record().value("fin_evenement").toDateTime().toString("d").toUtf8());
            unPandoc->write("er ");
            unPandoc->write(uneQuery.record().value("fin_evenement").toDateTime().toString("MMMM yyyy").toUtf8());

        }

        else
        {
            unPandoc->write(uneQuery.record().value("fin_evenement").toDateTime().toString("d MMMM yyyy").toUtf8());
        }

        unPandoc->write("\n\n");
    }
}

bool GestionnaireDAffectations::terminerGenerationEtat(QProcess* unPandoc, QTemporaryFile* unFichier)
{
    unPandoc->closeWriteChannel();
    unPandoc->waitForFinished();

    qDebug() << unPandoc->readAll();

    QProcess* lowriter = new QProcess(this);
    lowriter->start("lowriter", QStringList() << unFichier->fileName());
    lowriter->waitForFinished();

    qDebug() << lowriter->readAll();

    return true;
}
