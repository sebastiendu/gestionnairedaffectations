import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2

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

    Action {
        id: parametresDeCourriel
        text: qsTr("Paramètres de courriel")
        tooltip: "Définir les paramètres d'envoi des messages de courriel par lot"
        onTriggered: parametresCourriel.open()
    }

    Action {
        id: actionOuvrirEvenement
        text: qsTr("Ouvrir un Événement")
        onTriggered: fenetreOuvrirEvenement.open()
    }

    Rectangle {
        id : enSavoirPlus
        visible: false
        color: "white"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: parent.height*0.20
        anchors.leftMargin: parent.width*0.25
        width: parent.width*0.50
        height: 300
        border.color: "#bdc3c7"
        z: 500



        MouseArea {
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                Text {
                    id: logo
                    anchors.top: parent.top;
                    anchors.left: parent.left;
                    anchors.topMargin:  10;
                    anchors.leftMargin:parent.width/2 - width/2;
                    textFormat: Text.RichText
                    text:"<a href='http://ldd.fr' style='text-decoration:none'><img src='http://www.ldd.fr/local/cache-vignettes/L92xH100/siteon0-c0f7c.png'/></a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }

                Text {
                    id: adresse
                    anchors.top: logo.bottom
                    anchors.topMargin:15
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width/2 - width/2
                    text: "Les Développements Durables<br>2 bis, rue des Visitandines<br>64100 Bayonne"

                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 5
                    height: 5
                    color: "#bdc3c7"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: sound.play()
                    }

                   /* SoundEffect {
                        id: sound
                        volume: 0.8
                        source: "new_sound.wav"
                    }
                    == EASTER EGG
                    */

                }
                /*
                AnimatedImage {
                    anchors.top: parent.top
                    source: "doge.gif"
                    visible: sound.playing
                }
                    == EASTER EGG
                */

            }

            Text{
                visible: enSavoirPlus.visible
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 10
                anchors.rightMargin: 10
                font.pixelSize: 18
                text: "X"

                MouseArea {
                    anchors.fill: parent
                    onClicked : enSavoirPlus.visible = false
                }
            }
        }


    }

    Dialog {
        id: fenetreOuvrirEvenement

        width: 700
        height: 300

        TableView { // Le menu déroulant permettant de sélectionner l'événement
            id: tableauEvenement
            property int _id_evenement
            // height:50
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            model: app.liste_des_evenements // On charge la liste des évenement du menu déroulant
            selectionMode: SelectionMode.SingleSelection // FIXME: default
            TableViewColumn{ role: "id"  ; title: "id" ; horizontalAlignment: Text.AlignHCenter; width:((tableauEvenement.width/10))-1; visible: false;}
            TableViewColumn{ role: "nom"  ; title: "Nom" ; horizontalAlignment: Text.AlignHCenter;width:3*(tableauEvenement.width/10)-1}
            TableViewColumn{ role: "archive" ; title: "Archivé" ; horizontalAlignment: Text.AlignHCenter;width:(1.5*tableauEvenement.width/10)-1;}
            TableViewColumn{ role: "debut"  ; title: "Debut" ;  horizontalAlignment: Text.AlignHCenter; width:(2*(tableauEvenement.width/10))-1; delegate: Text { text: Fonctions.dateFR(styleData.value);elide:styleData.elideMode;color: (styleData.selected)? "white" : "black"}}
            TableViewColumn{ role: "fin" ; title: "Fin" ; horizontalAlignment: Text.AlignHCenter;width:(2*(tableauEvenement.width/10))-1; delegate: Text { text: Fonctions.dateFR(styleData.value);elide:styleData.elideMode; color: (styleData.selected)? "white" : "black"}}
            TableViewColumn{ role: "lieu"  ; title: "Lieu" ; horizontalAlignment: Text.AlignHCenter;width:(1.5*tableauEvenement.width/10)-1;}

            rowDelegate: Rectangle {

                color: styleData.selected ? Qt.rgba(0,0,1,0.5) : "white"

                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        app.setIdEvenement(model.id);
                        fenetreOuvrirEvenement.close();
                    }

                    onClicked: {
                        tableauEvenement.currentRow = styleData.row
                        tableauEvenement.selection.clear();
                        tableauEvenement.selection.select(styleData.row);
                        app.setIdEvenement(model.id); // FIXME : devrait être dans onAccepted de la Dialog
                    }
                }
            }
        }

        onAccepted : {

            //if(tableauEvenement.currentRow != -1) app.setIdEvenement( tableauEvenement.id_evenement); // FIXME setIdEvenement()
            fenetreOuvrirEvenement.close();

        }

    }

    Dialog {
        id: proprietesEvenement

        width: 400
        height: 300
        standardButtons: StandardButton.NoButton
        // modality: Qt.ApplicationModal

        Connections {
            target: app
            onListe_des_evenementsChanged: {

                _inputFin.text = Fonctions.dateFR(new Date(app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "fin")))
                _inputDebut.text = Fonctions.dateFR(new Date(app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "debut")))
                console.log(Fonctions.dateFR(new Date(app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "fin"))));
            }

            onFermerFenetreProprietesEvenement : {
                proprietesEvenement.close();
            }


        }


        Text { id: _nom; text: "Nom: \t";anchors.left: parent.left;anchors.leftMargin: 20 }
        TextField {id: _inputNom; anchors.left: _nom.right; width: 200; text: app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "nom");anchors.leftMargin: 20}
        Text { text: "Lieu: \t" ;id: _lieu; anchors.top: _nom.bottom; anchors.left: parent.left;anchors.topMargin:20;anchors.leftMargin: 20}
        TextField { id: _inputLieu; anchors.left: _lieu.right; width: 200;  anchors.top: _nom.bottom; text: app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "lieu");anchors.topMargin:20;anchors.leftMargin: 20}
        Text { text: "Debut: \t"; id: _debut; anchors.top: _lieu.bottom; anchors.left: parent.left;anchors.topMargin:20;anchors.leftMargin: 20}
        TextField {id: _inputDebut; anchors.left: _debut.right;  readOnly: true; width: 200;  anchors.top: _lieu.bottom; text: Fonctions.dateFR(new Date(app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "debut")));anchors.topMargin:20;anchors.leftMargin: 20}
// FIXME: le bouton debut mène à une pop-up de choix de date et heure mais sans bouton de validation, et qui s'appelle "Ajouter un tour" !
        Button {
            id: boutonCalendrierDebut
            anchors.top: _inputDebut.top
            anchors.left: _inputDebut.right
            anchors.leftMargin: 10
            width: 30
            text: "v"
            onClicked : { Fonctions.afficherFenetreCalendrier("debut",app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "debut"),new Date(app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "debut")).getHours(),new Date(app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "debut")).getMinutes())}
        }

        Text { text: "Fin: \t";id: _fin; anchors.top: _debut.bottom; anchors.left: parent.left;anchors.topMargin:20;anchors.leftMargin: 20}
        TextField{ id: _inputFin; anchors.top: _debut.bottom;  readOnly: true; width: 200; anchors.left: _fin.right; text: Fonctions.dateFR(new Date(app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "fin")));anchors.topMargin:20;anchors.leftMargin: 20}
        Button {
            id: boutonCalendrierFin
            anchors.top: _inputFin.top
            anchors.left: _inputFin.right
            anchors.leftMargin: 10
            width: 30
            text: "v"
            onClicked : { Fonctions.afficherFenetreCalendrier("fin",app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "fin"),new Date(app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "fin")).getHours(),new Date(app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "fin")).getMinutes())}
        }

        Text { text: "Archivé: \t" ; id: _archive; anchors.top: _fin.bottom; anchors.left: parent.left;anchors.topMargin:20;anchors.leftMargin: 20}
        CheckBox { id: _checkboxArchive; anchors.top: _fin.bottom; anchors.left: _archive.right;anchors.topMargin:20;anchors.leftMargin: 20; checked: app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "archive") }

        Button {
            id: _boutonChangerPlan
            text: "Changer le plan de l'événement"
            anchors.top: _checkboxArchive.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 20
            onClicked:  { planEvenement.open()}
        }

        Button {
            id: _boutonEnregistrer
            anchors.top: _boutonChangerPlan.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: (proprietesEvenement.width - width) /2
            width: 200
            text: "Enregistrer"
            //text: app.liste_des_evenements.getDataFromModel(app.id_evenement, "id")

            onClicked : {
                app.updateEvenement(_inputNom.text, _inputLieu.text, _checkboxArchive.checked);
            }


        }



        onAccepted: {
            console.log(_inputNom.text);
        }

    }

    MessageDialog {
        id: supprimerEvenement
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Yes |StandardButton.No
            text: "Etes vous sur de vouloir supprimer l'événemeent <b><i>"
                  + app.liste_des_evenements.getDataFromModel(app.liste_des_evenements.getIndexFromId(app.id_evenement), "nom")
                  + "</b></i> ?"

        onYes : {
            app.supprimerEvenement();
            supprimerEvenement.close();
        }

        onNo : {
            supprimerEvenement.close();
        }


    }

    Dialog {
        id: parametresCourriel
        width: prefixe.width+_variable.width+domaine.width+20
        modality: Qt.ApplicationModal
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        title: "Paramètres de courriel"
        onAccepted: {
            app.settings.setValue("email/prefixe", prefixe.text)
            app.settings.setValue("email/domaine", domaine.text)
        }
        Row {
            TextField {
                id: prefixe
                placeholderText: "prefixe"
                text: app.settings.value("email/prefixe", "")
            }

            Text {
                id: _variable
                anchors.verticalCenter: prefixe.verticalCenter
                text: "+<i>variable</i>@"
            }
            TextField {
                id: domaine
                placeholderText: qsTr("domaine")
                text: app.settings.value("email/domaine", "")
            }
        }
    }

    Action {
        id: planDeLEvenement
        text: qsTr("Plan de l'évènement…")
        tooltip: "Charger le plan de l'évènement"
        onTriggered: planEvenement.open()
    }

    FileDialog {
        id: planEvenement
        title: "Chargement du plan de l'évènement"
        nameFilters: [
            "Document SVG (*.svg)",
            "Tous les fichiers (*)"
        ]
        onAccepted: {
            app.enregistrerPlanEvenement(fileUrl)
        }
        modality: Qt.ApplicationModal
    }

    onClosing: {
        app.settings.setValue("x", x)
        app.settings.setValue("y", y)
        app.settings.setValue("width", width)
        app.settings.setValue("height", height)
    }

    menuBar: MenuBar { // La barre de menu
        Menu {
            title: qsTr("&Évenement")
            MenuItem { action: nouvelEvenement }
            MenuItem { action: actionOuvrirEvenement }
            MenuItem { action: planDeLEvenement }
            MenuItem {
                text: qsTr("Propriétés")
                onTriggered: proprietesEvenement.open();
            }
            MenuItem {
                text: qsTr("Supprimer")
                onTriggered: supprimerEvenement.open();
            }
            MenuItem {
                text: qsTr("Quitter")
                onTriggered: Qt.quit();
                shortcut: StandardKey.Quit
            }
        }

        Menu {
            title: qsTr("&Options")
            MenuItem { action: parametresDeConnexion }
            MenuItem { action: parametresDeCourriel }
        }

        Menu {
            title: qsTr("&Aide")
            MenuItem { text: qsTr("En savoir plus …");onTriggered: enSavoirPlus.visible = true}
        }

        Menu {
            title: qsTr("&Générer Etat")
            Menu {
                title: qsTr("Fiches des postes")

                MenuItem {
                    text: qsTr("PDF")
                    onTriggered: app.genererLesFichesDesPostesPDF();
                }

                MenuItem {
                    text: qsTr("ODT")
                    onTriggered: app.genererLesFichesDesPostesODT();
                }
            }

            Menu {
                title: qsTr("Cartes des bénévoles")

                MenuItem {
                    text: qsTr("PDF")
                    onTriggered: app.genererLesCartesDesBenevolesPDF();
                }

                MenuItem {
                    text: qsTr("ODT")
                    onTriggered: app.genererLesCartesDesBenevolesODT()
                }
            }

            MenuItem {
                text: qsTr("Tableau de remplissage")
                onTriggered: app.genererTableauDeRemplissage()
            }

            MenuItem {
                text: qsTr("Liste des personnes disponibles sans affectation")
                onTriggered: app.genererLaListeDesDisponibilitesSansAffectation()
            }

            MenuItem {
                text: qsTr("Export général des tours")
                onTriggered: app.genererExportGeneralDesTours()
            }

            MenuItem {
                text: qsTr("Export général des personnes")
                onTriggered: app.genererExportGeneralDesPersonnes()
            }
        }
    }

    TabView { // Les differents onglets
        id: onglet
        anchors.fill: parent
        currentIndex: 0 // TODO : si pas de connexion, montrer l'écran de connexion
                        // sinon si pas d'evenement, ecran de selection/creation de l'ev.
                        // sinon s'il n'y a pas de poste ou s'il n'y a pas de tour, ecran de definition des postes et tour de l'ev
                        // si pas de disponibilité, ecran de sollicitation et/ou d'inscription
                        // s'il y a des tours sans affectation, gestion des affectations
                        // s'il reste à valider des affectations, écran des demandes
                        // et sinon proposer la génération des états

        Tab {
            title : "Postes & Tours"

            Q_PosteEtTour{
            }
        }

        Tab {
            title: "Solliciter d'anciens bénévoles"

            Q_SolliciterAnciensBenevoles {
            }
        }

        Tab {
            title : "Candidature à valider"

            Q_CandidatureAValider {
            }
        }

        Tab {
            title: "Inscrire un bénévole"

            Q_InscrireBenevole {
            }
        }

        Tab {
            title: "Affectations (Plan)"

            Q_AffectationPlan {
            }
        }

        Tab {
            title: "Affectations (Liste)"

            Q_AffectationsListe {
            }
        }

        Tab {
            title: "Emploi du temps"

            Q_EmploiDuTemps {
            }
        }

        Tab {
            title: "Soumettre affectations"

            Q_SoumettreAffectation {
            }
        }
    }

    MessageDialog {
        id: messageDErreur
    }
    Connections {
        target: app
        onWarning: {
            messageDErreur.icon = StandardIcon.Warning
            messageDErreur.title = "Avertissement"
            messageDErreur.text=msg
            messageDErreur.informativeText=info
            messageDErreur.detailedText=detail
            messageDErreur.visible=true
        }
        onCritical: {
            messageDErreur.icon = StandardIcon.Critical
            messageDErreur.title = "Erreur critique"
            messageDErreur.text=msg
            messageDErreur.informativeText=info
            messageDErreur.detailedText=detail
            messageDErreur.visible=true
        }
        onFatal: {
            messageDErreur.icon = StandardIcon.Fatal
            messageDErreur.title = "Erreur fatale"
            messageDErreur.text=msg
            messageDErreur.informativeText=info
            messageDErreur.detailedText=detail
            messageDErreur.visible=true
        }
    }
}

