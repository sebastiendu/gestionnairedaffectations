import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2


import "fonctions.js" as Fonctions

Item {
    anchors.fill: parent

    Rectangle {
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
                height: 13
                anchors.left: parent.left
                anchors.right: parent.right
                z:3

                Text {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.horizontalCenter
                    text: prenom_personne + ' ' + nom_personne
                    horizontalAlignment: Text.Center
                }
                Text {
                    anchors.top: parent.top
                    anchors.left: parent.horizontalCenter
                    anchors.right: parent.right
                    text: nombre_affectations
                    horizontalAlignment: Text.Center
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listeDesDisponibles.currentIndex = index
                        app.setIdDisponibilite(id_disponibilite)
                        listeDesDisponibles.model = app.benevoles_disponibles
                    }
                }
            }

            model: app.benevoles_disponibles
            highlight: Rectangle { z:5;color: "blue"; radius: 5; opacity: 0.5; width: listeDesDisponibles.width ; height:13 ;y: listeDesDisponibles.currentItem.y;x: listeDesDisponibles.currentItem.x}
            focus: true
            highlightFollowsCurrentItem: false

        }



        ScrollBar {
            flickable: listeDesDisponibles;
        }

        Rectangle {
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
    }

    Rectangle {
        id: blockPosteTour
        anchors.left: affectationsListeDisponibilites.right
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "white"

        TextField {
            id: posteEtToursRecherche
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            onEditingFinished: app.poste_et_tour.setFilterFixedString(text);
            placeholderText: "Poste et tours Recherche"

        }

        Rectangle {
            id: blockListePosteTour
            anchors.top: posteEtToursRecherche.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            height: parent.height * 0.5
            border.color: "black"


            ListView {

                id: listePoste
                anchors.fill: parent
                model: app.poste_et_tour
                delegate:
                    Rectangle {
                    height : 13
                    z:1
                    width: parent.width
                    Text {
                        id: informationsTour
                    anchors.left: parent.left
                    anchors.leftMargin: 20;
                    text: Fonctions.dateFR(debut) + " → " + Fonctions.dateFR(fin) + "    " +
                          nombre_affectations + "/" +max  + "    " + "(min: " + min + ", max: " + max +")"


                }

                    ProgressBarAffectation {
                        anchors.left: informationsTour.right
                        anchors.top: informationsTour.top
                        anchors.topMargin: 2 // Pour etre centré au milieu verticalement
                        anchors.leftMargin: 10
                        width: 100
                        height: 8
                        valeurmin: min
                        valeurmax: max
                        valeur: nombre_affectations

                    }

                    MouseArea {
                       anchors.fill: parent
                       onClicked: {
                           console.log(id_tour);
                           app.setIdAffectation(id_tour);
                           listePersonnesInscritesBenevoles.model = app.affectations;
                           listePoste.currentIndex = index
                           blockFichePoste.titre = " <h2> " + nom + " </h2> "

                       }
                   }
                }


                section.property: "nom"
                section.criteria: ViewSection.FullString
                section.delegate: sectionHeading

                clip: true
                highlight: Rectangle { z:5; color: "blue"; radius: 5; opacity: 0.5; width: listePoste.width ; height:13 ;y: listePoste.currentItem.y}
                highlightFollowsCurrentItem: false
                focus: true



            }

            ScrollBar {
                flickable: listePoste
            }

            Component {
                id: sectionHeading
                Rectangle {
                    width: parent.width
                    height: 15
                    color: "lightsteelblue"

                    Text {
                        text: " " + section
                        font.bold: true
                    }
                }
            }
        }



        RectangleTitre {
            id: blockFichePoste
            anchors.top: blockListePosteTour.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.topMargin: 15
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            titre: "Liste des affectés"


            /*Text {
                id: _nomDuPoste
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 1
            } */

            ListView {

                id: listePersonnesInscritesBenevoles
                anchors.fill: parent
                anchors.left: parent.left
                anchors.leftMargin: 30
                anchors.top: parent.top
                anchors.topMargin: 20
                clip: true
                spacing: 5
                delegate: Text { text: "<b><font color='red'> X </font></b>" +prenom_personne + " " + nom_personne ;}
            }
            ScrollBar {
                flickable : listePersonnesInscritesBenevoles
            }



        }

    }


}



