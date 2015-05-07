#include <QSqlQuery>
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
    m_affectations = new SqlQueryModel;
    m_fiche_poste = new SqlQueryModel;
    m_fiche_poste_tour = new SqlQueryModel;
    m_poste_et_tour_sql = new SqlQueryModel;
    m_poste_et_tour = new QSortFilterProxyModel(this);
    m_planComplet = new SqlQueryModel;
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

        query.prepare("select * from poste_et_tour where id_poste= :poste ;");
        query.bindValue(":poste",m_id_poste);
        query.exec();
        m_fiche_poste_tour->setQuery(query);

        query.prepare("select * from affectations where id_tour= :tour AND id_evenement = :id_evenement; ");
        query.bindValue(":tour",m_id_tour);
        query.bindValue(":id_evenement",idEvenement());
        query.exec();
        m_tour_benevole->setQuery(query);

        query.prepare("select * from affectations where id_tour= :tour AND id_evenement = :id_evenement; ");
        query.bindValue(":tour",m_id_tour);
        query.bindValue(":id_evenement",idEvenement());
        query.exec();
        m_affectations->setQuery(query);

        query.prepare("select * from poste where id_evenement= :evt;");
        query.bindValue(":id_evenement",idEvenement());
        query.exec();
        m_planComplet->setQuery(query);

        query.prepare("select * from poste_et_tour where id_evenement= :evt ORDER BY nom, debut ASC;");
        query.bindValue(":id_evenement",idEvenement());
        query.exec();
        m_poste_et_tour_sql->setQuery(query);
        m_poste_et_tour->setSourceModel(m_poste_et_tour_sql);
        m_poste_et_tour->setFilterCaseSensitivity(Qt::CaseInsensitive);
        m_poste_et_tour->setFilterKeyColumn(-1);


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

    query = m_affectations->query();
    query.bindValue(0,0);
    query.exec();
    m_affectations->setQuery(query);

    query = m_planComplet->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_planComplet->setQuery(query);

    query = m_poste_et_tour_sql->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_poste_et_tour_sql->setQuery(query);

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

void GestionnaireDAffectations::setIdPosteTour(int id) {
    QSqlQuery query = m_fiche_poste_tour->query();
    query.bindValue(":poste", id);
    query.exec();
    m_fiche_poste_tour->setQuery(query);
}


void GestionnaireDAffectations::setIdTour(int id) {
    m_id_tour = id;
    QSqlQuery query = m_tour_benevole->query();
    query.bindValue(":tour", m_id_tour);
    query.exec();
    m_tour_benevole->setQuery(query);
    qDebug() << "Id du tour changé en " << id;
}

void GestionnaireDAffectations::setIdAffectation(int id) {
    m_id_affectation = id;
    QSqlQuery query = m_affectations->query();
    query.bindValue(":tour", id);
    query.exec();
    m_affectations->setQuery(query);
    qDebug() << "setIdAffectation: " << id;
}


void GestionnaireDAffectations::setIdDisponibilite(int id) {
    m_id_disponibilite = id;
    QSqlQuery query = m_fiche_benevole->query(); //On demande la fiche d'un bénévole ayant un id precis
    query.bindValue(0, m_id_disponibilite); // Cet id correspond à l'id passé en parametre
    query.exec();
    m_fiche_benevole->setQuery(query);
    qDebug() << "setIdDisponibilite: " << id;
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

    qDebug() << "La date:" << m_heure.toString("yyyy-MM-d h:m:s");
    qDebug() << "Nombre de postes à ce moment: " << m_postes->rowCount();
}

void GestionnaireDAffectations::insererPoste(QString poste, QString description, float posx, float posy) {
    QSqlQuery query;
    query.prepare("INSERT INTO poste (id_evenement,nom,description,posx,posy) VALUES (:id_evenement, :poste, :description, :posx, :posy);");
    query.bindValue(":id_evenement",idEvenement());
    query.bindValue(":poste",poste);
    query.bindValue(":description",description);
    query.bindValue(":posx",posx);
    query.bindValue(":posy",posy);
    query.exec();
    qDebug() << query.lastError().text();

    query = m_planComplet->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_planComplet->setQuery(query);

    planCompletChanged();
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


        // A SUPPRIMER UNE FOIS DEBUGGER
        query = m_planComplet->query(); // <
        query.bindValue(0,idEvenement()); // <
        query.exec(); // <
        m_planComplet->setQuery(query); // <
        planCompletChanged(); // <
    }

}


void GestionnaireDAffectations::supprimerPoste(int id){

    QSqlQuery query;

    query.prepare("DELETE FROM poste WHERE id = :id;");
    query.bindValue(":id",id);
    query.exec();
    qDebug() << query.lastError().text(); // Si erreur, on l'affiche dans la console

    query = m_planComplet->query();
    query.bindValue(0,idEvenement());
    query.exec();
    m_planComplet->setQuery(query);

    planCompletChanged();
}

void GestionnaireDAffectations::desaffecterBenevole(){

    QSqlQuery query;
    qDebug() << "1";
    query.prepare("DELETE FROM affectation WHERE id_disponibilite = :id_disponibilite;");
    qDebug() << "2";
    query.bindValue(":id_disponibilite",m_id_disponibilite);
    query.exec();
    qDebug() << "3";
    qDebug() << query.lastError().text(); // Si erreur, on l'affiche dans la console

    query = m_affectations->query();
    qDebug() << "4";
    query.bindValue(":tour",m_id_affectation);
    query.bindValue(":id_evenement",idEvenement());
    query.exec();
    qDebug() << "5";
    m_affectations->setQuery(query);
    qDebug() << "6";

    query = m_poste_et_tour_sql->query();
    query.bindValue(":id_evenement",idEvenement());
    query.exec();

    m_poste_et_tour_sql->setQuery(query);
    m_poste_et_tour->setSourceModel(m_poste_et_tour_sql);
    m_poste_et_tour->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_poste_et_tour->setFilterKeyColumn(-1);

    qDebug() << "m_id_disponibilite: " + m_id_disponibilite;
    qDebug() << "m_id_tour: " + m_id_affectation;

}

void GestionnaireDAffectations::affecterBenevole(){

    QSqlQuery query;

    query.prepare("INSERT INTO affectation (id_disponibilite, id_tour,date_et_heure_proposee ,statut,commentaire) VALUES (:id_disponibilite, :id_tour, :date, :statut, :commentaire)");
    query.bindValue(":id_disponibilite",m_id_disponibilite);
    query.bindValue(":id_tour",m_id_affectation);
    query.bindValue(":date","2014-10-01 00:00:00");
    query.bindValue(":statut","proposee");
    query.bindValue(":commentaire","test");
    query.exec();

    qDebug() << "INSERT INTO affectation (id_disponibilite, id_tour,date_et_heure_proposee ,statut,commentaire) VALUES ("<< m_id_disponibilite << "," << m_id_affectation << ",'2014-10-01 00:00:00','proposee','test')";
    qDebug() << query.lastError().text();
    query = m_affectations->query();

    query.bindValue(":tour",m_id_affectation);
    query.bindValue(":id_evenement",idEvenement());
    query.exec();
    m_affectations->setQuery(query);

    query = m_poste_et_tour_sql->query();
    query.bindValue(":id_evenement",idEvenement());
    query.exec();

    m_poste_et_tour_sql->setQuery(query);
    m_poste_et_tour->setSourceModel(m_poste_et_tour_sql);
    m_poste_et_tour->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_poste_et_tour->setFilterKeyColumn(-1);
}

void GestionnaireDAffectations::modifierTourDebut(QDateTime debut, QDateTime ancienDebut) {

    QSqlQuery query;
    query.prepare("UPDATE tour SET debut = :debut WHERE id_poste = :poste AND debut = :anciendebut");
    query.bindValue(":poste",m_id_poste);
    query.bindValue(":debut",debut);
        query.bindValue(":anciendebut",ancienDebut);
    query.exec();
    qDebug() << query.lastError().text();

}

void GestionnaireDAffectations::modifierTourFin(QDateTime fin, QDateTime ancienFin) {

    QSqlQuery query;
    query.prepare("UPDATE tour SET fin = :fin WHERE id_poste = :poste AND fin= :ancienfin");
    query.bindValue(":poste",m_id_poste);
    query.bindValue(":fin",fin);
    query.bindValue(":ancienfin",ancienFin);

    query.exec();
    qDebug() << query.lastError().text();

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
