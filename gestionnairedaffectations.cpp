#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>
#include <QtQml>
#include <QtDebug>
#include <QQuickView>
#include "gestionnairedaffectations.h"
#include <map>
#include "poste.h"
#include <plan.h>


GestionnaireDAffectations::GestionnaireDAffectations(int & argc, char ** argv):
    QGuiApplication(argc,argv)
{
    QCoreApplication::setOrganizationName("Les Développements Durables");
    QCoreApplication::setOrganizationDomain("ldd.fr");
    QCoreApplication::setApplicationName("Laguntzaile");

    qmlRegisterType<Settings>("fr.ldd.qml", 1, 0, "Settings");
    qmlRegisterType<SqlQueryModel>("fr.ldd.qml", 1, 0, "SqlQueryModel");
    qmlRegisterType<QSortFilterProxyModel>("fr.ldd.qml", 1, 0, "QSortFilterProxyModel");
    qmlRegisterType<Plan>("fr.ldd.qml", 1, 0, "Plan");

    m_settings = new Settings;

    m_id_disponibilite=0;
    m_id_poste=0;

    m_liste_des_evenements = new SqlQueryModel;
    m_postes = new SqlQueryModel;
    m_tour_benevole = new SqlQueryModel;
    m_benevoles_disponibles_sql = new SqlQueryModel;
    m_benevoles_disponibles = new QSortFilterProxyModel(this);
    m_fiche_benevole = new SqlQueryModel;
    m_fiche_poste = new SqlQueryModel;
    m_plan = new QSortFilterProxyModel(this);

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
}

GestionnaireDAffectations::~GestionnaireDAffectations()
{
    QSqlDatabase().close();
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

        query.prepare("select * from liste_des_evenements");
        query.exec();
        m_liste_des_evenements->setQuery(query);

        query.prepare("select * from poste where id_evenement=? order by nom ");
        query.addBindValue(idEvenement());
        query.exec();
        m_postes->setQuery(query);

        query.prepare("select * from benevoles_disponibles where id_evenement=?");
        query.addBindValue(idEvenement());
        query.exec();
        m_benevoles_disponibles_sql->setQuery(query);
        m_benevoles_disponibles->setSourceModel(m_benevoles_disponibles_sql);
        m_benevoles_disponibles->setFilterCaseSensitivity(Qt::CaseInsensitive);
        m_benevoles_disponibles->setFilterKeyColumn(-1);

        query.prepare("select * from fiche_benevole where id_disponibilite=?");
        query.addBindValue(m_id_disponibilite);
        query.exec();
        m_fiche_benevole->setQuery(query);

        query.prepare("select * from poste_et_tour where id_poste= :poste AND debut <= :debut AND fin >= :fin ORDER BY debut ASC"); //AND debut <= :debut AND fin >= :fin"
        query.bindValue(":poste",m_id_poste);
        query.bindValue(":debut",m_heure.toString("yyyy-MM-d h:m:s"));
        query.bindValue(":fin",m_heure.toString("yyyy-MM-d h:m:s"));

        query.exec();
        m_fiche_poste->setQuery(query);

        query.prepare("select * from affectations where id_tour= :tour AND id_evenement = :id_evenement; ");
        query.bindValue(":tour",m_id_tour);
        query.bindValue(":id_evenement",idEvenement());
        query.exec();
        m_tour_benevole->setQuery(query);


    } else {
        qDebug() << "Impossible d'ouvrir la connexion à la base :" << db.lastError().text();
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
}

void GestionnaireDAffectations::setIdEvenementFromModelIndex(int index) {
    this->setIdEvenement(m_liste_des_evenements->getIdFromIndex(index));

    QSqlQuery query = m_benevoles_disponibles_sql->query(); // On fait un select des bénévoles participant à un événement avec un id précis
    query.bindValue(0,idEvenement()); // Cet id correspond à l'id evenement
    query.exec(); // On execute la requette
    m_benevoles_disponibles_sql->setQuery(query); // On remplace la requete ayant un id indéfini par une requete avec un id précis (idEvenement)

    query = m_postes->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_postes->setQuery(query);

    query = m_fiche_benevole->query();
    query.bindValue(0,0);
    query.exec();
    m_fiche_benevole->setQuery(query);

    query = m_fiche_poste->query();
    query.bindValue(0,0);
    query.exec();
    m_fiche_poste->setQuery(query);

    query = m_tour_benevole->query();
    query.bindValue(0,0);
    query.exec();
    m_tour_benevole->setQuery(query);


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
    query.bindValue(":debut",m_heure.toString("yyyy-MM-d h:m:s"));
    query.bindValue(":fin",m_heure.toString("yyyy-MM-d h:m:s"));
    query.exec();
    m_fiche_poste->setQuery(query);
}

void GestionnaireDAffectations::setIdTour(int id) {
    m_id_tour = id;
    QSqlQuery query = m_tour_benevole->query();
    query.bindValue(":tour", m_id_tour);
    query.exec();
    m_tour_benevole->setQuery(query);
    qDebug() << "Id du tour changé en " << id;
}

void GestionnaireDAffectations::setIdDisponibilite(int id) { // A quoi sert cette fonction ?
    m_id_disponibilite = id;
    QSqlQuery query = m_fiche_benevole->query(); //On demande la fiche d'un bénévole ayant un id precis
    query.bindValue(0, m_id_disponibilite); // Cet id correspond à l'id passé en parametre
    query.exec();
    m_fiche_benevole->setQuery(query);
}

void GestionnaireDAffectations::enregistrerNouvelEvenement(QString nom, QDateTime debut, QDateTime fin, QString lieu, int id_evenement_precedent) {
    QSqlQuery query;
    query.prepare("insert into evenement (nom, debut, fin, lieu, id_evenement_precedent) values (?,?,?,?,?)");
    query.addBindValue(nom);
    query.addBindValue(debut);
    query.addBindValue(fin);
    query.addBindValue(lieu);
    query.addBindValue(id_evenement_precedent);
    if (query.exec()) {
        setIdEvenement(query.lastInsertId().toInt());
    }
}

void GestionnaireDAffectations::selectionnerMarqueur() {

}

void GestionnaireDAffectations::ajouterUnPoste(Poste p){
    int dernierID = this->listeDePoste.rbegin()->first;
    this->listeDePoste.insert(std::pair<int,Poste>(dernierID+1,p));
}

void GestionnaireDAffectations::supprimerUnPoste(int p){
    this->listeDePoste.erase(p);
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

    qDebug() << "Nombre de colonne dans plan:" << m_plan->rowCount();
    qDebug() << m_plan->index(1,1);

    /*query.prepare("select * from poste_et_tour where id_poste= :poste AND debut <= :debut AND fin >= :fin;");
    query.bindValue(":poste",m_id_poste);
    query.bindValue(":debut",m_heure.toString("yyyy-MM-d h:m:s"));
    query.bindValue(":fin",m_heure.toString("yyyy-MM-d h:m:s"));
    query.exec();
    m_fiche_poste = new SqlQueryModel;
    m_fiche_poste->setQuery(query); */

    qDebug() << "La date:" << m_heure.toString("yyyy-MM-d h:m:s");
    qDebug() << "Nombre de postes à ce moment: " << m_postes->rowCount();
}

/* void GestionnaireDAffectations::faireInscription(int p){
    QSqlQuery query;
    query.prepare("insert into evenement (nom, debut, fin, lieu, id_evenement_precedent) values (?,?,?,?,?)");
    query.addBindValue(nom);
    query.addBindValue(debut);
    query.addBindValue(fin);
    query.addBindValue(lieu);
    query.addBindValue(id_evenement_precedent);
    if (query.exec()) {
        setIdEvenement(query.lastInsertId().toInt());
    }
}
*/

void GestionnaireDAffectations::genererFichesDePostes()
{
    QSqlQuery query;
    query.prepare("select * from fiche_de_poste_benevoles_par_tour where id_evenement= :evt");
    query.bindValue(":evt",idEvenement());
    query.exec();

    /* Création d'un fichier temporaire
        // Génération d'un nom aléatoire
        char *monFichier;
        char nom[] = "lOlIlOlXXXXXX";
        monFichier = mktemp(nom);

        // Création du fichier
        ofstream monFichierTemporaire;
        monFichierTemporaire.open(monFichier,ios::out);
        if (!monFichierTemporaire.bad())
        {
            monFichierTemporaire << " contenu " ;
            monFichierTemporaire.close();
        } */
    QProcess* pandoc = new QProcess(this);
    pandoc->setProgram("pandoc");
    QStringList arguments;
    arguments << "-f" << "markdown" << "-t" << "odt" << "-o" << "/tmp/resultat.odt" << "-";
    pandoc->setArguments(arguments);
    pandoc->start();
    pandoc->waitForStarted();

    // PARCOUR DE LA REQUETE
    // Initialisation
    int id_poste = -1;
    int id_tour = -1;

    // Affichage des résultats en HTML
    query.next();
    qDebug () << query.record().value("nom_evenement").toString();

    pandoc->write("\n# Evenement : ");
    pandoc->write(query.record().value("nom_evenement").toString().toUtf8());
    pandoc->write("\n\n");

    while (query.next())
    {
        if (query.record().value("id_poste").toInt() != id_poste)
        {
            id_poste = query.record().value("id_poste").toInt();

            pandoc->write("\n -------- \n");
            pandoc->write("\n\n## Poste : ");
            pandoc->write(query.record().value("nom_poste").toString().toUtf8());
            pandoc->write("\n\n");
        }

        if (query.record().value("id_tour").toInt() != id_tour)
        {
            id_tour = query.record().value("id_tour").toInt();


            if (query.record().value("debut_tour").toDateTime().toString("d") == query.record().value("fin_tour").toDateTime().toString("d"))
            {
                pandoc->write("\n\n### Tour : Le ");
                pandoc->write(query.record().value("debut_tour").toDateTime().toString("d/MM/yyyy").toUtf8());
                pandoc->write(" de ");
                pandoc->write(query.record().value("debut_tour").toDateTime().toString("H:mm").toUtf8());
                pandoc->write(" à ");
                pandoc->write(query.record().value("fin_tour").toDateTime().toString("H:mm").toUtf8());
                pandoc->write("\n\n");
            }
            else
            {
                pandoc->write("\n\n### Tour : Du ");
                pandoc->write(query.record().value("debut_tour").toDateTime().toString("d/MM/yyyy H:mm").toUtf8());
                pandoc->write(" au ");
                pandoc->write(query.record().value("fin_tour").toDateTime().toString("d/MM/yyyy H:mm").toUtf8());
                pandoc->write("\n\n");
            }
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
    lowriter->start("lowriter", QStringList() << "/tmp/resultat.odt");
    lowriter->waitForFinished();

    qDebug() << lowriter->readAll();

}

