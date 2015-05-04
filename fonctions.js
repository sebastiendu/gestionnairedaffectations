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

function focusCandidat(index)
{
    if(indexMemoire != index)
    {
        cadreCandidat.color = "blue"
        indexMemoire = index;
    }

}

function genererMail()
{

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

function createSpriteObjects(rect,x,y) {
    component = Qt.createComponent("marqueur.qml");
    if (component.status == Component.Ready)
        finishCreation(rect,x,y);
    else
        component.statusChanged.connect(finishCreation);
}
function finishCreation(rect,x,y) {
    if (component.status == Component.Ready) {
        numeroMarqueur++;


        if(x - ((22/640) * rect.width) > 0) x-= ((22/640) * rect.width); // Pour centrer parfaitement le marqueur sur le curseur
        if(y - ((22/640) * rect.height) > 0) y-= ((22/640) * rect.height);


        var ratioX = x / rect.width;
        var ratioY = y / rect.height;

        console.log(ratioX);
        console.log(ratioY);

        sprite = component.createObject(rect, {"ratioX": ratioX, "ratioY": ratioY,"id":numeroMarqueur});

        if (sprite == null) {
            // Error Handling
            console.log("Error creating object");
        }
    } else if (component.status == Component.Error) {
        // Error Handling
        console.log("Error loading component:", component.errorString());
    }
}


function calculerHauteurBulle(h)
{
    console.log("h: "+ h)
    return h*2;
}

function min(a,b){
    if(a<b) return a;
    else return b;
}

function max(a,b){
    if(a>b) return a;
    else return b;
}

function resizePointeur() {

}

function afficherMessage(message){
    console.log(message);
}
