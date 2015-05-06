import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import fr.ldd.qml 1.0
import QtWebKit 3.0
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0

import "fonctions.js" as Fonctions

ApplicationWindow { // Fenetre principale
    id: gestionDesAffectations
    visible: true
    title: qsTr("Gestion des affectations")
    x: app.settings.value("x",50)
    y: app.settings.value("y",30)
    width: app.settings.value("width",850)
    height: app.settings.value("height",600)
    minimumWidth: 740
    minimumHeight: 500
    color: "#ffffff"


    Action {
        id: nouvelEvenement
        text: qsTr("&Nouveau")
        shortcut: StandardKey.New
        tooltip: "Déclarer un nouvel évènement"
        onTriggered: {
            var component = Qt.createComponent("nouvelevenement.qml")
            if( component.status !== Component.Ready )
            {
                if( component.status === Component.Error )
                    console.debug("Error:"+ component.errorString() );
                return;
            }
            var window = component.createObject(gestionDesAffectations)
            window.show() // On ouvre la fenetre d'ajout du nouvel évenement
        }
    }

    Action {
        id: parametresDeConnexion
        text: qsTr("Paramètres de connexion…")
        shortcut: StandardKey.Preferences
        tooltip: "Définir les paramètres de connexion à la base de données"
        onTriggered: {
            var component = Qt.createComponent("parametres_de_connexion.qml")
            if( component.status !== Component.Ready )
            {
                if( component.status === Component.Error )
                    console.debug("Error:"+ component.errorString() );
                return;
            }
            var window = component.createObject(gestionDesAffectations)
            window.show()
        }
    }

    onClosing: {
        app.settings.setValue("x", x)
        app.settings.setValue("y", y)
        app.settings.setValue("width", width)
        app.settings.setValue("height", height)
    }

    ComboBox { // Le menu déroulant permettant de sélectionner l'événement
        id: selecteurEvenement
        // height:50
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        model: app.liste_des_evenements // On charge la liste des évenement du menu déroulant
        currentIndex: app.getEvenementModelIndex() // Par defaut le menu déroulant est sur l'index courant
        textRole: "nom"
        onCurrentIndexChanged: {
            app.setIdEvenementFromModelIndex(currentIndex) // On appelle la fonction permettant entre autre de charger toutes les informations du nouvel évenement
        }

    }

    menuBar: MenuBar { // La barre de menu
        Menu {
            title: qsTr("&Évenement")
            MenuItem { action: nouvelEvenement }
            MenuItem {
                text: qsTr("Supprimer")
                onTriggered: console.log("TODO : Ouvrir l'interface de suppression de l'évènement");
            }
            MenuItem {
                text: qsTr("Quitter")
                onTriggered: Qt.quit();
            }
        }
        Menu {
            title: qsTr("&Edition")
        }
        Menu {
            title: qsTr("&Affichage")
        }

        Menu {
            title: qsTr("&Options")
            MenuItem { action: parametresDeConnexion }
        }


        Menu {
            title: qsTr("&Aide")
        }

        Menu {
            title: qsTr("&Générer Etat")
            MenuItem {
                text: qsTr("Fiche de postes / Bénévoles par tours")
                onTriggered: app.genererFichesDePostes()
            }
            MenuItem {
                text: qsTr("Carte de bénévole / Inscription postes")
                onTriggered: app.genererCarteBenevoles();
            }
            MenuItem {
                text: qsTr("Tableau de remplissage")
                onTriggered: app.genererTableauRemplissage();
            }
            MenuItem {
                text: qsTr("Fiches à problèmes")
                onTriggered: app.genererFichesProblemes();
            }
            MenuItem {
                text: qsTr("Export général")
                onTriggered: app.genererExportGeneral();
            }
        }

    }




    TabView { // Les differents onglets
        id: onglet
        anchors.top: selecteurEvenement.bottom
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom

        // height:parent.height
        Component.onCompleted: {
            addTab("Affectations", carte)
            addTab("Postes & Tours", postesEtTours)
            addTab("Candidature à valider", candidaturesAValider)
            addTab("Inscrire un bénévole", inscrireBenevole)
            addTab("Soumettre affectations", soumettreAffectations)
            addTab("Solliciter d'anciens bénévoles", solliciterAnciensBenevoles)
        }

        // =========================================================
        // ===================== ONGLET Affectations ======================
        // =========================================================

        Component {
            id: carte


            Rectangle {
                id: affectations
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.bottom: navigateurDeTemps.top
                anchors.bottomMargin: 0
                anchors.top: onglet.bottom
                anchors.topMargin: 0


                Rectangle {
                    id: disponibilites
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: navigateurDeTemps.top
                    anchors.bottomMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.right: plan.left
                    anchors.rightMargin: 0
                    z:1

                    TextField {
                        id: rechercheDeDisponibles
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        placeholderText: qsTr("Recherche d'une personne disponible")
                        onEditingFinished: app.benevoles_disponibles.setFilterFixedString(text);
                        // A la fin de l'édition (lorsque ENTREE est pressé) on charge la liste contenant seulement
                        // la chaine de caractère remplie
                    }

                    ListView {
                        id: listeDesDisponibles
                        anchors.bottom: parent.verticalCenter
                        anchors.top: rechercheDeDisponibles.bottom
                        anchors.margins: 5
                        anchors.right: parent.right
                        anchors.left: parent.left
                        clip: true
                        highlight:Rectangle { color: "lightsteelblue"; radius: 5 }
                        focus: true

                        delegate: Rectangle { // Corresponds au block contenant le nom... La  ListView contient donc plusieurs de ces blocks
                            height: 13
                            anchors.left: parent.left
                            anchors.right: parent.right
                            Text {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.horizontalCenter
                                text: prenom_personne + ' ' + nom_personne
                            }
                            Text {
                                anchors.top: parent.top
                                anchors.left: parent.horizontalCenter
                                anchors.right: parent.right
                                text: '<i>' + ville + '</i> ' + nombre_affectations + ' poste(s)'
                                horizontalAlignment: Text.Right
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    listeDesDisponibles.currentIndex = index
                                    app.setIdDisponibilite(id_disponibilite)
                                    //  Fonction à appeller lorsque une personne est cliquée
                                }
                            }
                        }
                        model: app.benevoles_disponibles
                    }



                    ScrollBar {
                        flickable: listeDesDisponibles;
                    }

                    ListView {
                        id: ficheBenevole
                        model: app.fiche_benevole
                        anchors.top: parent.verticalCenter
                        anchors.bottom: parent.bottom
                        anchors.margins: 5
                        anchors.right: parent.right
                        anchors.left: parent.left
                        clip:true

                        delegate: Column {
                            Text { text: 'Nom :\t' + nom }
                            Text { text: 'Prenom :\t' + prenom }
                            Text { text: 'Inscription :\t' + date_inscription.toLocaleDateString() }
                            Text { text: 'Amis :\t' + liste_amis }
                            Text { text: 'Type de poste :\t' + type_poste }
                            Text { text: 'Commentaire :\t' + commentaire_disponibilite }
                            Text { text: 'Statut :\t' + statut_disponibilite }
                            Text { text: 'Adresse :\t' + adresse }
                            Text { text: '\t' + code_postal + ' ' + ville}
                            Text { text: 'Contact :\t' + portable + " " + domicile }
                            Text { text: '\t' + email }
                            Text { text: 'Âge :\t' + age + " ans" }
                            Text { text: 'Profession :\t' + profession }
                            Text {
                                text: 'Compétences : ' + competences
                                wrapMode: Text.WordWrap
                                width: parent.width}
                            Text { text: 'Langues :\t' + langues }
                            Text {
                                text: 'Commentaire : ' + commentaire_personne
                                wrapMode: Text.WordWrap
                                width: parent.width}
                        }
                    }
                }

                Image {
                    id: plan
                    width: parent.width / 2
                    sourceSize.height: 1000
                    sourceSize.width: 1000
                    fillMode: Image.PreserveAspectFit
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.bottom: navigateurDeTemps.top
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../plan.svg"
                    z:3

                    Rectangle {

                        id: rectangleAutourPlan
                        anchors.top: plan.y
                        anchors.topMargin: 0
                        anchors.fill:parent
                        color:"transparent"

                        Repeater {
                            id: leRepeater
                            objectName: "monRepeater"
                            model: app.planCourant



                            delegate: Rectangle {
                                id: imageMarqueur
                                //source: "marqueurs/rouge.png"
                                x: (plan.width > plan.height) ? (posx * plan.height)+ ((plan.width-plan.height)/2) : posx * plan.width
                                y: (plan.width > plan.height) ? posy * plan.height : (posy * plan.width)+ ((plan.height-plan.width)/2)
                                height: (plan.width > plan.height) ? (50/1000) * plan.height : (50/1000) * plan.width
                                width: (plan.width > plan.height) ? (50/1000) * plan.width : (50/1000) * plan.width
                                radius: 100
                                border.width: 4
                                border.color: "red"
                                z: 100
                                transform: Translate {
                                    x: -width/2
                                    y: -height/2
                                }
                                MouseArea {

                                    hoverEnabled: true
                                    onEntered : { allongerRectangle.start(); elargirRectangle.start(); remonterRectangle.start(); app.setIdTour(id_tour)} // Le contraire de arrondir
                                    onExited : { retrecirRectangle.start(); affinerRectangle.start(); redescendreRectangle.start();app.setIdTour(-1) }



                                    NumberAnimation { id: allongerRectangle; target: imageMarqueur; property: "width"; to: 300; duration: 200}
                                    NumberAnimation { id: elargirRectangle; target: imageMarqueur; property: "height"; to: 60; duration: 200}
                                    NumberAnimation { id: derondirRectangle; target: imageMarqueur; property: "radius"; to: 5; duration: 200}
                                    NumberAnimation { id: remonterRectangle; target: imageMarqueur; property: "z"; to: 200; duration: 200}

                                    NumberAnimation { id: retrecirRectangle; target: imageMarqueur; property: "width"; to: Math.round((plan.width > plan.height) ? (50/1000) * plan.height : (50/1000) * plan.width); duration: 200}
                                    NumberAnimation { id: affinerRectangle; target: imageMarqueur; property: "height"; to: Math.round((plan.width > plan.height) ? (50/1000) * plan.height : (50/1000) * plan.width); duration: 200}
                                    NumberAnimation { id: redescendreRectangle; target: imageMarqueur; property: "z"; to: 100; duration: 200}



                                    anchors.fill : parent

                                }

                                Rectangle {
                                    id:ddd
                                    anchors.fill: parent
                                    color: "transparent"


                                    ListView {
                                          id: interieurCercle
                                          model: app.tour_benevoles

                                          //anchors.centerIn: parent
                                          anchors.left: parent.left
                                          anchors.top: parent.top
                                          anchors.leftMargin: 50
                                          width: parent.width
                                          height: parent.height

                                          anchors.topMargin: 15
                                          clip:true
                                          spacing: 13
                                          orientation: ListView.Horizontal
                                          delegate:  Rectangle {

                                              Rectangle {color: "black"; radius: 100; width: 10;height: 10}
                                              Rectangle {color: Fonctions.couleurCercle(statut_affectation); radius: 100; width: 10;height: 10; border.color: "black"; border.width: 1}
 }

                                    }
                                }

                            }
                        }

                        Rectangle {
                            id: bulleinformative
                            color: "white"
                            x: 0
                            y: -1000
                            width: 200
                            height: 50
                            radius:5
                            border.color: "#c0392b"
                            border.width: 2

                            Text {
                                anchors.fill: parent
                                anchors.margins: 10
                                text: "Exemple d'information"
                            }


                        }


                    }

                }

                Rectangle {
                    id: tours
                    anchors.top: parent.top
                    anchors.bottom: navigateurDeTemps.top
                    anchors.left: plan.right
                    anchors.right: parent.right
                    anchors.margins: 20
                    z:2

                    TextField {
                        id: rechercheDeTours
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.leftMargin: 0
                        placeholderText: qsTr("Recherche d'un tour sur un poste")
                    }

                    ListView {
                        id: listeDesTours
                        anchors.top: rechercheDeTours.bottom
                        anchors.topMargin: 10
                        clip: true
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.leftMargin: 0
                        spacing: 3
                        height: parent.height * 0.30
                        delegate: Button {
                            text: nom
                            anchors.left: parent.left
                            anchors.right: parent.right

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    app.setIdPoste(id_poste)
                                    app.setIdTour(id_tour)
                                    console.log(id_tour);
                                    _listeDesAffectes.text = "<hr><u>Liste des affectés</u>";

                                }
                            }
                        }
                        keyNavigationWraps: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: app.planCourant
                    }

                    ListView {

                        id: fichePoste
                        model: app.fiche_poste
                        anchors.top: listeDesTours.bottom
                        anchors.topMargin: 15

                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        clip: true
                        height: parent.height * 0.20

                        delegate:


                            Column {

                            anchors.topMargin: 10

                            Text {
                                id: _horaire
                                text: '<b><h2>' + Fonctions.heure(debut) + " - " + Fonctions.heure(fin) + "</h2></b><br>"
                                wrapMode: Text.Wrap
                                width: fichePoste.width
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                id: _nombre_affectation
                                text: "<u>Affectations: </u> " + nombre_affectations+"/"+max
                                wrapMode: Text.Wrap
                                width: fichePoste.width
                            }


                        }


                    }


                    Rectangle {
                        anchors.top: fichePoste.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 15

                        Text
                        {
                            id: _listeDesAffectes
                            text: "<u>Liste des affectés</u>"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        ListView {
                            id: benevolesAffectes
                            anchors.top: _listeDesAffectes.bottom
                            anchors.topMargin: 6
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            clip: true
                            spacing: 6
                            model: app.tour_benevoles

                            delegate:
                                Row {

                                Rectangle { id: rond_couleur_affectation; color:Fonctions.definirCouleurCercleNom(statut_affectation);radius:100; width:10; height:10}



                                Text {
                                    text: " " +nom_personne + " " + prenom_personne + " " + statut_affectation
                                    wrapMode: Text.Wrap
                                    width: parent.width - rond_couleur_affectation


                                }

                            }

                        }


                        ScrollBar {
                            flickable: benevolesAffectes;
                        }
                    }
                    ScrollBar {
                        flickable: listeDesTours;
                    }


                    ScrollBar {
                        flickable: fichePoste;
                    }

                }


                /*  Connections {
                                    target: gestionnairedaffectations
                                    onPlacerMarqueur: {
                                      Fonctions.createSpriteObjectsPlan(x,y);
                                    }
                                } */


                Slider { // Le slider permettant de changer de date
                    id: navigateurDeTemps
                    minimumValue: app.heureMin.getTime()
                    maximumValue: app.heureMax.getTime()
                    value: app.heure.getTime()
                    z:2
                    updateValueWhileDragging : false
                    onValueChanged: {
                        app.heure = new Date(value);
                        listeDesTours.model = app.planCourant;
                        bulleinformative.y = -1000;
                        leRepeater.model = app.planCourant;
                        app.setIdPoste(-1)
                        app.setIdTour(-1)
                        _listeDesAffectes.text = ""
                    }
                    //  console.log(app.heure);}// La variable "heure" prends pour valeur la date du slider
                    // stepSize: 24*3600 // Fait planter l'application


                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    // anchors.bottom: statusbar.top NE PLACE PAS AU DESSUS DE LA BARRE DE STATUT
                    anchors.bottomMargin: 20 // SOLUTION TEMPORAIRE
                    anchors.bottom:parent.bottom

                    style: SliderStyle {
                        groove: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 8
                            LinearGradient {
                                anchors.fill: parent
                                start: Qt.point(0, 0)
                                end: Qt.point(navigateurDeTemps.width, 0)
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "red" }
                                    GradientStop { position: 1.0; color: "blue" }
                                }
                            }
                            radius: 8
                        }
                        handle: Rectangle {
                            anchors.centerIn: parent
                            color: control.pressed ? "white" : "lightgray"
                            border.color: "gray"
                            border.width: 2
                            implicitWidth: 55
                            implicitHeight: 34
                            radius: 12

                            Rectangle {
                                anchors.topMargin: 10
                                anchors.fill:parent
                                color: "transparent"
                                Text {
                                    text: Fonctions.heure(app.heure)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }


                }



            }


        }
        // ===================================================================
        // =======================ONGLET POSTES ET TOURS =====================
        // ===================================================================

        Component {
            id: postesEtTours
            Rectangle {
                id:rectTest
                objectName: "recTest"
                color: "white"
                Image {
                    id: planPosteEtTours
                    width: 3* (parent.width / 5)

                    sourceSize.height: 1000
                    sourceSize.width: 1000
                    fillMode: Image.PreserveAspectFit
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 85
                    anchors.left: parent.left
                    anchors.leftMargin:10
                    source: "../plan.svg"
                    onStatusChanged: console.log(planPosteEtTours.anchors.right)

                    Rectangle {

                        id: rectangleBordurePlan
                        color: "transparent"


                        x: (parent.width - width)/2
                        y: (parent.height - height)/2
                        height: Fonctions.min(parent.width, parent.height)
                        width: Fonctions.min(parent.width, parent.height)

                        MouseArea {
                            id: mouseAreaPlan
                            anchors.fill: parent
                            onClicked: Fonctions.createSpriteObjects(rectangleBordurePlan,mouse.x , mouse.y)
                            cursorShape: Qt.CrossCursor
                        }
                    }



                }

                Rectangle {
                    id: descriptionPoste
                    width: 2* (parent.width / 5)
                    color:"white"
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin:10
                    border.color: "black"
                    border.width: 1

                    Label {
                        id : _nom
                        text: "Nom:"
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 10
                    }

                    TextField {
                        id: _nomPoste
                        placeholderText: "Nom du poste"
                        anchors.top: parent.top
                        anchors.topMargin:5
                        anchors.left: _descriptionPoste.left

                    }

                    Label {
                        id : _description
                        text: "Description:"
                        anchors.top: _nom.bottom
                        anchors.left: parent.left
                        anchors.margins: 10
                    }

                    TextArea { // TODO : Retour à la ligne automatique
                        id: _descriptionPoste
                        anchors.top: _nomPoste.bottom
                        anchors.topMargin:5
                        anchors.left: _description.right
                        anchors.right: parent.right
                        anchors.rightMargin:10
                        anchors.leftMargin: 10
                        height:parent.height/3

                    }

                    TableView {
                        id: tableauTours
                        width:parent.width *0.95
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top:_descriptionPoste.bottom
                        anchors.topMargin: 10
                        TableViewColumn{ role: "debut"  ; title: "Debut du tour" ; width:(3*(tableauTours.width/10))}
                        TableViewColumn{ role: "fin" ; title: "Fin du tour" ;width:(3*(tableauTours.width/10))}
                        TableViewColumn{ role: "min"  ; title: "Nb. min" ;width:(tableauTours.width/5)}
                        TableViewColumn{ role: "max" ; title: "Nb. max" ;width:(tableauTours.width/5)}
                        model: exemplePeuplement
                    }

                    ListModel {
                        id: exemplePeuplement
                        ListElement{ debut: "05/06/2015 20h00"; fin:"05/06/2015 22h00"; min: "2"; max:"4";}
                        ListElement{ debut: "05/06/2015 22h00"; fin:"06/06/2015 00h00"; min: "4"; max:"5";}
                        ListElement{ debut: "06/06/2015 00h00"; fin:"06/06/2015 02h00"; min: "3"; max:"5";}
                    }

                    Button { // Exemple d'ajout
                        anchors.top : tableauTours.bottom
                        anchors.topMargin: 10
                        onClicked:{
                            exemplePeuplement.append({debut: "21/12/2012 00h00", fin:"22/12/2012", min: "0", max:"7 milliards"});

                        }
                        text:"Ajouter un tour"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }



                }

                Image {
                    id: corbeille
                    width: 45
                    height:65

                    anchors.topMargin: 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 25
                    anchors.left: descriptionPoste.left
                    anchors.leftMargin: (-(corbeille.width+100))
                    source: "corbeille.png"
                }



            }
        }
        //===========================================================================
        //=====================ONGLET CANDIDATURE A VALIDER =========================
        //===========================================================================

        Component {
            id: candidaturesAValider
            Rectangle {

                color: "purple"

                Rectangle {
                    id: rectangleCandidats
                    color: "white"
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin:5
                    width: (parent.width/4 - 10)
                    height: parent.height * 0.90

                    Label {
                        id: _listeDesCandidats
                        text: "Liste des candidats"
                        anchors.top: rectangleCandidats.top
                        anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.underline: true
                    }

                    Rectangle {
                        anchors.top:_listeDesCandidats.bottom
                        anchors.topMargin:45 // Pour eviter qu'a certain moment la liste dépasse sur le texte
                        anchors.bottom: rectangleCandidats.bottom
                        anchors.bottomMargin: 45 // Pour eviter qu'a certain moment la liste dépasse du rectangle
                        anchors.right: rectangleCandidats.right
                        anchors.left: rectangleCandidats.left
                        anchors.margins: 10



                        Component {
                            id: listDelegate

                            Rectangle {

                                id: cadreCandidat
                                width: parent.width
                                height: 50

                                anchors.margins: 3

                                Row {

                                    Column {
                                        width: 50
                                        Image {
                                            id: itemBtn
                                            source: "personne.png"

                                        }
                                    }

                                    Column {
                                        width: 200
                                        anchors.top:parent.top
                                        anchors.topMargin:10
                                        Text { text: 'Nom: ' + nom_personne }
                                        Text { text: 'Prenom: ' + prenom_personne }
                                    }

                                }

                                MouseArea {
                                    anchors.fill: parent;
                                    onClicked:{
                                        listView.currentIndex = index;
                                        _numCandidat.text = "Candidat Sélectionné: "+index

                                        //Fonctions.focusCandidat(index); TODO
                                    }
                                }
                            }
                        }

                        ListModel {
                            id: listModel

                            ListElement {
                                nom: "ETCHEGOYEN"
                                prenom: "Bastien"
                            }
                            ListElement {
                                nom: "ALCUYET"
                                prenom: "Gaizka"
                            }
                        }

                        ListView {
                            id: listView
                            anchors.fill: parent
                            anchors.margins: 5
                            model: app.benevoles_disponibles
                            delegate: listDelegate
                            focus: true
                        }
                    }

                }

                Rectangle {
                    id: rectangleFicheDuCandidat
                    color: "white"
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: rectangleCandidats.right
                    anchors.leftMargin:5
                    width: (parent.width/4 - 10)
                    height: parent.height * 0.90

                    Label {
                        id: _ficheDuCandidatSelectionne
                        text: "Fiche du candidat sélectionné"
                        anchors.top: rectangleFicheDuCandidat.top
                        anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.underline: true
                        anchors.left: rectangleCandidats.right
                        anchors.leftMargin: 10
                    }

                    Label {

                        id: _numCandidat
                        text: "Candidat Sélectionné: aucun"
                        anchors.top: _ficheDuCandidatSelectionne.top
                        anchors.topMargin: rectangleFicheDuCandidat.height/2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.left: rectangleCandidats.right
                        anchors.leftMargin: 10
                    }

                }

                Rectangle {
                    id: rectangleListeDoublons
                    color: "white"
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: rectangleFicheDuCandidat.right
                    anchors.leftMargin:5
                    width: (parent.width/4 - 10)
                    height: parent.height * 0.90

                    Label {
                        id: _doublonPossibles
                        text: "Doublons possibles du candidat"
                        anchors.top: rectangleListeDoublons.top
                        anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.underline: true
                        anchors.left: rectangleFicheDuCandidat.right
                        anchors.leftMargin: 10
                    }
                }

                Rectangle {
                    id: rectangleFicheDoublon
                    color: "white"
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: rectangleListeDoublons.right
                    anchors.leftMargin:5
                    width: (parent.width/4 - 10)
                    height: parent.height * 0.90

                    Label {
                        id: _ficheDuDoublon
                        text: "Fiche du doublon"
                        anchors.top: rectangleFicheDoublon.top
                        anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.underline: true
                        anchors.left: rectangleListeDoublons.right
                        anchors.leftMargin: 10
                    }
                }


            }
        }

        //===========================================================================
        //=====================   ONGLET INSCRIRE BENEVOLE ==========================
        //===========================================================================
        Component {
            id:inscrireBenevole
            Rectangle {
                anchors.fill: parent
                color: green

                Label {
                    id: l_nomBenevole
                    text: "Nom: "
                    anchors.top: parent.top
                    anchors.topMargin:29
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _nomBenevole
                    placeholderText: "Nom"
                    anchors.top: parent.top
                    anchors.topMargin:25
                    anchors.left: l_nomBenevole.right
                }

                Label {
                    id: l_prenomBenevole
                    text: "Prenom: "
                    anchors.top: _nomBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _prenomBenevole
                    placeholderText: "Prenom"
                    anchors.top: _nomBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_prenomBenevole.right
                }

                Label {
                    id: l_adresseBenevole
                    text: "Adresse Postale: "
                    anchors.top: _prenomBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _adresseBenevole
                    placeholderText: "Adresse"
                    anchors.top: _prenomBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_prenomBenevole.right
                }

                Label {
                    id: l_codePostalBenevole
                    text: "Code postal: "
                    anchors.top: _adresseBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _codePostalBenevole
                    placeholderText: "Code Postal"
                    anchors.top: _adresseBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_codePostalBenevole.right
                }

                Label {
                    id: l_communeBenevole
                    text: "Commune: "
                    anchors.top: _codePostalBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _communeBenevole
                    anchors.top: _codePostalBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_communeBenevole.right
                }

                Label {
                    id: l_courrielBenevole
                    text: "Courriel: "
                    anchors.top: _communeBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _courrielBenevole
                    placeholderText: "Adresse courriel"
                    anchors.top: _communeBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_courrielBenevole.right
                }

                Label {
                    id: l_numPortableBenevole
                    text: "Numero de portable: "
                    anchors.top: _courrielBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _numPortableBenevole
                    placeholderText: "Portable"
                    anchors.top: _courrielBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_numPortableBenevole.right
                }

                Label {
                    id: l_numDomicileBenevole
                    text: "Numero du domicile: "
                    anchors.top: _numPortableBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _numDomicileBenevole
                    placeholderText: "Numero du domicile"
                    anchors.top: _numPortableBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_numDomicileBenevole.right
                }

                Label {
                    id: l_professionBenevole
                    text: "Profession: "
                    anchors.top: _numDomicileBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _professionBenevole
                    placeholderText: "Profession"
                    anchors.top: _numDomicileBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_professionBenevole.right
                }

                Label {
                    id: l_datenaissanceBenevole
                    text: "Date de naissance "
                    anchors.top: _professionBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _datenaissanceBenevole
                    placeholderText: "JJ/MM/AAAA"
                    anchors.top: _professionBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_datenaissanceBenevole.right
                }

                Label {
                    id: l_languesBenevole
                    text: "Langues: "
                    anchors.top: _datenaissanceBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _languesBenevole
                    placeholderText: "Langues"
                    anchors.top: _datenaissanceBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_languesBenevole.right
                }

                Label {
                    id: l_competencesBenevole
                    text: "Competences: "
                    anchors.top: _languesBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _competencesBenevole
                    placeholderText: "Competence"
                    anchors.top: _languesBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_competencesBenevole.right
                }

                Label {
                    id: l_commentaireBenevole
                    text: "Commentaire: "
                    anchors.top: _competencesBenevole.bottom
                    anchors.topMargin:9
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                }

                TextField {
                    id: _commentaireBenevole
                    placeholderText: "Commentaire"
                    anchors.top: _competencesBenevole.bottom
                    anchors.topMargin:5
                    anchors.left: l_competencesBenevole.right
                }

                Button {
                    text: "Inscrire le bénévole"
                    anchors.top: _commentaireBenevole.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.40
                    onClicked: { console.log("TODO: Faire la requete d'inscription (attendre modification de la base");
                        app.faireInscription(_nomBenevole.text, _prenomBenevole.text, _adresseBenevole.text, _codePostalBenevole.text, _communeBenevole.text,_courrielBenevole.text, _numero);
                    }
                }

            }
        }

        //===========================================================================
        //=====================ONGLET SOUMETTRE AFFECTATION==========================
        //===========================================================================

        Component {
            id: soumettreAffectations
            Rectangle {
                color: "pink"
                Label {
                    id : _soumettreAffectations
                    text : "Soumettre par email les affectations pour validation par chaque bénévole"
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 20
                    anchors.leftMargin:20
                    font.pixelSize: 16
                }

                CheckBox {
                    id: _checkboxAffecationsJamaisSoumises
                    anchors.top: _soumettreAffectations.bottom
                    anchors.topMargin: 10
                    anchors.left: _soumettreAffectations.left
                    anchors.leftMargin: 50
                    text: "Les affectations proposées qui n'ont jamais été soumises à l'approbation du bénévole"
                }

                CheckBox {
                    id: _checkboxAffecationsNonTraitees
                    anchors.top: _checkboxAffecationsJamaisSoumises.bottom
                    anchors.topMargin: 10
                    anchors.left: _soumettreAffectations.left
                    anchors.leftMargin: 50
                    text: "Les affectations qui ont déjà été soumises mais que le bénévole n'a pas encore traité"
                }

                CheckBox {
                    id: _checkboxAffecationsRelance
                    anchors.top: _checkboxAffecationsNonTraitees.bottom
                    anchors.topMargin: 10
                    anchors.left: _soumettreAffectations.left
                    anchors.leftMargin: 50
                    text: "Les affectations qui ont fait l'objet d'une relance mais n'ont pas obtenue de réaction"
                }

                Label {
                    id: _envoyerMessage
                    anchors.top: _checkboxAffecationsRelance.bottom
                    anchors.topMargin: 100
                    anchors.left: _soumettreAffectations.left
                    anchors.leftMargin: 50
                    text: "Envoyer un message à "
                }

                Button {
                    id: _boutonGenerer
                    anchors.top: _envoyerMessage.top
                    anchors.topMargin: -5 // Simplement pour que le bouton soit centré avec le texte
                    anchors.left: _envoyerMessage.right
                    anchors.leftMargin: 10
                    text: "Generer l'adresse mail"
                    onClicked: {
                        console.log("TODO: Generer la chaine de caractère et la placer à la place du bouton.")
                        console.log("Si ce n'est pas possible, ouvrir une boite de dialogue ?")
                        // _boutonGenerer.destroy()
                    }
                }
            }
        }

        Component {
            id: solliciterAnciensBenevoles
            Rectangle {
                color: "yellow"
                Plan {

                }
            }
        }



    }


    StatusBar { // Barre de statut, indique la date
        id: statusbar
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        Label {
            text: Fonctions.dateFR(app.heure)
        }
    }
}

