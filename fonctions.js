var indexMemoire = "-1"; // Permet de connaitre le n° du candidat selectionné, vaut -1 par defaut ( personne n'est selectionné )
var component;
var sprite;
var numeroMarqueur = 0;
var bulleClique = false;
var jourPrecedent= 0;
var moisPrecedent = 0;
var anneePrecedente = 0;

var jourPrecedentEmploiDuTemps = 0;

function dateBarreStatut(dateRecu) {
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


function dateFR(dateRecu) {
    if(dateRecu == "") return "" // Bug courant, permet de patcher les warnings qui s'affolent dans la console

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



    return dateRecu.getDate()+"/"+numeroMois+"/"+dateRecu.getFullYear()+" "+heure+":"+minutes;

}

function dateTour(debut,fin) {

    var minutesDebut;
    var minutesFin;
    var heureDebut;
    var heureFin;

    var nomMois = [
        "Janvier", "Fevrier", "Mars",
        "Avril", "Mai", "Juin", "Juillet",
        "Aout", "Septembre", "Octobre",
        "Novembre", "Decembre"
    ];

    var numeroJourDebut = debut.getDate();
    var numeroMoisDebut = debut.getMonth();
    var numeroAnneeDebut = debut.getFullYear();

    var numeroJourFin = fin.getDate();
    var numeroMoisFin = fin.getMonth();
    var numeroAnneeFin = fin.getFullYear();


    if(debut.getHours() < 10) heureDebut = "0"+debut.getHours();
    else heureDebut = debut.getHours();
    if(debut.getMinutes() < 10) minutesDebut = "0"+debut.getMinutes();
    else minutesDebut = debut.getMinutes();

    if(fin.getHours() < 10) heureFin = "0"+fin.getHours();
    else heureFin = fin.getHours();
    if(fin.getMinutes() < 10) minutesFin = "0"+fin.getMinutes();
    else minutesFin = fin.getMinutes();



    if( (numeroJourDebut == numeroJourFin || (numeroJourDebut==numeroJourFin+1 && heureDebut > heureFin )) && numeroMoisDebut == numeroMoisFin && numeroAnneeDebut == numeroAnneeFin)
    {
        if( (anneePrecedente != 0 && jourPrecedent != 0 && moisPrecedent != 0) && (numeroJourDebut==jourPrecedent && moisPrecedent==numeroMoisDebut && anneePrecedente==numeroAnneeDebut))
        {
                return "\t  \t" + heureDebut+"h"+minutesDebut+ " à "+heureFin+"h"+minutesFin+ " \t ";
        }
         else   {
            anneePrecedente = numeroAnneeDebut;
            moisPrecedent = numeroMoisDebut;
            jourPrecedent = numeroJourDebut;
            return "Le "+numeroJourDebut+" "+nomMois[numeroMoisDebut]+ " " + numeroAnneeDebut +" de " + "\t" + heureDebut+"h"+minutesDebut+ " à "+heureFin+"h"+minutesFin+ " \t ";
        }
    }
    else
    {
        return "Du "+numeroJourDebut+" "+nomMois[numeroMoisDebut]+ " " + numeroAnneeDebut +" " + heureDebut+"h"+minutesDebut+ " au  "+ numeroJourFin+" "+nomMois[numeroMoisFin]+ " " + numeroAnneeFin +" "  +heureFin+"h"+minutesFin+ " ";
    }



}

function dateEmploiDuTemps(date) {

    var heure;
    var minutes;
    var nomJour = [
        "Lundi", "Mardi", "Mercredi",
        "Jeudi", "Vendredi", "Samedi", "Dimanche"
    ];

    if(date.getHours() < 10) heure = "0"+date.getHours(); // pour afficher 07h00 au lieu de 7h00
    else heure = date.getHours();
    if(date.getMinutes() < 10) minutes = "0"+date.getMinutes(); // pour afficher 07h05 au lieu de 07h5
    else minutes = date.getMinutes();

    if(jourPrecedentEmploiDuTemps == date.getDate() )
    {
        console.log("Courant: " + jourPrecedentEmploiDuTemps+" "+heure+"h"+minutes )
        jourPrecedentEmploiDuTemps = date.getDate();
        return "\t "+heure+"h"+minutes;
    }
    else
    {
        console.log(jourPrecedentEmploiDuTemps+"!="+date.getDate())
        jourPrecedentEmploiDuTemps = date.getDate()
        return nomJour[date.getDay()]+" "+date.getDate()+ "/"+ (date.getMonth()+1);
    }


}

function nomJourEtDate (date)
{

    var nomJour = [
        "Lundi", "Mardi", "Mercredi",
        "Jeudi", "Vendredi", "Samedi", "Dimanche"
    ];

        return nomJour[date.getDay()]+" "+date.getDate()+ "/"+ (date.getMonth()+1);

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

function heureMinutes(dateRecu) {
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

function afficherFenetreAjouterTour(champ, valeur,idtour,h,m) {
    var component = Qt.createComponent("CalendrierTour.qml")
    if( component.status !== Component.Ready )
    {
        if( component.status === Component.Error )
            console.debug("Error:"+ component.errorString() );
        return;
    }
    var window = component.createObject(gestionDesAffectations, {"champ":champ, "valeur": valeur, "idtour": idtour, "heureRecu":h,"minutesRecu":m })
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

