import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import fr.ldd.qml 1.0
import QtWebKit 3.0
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
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
    Dialog {
        id: parametresCourriel
        modality: Qt.ApplicationModal
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        title: "Paramètres de courriel"
        visible : false
        onAccepted: {
            app.settings.setValue("email/prefixe", prefixe.text)
            app.settings.setValue("email/domaine", domaine.text)
        }
        Row {
            TextField {
                id: prefixe
                placeholderText: "prefixe"
                text: app.settings.value("email/prefixe")
            }

            Text {
                text: "+<i>variable</i>@"
            }
            TextField {
                id: domaine
                placeholderText: qsTr("domaine")
                text: app.settings.value("email/domaine")
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
            MenuItem { action: planDeLEvenement }
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
            MenuItem { action: parametresDeCourriel }
        }


        Menu {
            title: qsTr("&Aide")
        }

        Menu {
            title: qsTr("&Générer Etat")
            MenuItem {
                text: qsTr("Fiche de postes / Bénévoles par tours")
                onTriggered: app.genererFichesDePostes();
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



        Tab {
            id: postesEtTours
            title : "Postes & Tours"


            Q_PosteEtTour{

            }
        }


        Tab {
            id: solliciterAnciensBenevoles
            title: "Solliciter d'anciens bénévoles"

            Rectangle {
                color: "yellow"

            }
        }


        Tab {
            id: candidaturesAValider
            title : "Candidature à valider"
            anchors.fill: parent
            Q_CandidatureAValider {

            }

        }

        Tab {
            id:inscrireBenevole
            title: "Inscrire un bénévole"

            Q_InscrireBenevole {

            }
        }


        Tab {
            id: carte
            title: "Affectations (Plan)"


            Q_AffectationPlan {
                anchors.fill: parent
            }

        }


        Tab {
            id: affectationsListe
            title: "Affectations (Liste)"
            anchors.fill: parent


            Q_AffectationsListe {

            }

        }

        Tab {
            id: emploiDuTemps
            title: "Emploi du temps"
            anchors.fill: parent


            Q_EmploiDuTemps {

            }

        }


        Tab {
            id: soumettreAffectations
            title: "Soumettre affectations"

            Q_SoumettreAffectation {

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
            text: Fonctions.dateBarreStatut(app.heure)
        }
    }
    MessageDialog {
        id: messageDErreur
    }
    Connections {
        target: app
        onWarning: {
            messageDErreur.icon = StandardIcon.Warning
            messageDErreur.text=msg
            messageDErreur.visible=true
        }
        onCritical: {
            messageDErreur.icon = StandardIcon.Critical
            messageDErreur.text=msg
            messageDErreur.visible=true
        }
        onFatal: {
            messageDErreur.icon = StandardIcon.Fatal
            messageDErreur.text=msg
            messageDErreur.visible=true
        }
    }
}

