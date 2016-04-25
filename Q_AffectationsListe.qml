import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.2

import "fonctions.js" as Fonctions

Item {
    anchors.fill: parent

    Rectangle { // liste des dispo et fiche du participant
        id: affectationsListeDisponibilites
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.30

        TextField {
            id: disponibilitesRecherche
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            onEditingFinished: app.benevoles_disponibles.setFilterFixedString(text);
            placeholderText: "Disponibilités Recherche"

        }

        Rectangle {
            id: headerListeDesDisponibilites
            anchors.top: disponibilitesRecherche.bottom
            anchors.topMargin:5
            color:"#ecf0f1"
            height: 15
            width: parent.width


            Text {
                anchors.top: parent.top
                x: parent.width *0.25 - width/2
                text: "Prenom Nom"

            }
            Text {
                anchors.top: parent.top
                x: parent.width *0.75 - width/2
                text: "Nombre d'affectations"

            }

        }

        ListView {
            id: listeDesDisponibles
            anchors.bottom: parent.verticalCenter
            anchors.top: headerListeDesDisponibilites.bottom
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.left: parent.left
            clip: true


            delegate: Rectangle { // Corresponds au block contenant le nom... La  ListView contient donc plusieurs de ces blocks
                height: _nomPrenom.height + _nomPrenom.anchors.topMargin
                anchors.left: parent.left
                anchors.right: parent.right
                z:3

                Text {
                    id: _nomPrenom
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    width: parent.width * 0.70
                    text: prenom_personne + ' ' + nom_personne
                    horizontalAlignment: Text.Left
                }
                Text {
                    id: _nombreAffectations
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.right: parent.right
                    text: nombre_affectations
                    horizontalAlignment: Text.Left
                    width: parent.width * 0.3
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listeDesDisponibles.currentIndex = index
                        app.setIdDisponibilite(id_disponibilite)
                        //listeDesDisponibles.model = app.benevoles_disponibles
                    }
                }
            }

            model: app.benevoles_disponibles
            highlight: Rectangle { visible: (listeDesDisponibles.currentIndex == -1 )? false: true; z:5;color: "blue"; radius: 5; opacity: 0.5; width: listeDesDisponibles.width ; height:13 ;y: (listeDesDisponibles.currentIndex == -1 )? 0: listeDesDisponibles.currentItem.y + 10;x: (listeDesDisponibles.currentIndex == -1 )? 0: listeDesDisponibles.currentItem.x}
            focus: true
            highlightFollowsCurrentItem: false

        }

        Component.onCompleted: {
            listeDesDisponibles.currentIndex = -1;
        }



        ScrollBar { // de la ListView
            flickable: listeDesDisponibles;
        }

        Rectangle { // un trait et la fiche du participant
            anchors.fill: parent
            border.color: "black"
            color: "transparent"

            Trait {
                id: traitMilieu
                anchors.top: parent.verticalCenter
            }

            ListView {
                id: ficheBenevole
                model: app.fiche_benevole
                anchors.top: traitMilieu.bottom
                anchors.bottom: parent.bottom
                anchors.margins: 5
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.left: parent.left
                clip:true

                delegate: Column {


                    Text { text: "<img src='personne.png'/>     <b>" + prenom + " " + nom + "</b><br>";}
                    Text { text: 'Inscription :\t' + date_inscription.toLocaleDateString();}
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
                    Text { text: 'Id DISPO :\t' + id_disponibilite } // A ENKLEVER
                    Text {
                        text: 'Compétences : ' + competences
                        wrapMode: Text.WordWrap
                        width: parent.width}
                    Text { text: 'Langues :\t' + langues }
                    Text {
                        text: 'Commentaire : ' + commentaire_personne
                        wrapMode: Text.WordWrap
                        width: parent.width}
                    Text {
                        text: 'Disponibilite : ' + commentaire_disponibilite
                        wrapMode: Text.WordWrap
                        width: parent.width}

                }
            }
        }
    }

    Rectangle { // TODO remplacer par un layout avec un spacing et virer les margins des blocks regroupés ici
        id: blockPosteTour
        anchors.left: affectationsListeDisponibilites.right
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "white"

        ListeDesToursParPoste {
            id: listeDesToursParPoste
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            anchors.bottom: parent.verticalCenter
        }

        Button {
            id: _boutonEnvoyer // TODO : Renommer
            anchors.top: listeDesToursParPoste.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            text : "→"
            onClicked : {
                console.log("Cliqué");
                app.affecterBenevole();
                app.setIdDisponibilite(-1)
                listePersonnesInscritesBenevoles.model = app.affectations_acceptees_validees_ou_proposees_du_tour;
                listeDesToursParPoste.model = app.poste_et_tour;

            }
        }

        Button {
            id: _boutonRecevoir // TODO : Renommer
            anchors.top: _boutonEnvoyer.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            text : "←"
            anchors.leftMargin: 10
            onClicked: {
                console.log("index:" + listePersonnesInscritesBenevoles.currentIndex);
                console.log("model: " + listePersonnesInscritesBenevoles.model.getDataFromModel(listePersonnesInscritesBenevoles.currentIndex,"id_affectation"))
                app.desaffecterBenevole(listePersonnesInscritesBenevoles.model.getDataFromModel(listePersonnesInscritesBenevoles.currentIndex,"id_affectation"));
                app.setIdDisponibilite(-1)
                listePersonnesInscritesBenevoles.model = app.affectations_acceptees_validees_ou_proposees_du_tour;
                listeDesToursParPoste.model = app.poste_et_tour;
                // _boutonRecevoir.checkable = true

            }
        }

        FicheDuTour {
            id: blockFichePoste
            anchors.top: listeDesToursParPoste.bottom
            anchors.left: _boutonEnvoyer.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.topMargin: 15
            anchors.leftMargin: 10
            anchors.rightMargin: 10
        }


    }


}



