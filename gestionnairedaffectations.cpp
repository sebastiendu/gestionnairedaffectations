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

    QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL");
    // TODO: lire ces valeurs dans les Settings
    db.setHostName("bdd.ldd.fr");
    db.setDatabaseName("laguntzaile");
    db.setUserName("bastien");
    db.setPassword("bastien");
    if (!db.open()) {
        // TODO : proposer un écran de paramétrage pour mettre à jour les Settings
        qDebug() << "Impossible d'ouvrir la connexion à la base :" << db.lastError().text();
        exit(1);
    }

    QSqlQuery query;

    query.prepare("select * from liste_des_evenements"); // On séléctionne la liste des évenements
    query.exec();
    m_liste_des_evenements = new SqlQueryModel;
    m_liste_des_evenements->setQuery(query);

    query.prepare("select * from poste where id_evenement=? order by nom ");
    query.addBindValue(idEvenement());
    query.exec();
    m_postes = new SqlQueryModel;
    m_postes->setQuery(query);

    QQmlEngine engine;
    QQmlComponent component(&engine, QUrl::fromLocalFile("marqueur.qml"));


    QSqlQueryModel model;
    model.setQuery(query);
    for(int i=0;i<model.rowCount();i++)
    {
            qDebug() << model.data(model.index(i, 0)).toInt();
           // component.create(); Ne veut pas se créer ...
            //emit placerMarqueur(10,10);
    }


    query.prepare("select * from benevoles_disponibles where id_evenement=?");
    query.addBindValue(idEvenement());
    query.exec();
    m_benevoles_disponibles_sql = new SqlQueryModel;
    m_benevoles_disponibles_sql->setQuery(query);
    m_benevoles_disponibles = new QSortFilterProxyModel(this);
    m_benevoles_disponibles->setSourceModel(m_benevoles_disponibles_sql);
    m_benevoles_disponibles->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_benevoles_disponibles->setFilterKeyColumn(-1);

    m_id_disponibilite=0;
    query.prepare("select * from fiche_benevole where id_disponibilite=?");
    query.addBindValue(m_id_disponibilite);
    query.exec();
    m_fiche_benevole = new SqlQueryModel;
    m_fiche_benevole->setQuery(query);

    m_id_poste=0;
    query.prepare("select * from poste_et_tour where id_poste= :poste "); //AND debut <= :debut AND fin >= :fin"
    query.bindValue(":poste",m_id_poste);
  //  query.bindValue(":debut",m_heure.toString("yyyy-MM-d h:m:s"));
  //  query.bindValue(":fin",m_heure.toString("yyyy-MM-d h:m:s"));
  //  qDebug() << m_heure.toString("Yyyy-MM-d h:m:s");
  //  qDebug() << m_heure.toString();
  //  qDebug() << m_heure;
    query.exec();
    m_fiche_poste = new SqlQueryModel;
    m_fiche_poste->setQuery(query);
    // format: 2014-11-16 08:00:00+01
    m_settings = new Settings;

    Plan monPlan;
}

GestionnaireDAffectations::~GestionnaireDAffectations()
{
    QSqlDatabase().close();
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
    query.bindValue(0, m_id_poste);
    query.exec();
    m_fiche_poste->setQuery(query);
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
