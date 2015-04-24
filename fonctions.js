var indexMemoire = "-1"; // Permet de connaitre le n° du candidat selectionné, vaut -1 par defaut ( personne n'est selectionné )
var component;
var sprite;
var numeroMarqueur = 0;

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

function createSpriteObjectsPlan(x,y) {
    component = Qt.createComponent("marqueur.qml");
    if (component.status == Component.Ready)
        finishCreationPlan(x,y);
    else
        component.statusChanged.connect(finishCreation);
}
function finishCreationPlan(x,y) {
    if (component.status == Component.Ready) {
        numeroMarqueur++;
        sprite = component.createObject(plan, {"x": x, "y": y,"id":numeroMarqueur});
        console.log(sprite.id)
        if (sprite == null) {
            // Error Handling
            console.log("Error creating object");
        }
    } else if (component.status == Component.Error) {
        // Error Handling
        console.log("Error loading component:", component.errorString());
    }
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
        sprite = component.createObject(rect, {"x": x, "y": y,"id":numeroMarqueur});
        console.log(sprite.id)
        if (sprite == null) {
            // Error Handling
            console.log("Error creating object");
        }
    } else if (component.status == Component.Error) {
        // Error Handling
        console.log("Error loading component:", component.errorString());
    }
}

function resizePointeur() {

}

function afficherMessage(message){
    console.log(message);
}
