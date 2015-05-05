var indexMemoire = "-1"; // Permet de connaitre le n° du candidat selectionné, vaut -1 par defaut ( personne n'est selectionné )
var component;
var sprite;
var numeroMarqueur = 0;
var bulleClique = false;



function dateFR(dateRecu) {
    var heure;
    var minutes;
    var numeroMois = dateRecu.getMonth() + 1;

    // ==== On affiche l'heure correctement====//
    if(dateRecu.getHours() < 10)
        heure = "0"+dateRecu.getHours();
    else
        heure = dateRecu.getHours();

    // ==== On affiche les minutes correctement====//
    if(dateRecu.getMinutes() < 10)
        minutes = "0"+dateRecu.getMinutes();
    else
        minutes = dateRecu.getMinutes();



    return "Le "+dateRecu.getDate()+"/"+numeroMois+"/"+dateRecu.getFullYear()+" à "+heure+":"+minutes;

}

function afficherBulleInformative(rectangle,bulle,x,y)
{
    console.log ( "-----" );
    console.log(x);
    console.log(rectangle.x);
    console.log(rectangle.width);
    console.log(rectangle.width + rectangle.x)
    if((x + 45 + bulle.width) > (rectangle.x + rectangle.width)) bulle.x = ( x - bulle.width);
    else bulle.x = (x+45);

    bulle.y = y;
}

function datePourTours(dateRecu) {
    var heure;
    var minutes;
    var numeroMois = dateRecu.getMonth() + 1;

    // ==== On affiche l'heure correctement====//
    if(dateRecu.getHours() < 10)
        heure = "0"+dateRecu.getHours();
    else
        heure = dateRecu.getHours();

    // ==== On affiche les minutes correctement====//
    if(dateRecu.getMinutes() < 10)
        minutes = "0"+dateRecu.getMinutes();
    else
        minutes = dateRecu.getMinutes();



    return dateRecu.getDate()+"/"+numeroMois+"/"+dateRecu.getFullYear()+" "+heure+"h"+minutes;

}

function definirCouleurCercleNom (statut) {
    if(statut == "acceptee")
        return "green";
    else if(statut == "rejetee")
        return "red"
    else
        return "orange";
}

function couleurCercle(statut){
    if(statut == "acceptee")
        return "green";
    else if(statut == "rejetee")
        return "red"
    else
        return "orange";
}

function heure(dateRecu) {
    var heure;
    var minutes;


    // ==== On affiche l'heure correctement====//
    if(dateRecu.getHours() < 10)
        heure = "0"+dateRecu.getHours();
    else
        heure = dateRecu.getHours();

    // ==== On affiche les minutes correctement====//
    if(dateRecu.getMinutes() < 10)
        minutes = "0"+dateRecu.getMinutes();
    else
        minutes = dateRecu.getMinutes();



    return heure+"h"+minutes;

}



function afficherFenetreNouveauPoste() {
    var component = Qt.createComponent("nouveauPoste.qml")
    if( component.status !== Component.Ready )
    {
        if( component.status === Component.Error )
            console.debug("Error:"+ component.errorString() );
        return;
    }
    var window = component.createObject(gestionDesAffectations)
    window.show() // On ouvre la fenetre d'ajout du nouveau poste
}

function afficherFenetreSupprimerPoste() {
    var component = Qt.createComponent("supprimerPoste.qml")
    if( component.status !== Component.Ready )
    {
        if( component.status === Component.Error )
            console.debug("Error:"+ component.errorString() );
        return;
    }
    var window = component.createObject(gestionDesAffectations)
    window.open() // On ouvre la fenetre d'ajout du nouveau poste
}


function afficherFenetreAjouterTour(champ, valeur) {
    var component = Qt.createComponent("CalendrierTour.qml")
    if( component.status !== Component.Ready )
    {
        if( component.status === Component.Error )
            console.debug("Error:"+ component.errorString() );
        return;
    }
    var window = component.createObject(gestionDesAffectations, {"champ":champ, "valeur": valeur})
    window.show() // On ouvre la fenetre d'ajout du nouveau poste
}


function createSpriteObjects(rect,x,y) {
    component = Qt.createComponent("marqueur.qml");
    if (component.status == Component.Ready)
        finishCreation(rect,x,y);
    else
        component.statusChanged.connect(finishCreation);
}





function min(a,b){
    if(a<b) return a;
    else return b;
}

function max(a,b){
    if(a>b) return a;
    else return b;
}

