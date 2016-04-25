import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.2

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

        TextField {
            id: posteEtToursRecherche
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            onEditingFinished: app.poste_et_tour.setFilterFixedString(text);
            placeholderText: "Recherche de postes et tours"

        }

        ScrollView { // contient la liste des postes et des tours
            id: blockListePosteTour
            anchors.top: posteEtToursRecherche.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            anchors.bottom: parent.verticalCenter
            flickableItem.interactive: true

            ListView {
                id: listeDesToursParPoste
                anchors.fill: parent
                model: app.poste_et_tour
                cacheBuffer: 800
                delegate: Rectangle { // une ligne pour chaque tour du poste
                    property int v_id_tour: id_tour
                    height: 13
                    z: 1
                    width: parent.width

                    RowLayout { // 3 cellules sur la même ligne
                        spacing: 2
                        width: parent.width

                        Text { // date et heure début et fin
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            text: Fonctions.dateTour(debut,fin)
                            horizontalAlignment: Text.AlignRight
                            clip: true
                            Layout.preferredWidth: parent.width / 3

                        }

                        Text { // nombre d'affectations, min et max
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            text: (nombre_affectations_validees_ou_acceptees + nombre_affectations_proposees) +
                                  "/" + max +
                                  " (min: " + min + ", max: " + max +")" // TODO fusionner avec la progressbar ci-dessous
                            horizontalAlignment: Text.AlignHCenter
                            clip: true
                            Layout.preferredWidth: parent.width / 3
                        }

                        ProgressBarAffectation {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            valeurmin: min
                            valeurmax: max
                            valeur: nombre_affectations_validees_ou_acceptees + nombre_affectations_proposees
                            certain: nombre_affectations_proposees == 0
                            Layout.preferredWidth: parent.width / 3
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: listeDesToursParPoste.currentIndex = index
                    }
                }
                section.property: "nom"
                section.criteria: ViewSection.FullString
                section.delegate: Rectangle { // une ligne d'entête pour chaque poste
                    width: parent.width
                    height: 15
                    color: "lightsteelblue"

                    Text {
                        text: section
                        font.bold: true
                    }
                }
                clip: true
                highlight: Rectangle {
                    z: 5
                    color: "blue"
                    opacity: 0.5
                    width: parent.width
                    height: 13
                }
                focus: true // FIXME : on n'a jamais le focus ! (sauf en faisant Tab mais alors toute la listview disparait)
                Keys.onUpPressed: { decrementCurrentIndex(); console.log("up"); } // FIXME
                Keys.onDownPressed: { incrementCurrentIndex(); console.log("down"); } // FIXME
                onCurrentItemChanged: app.setIdTour(currentItem.v_id_tour);
            }
        }

        Button {
            id: _boutonEnvoyer // TODO : Renommer
            anchors.top: blockListePosteTour.bottom
            anchors.topMargin: blockFichePoste.height/3
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



        RectangleTitre {
            id: blockFichePoste
            anchors.top: blockListePosteTour.bottom
            anchors.left: _boutonEnvoyer.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.topMargin: 15
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            titre: " <h2> Poste numéro " + listeDesToursParPoste.currentItem.v_id_poste + " </h2> "


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
                model: app.affectations_acceptees_validees_ou_proposees_du_tour

                clip: true
                spacing: 5
                delegate: Text {
                    text: prenom_personne + " " + nom_personne
                    font.bold: true
                    color: (statut_affectation == "acceptee" ||statut_affectation ==  "validee") ? "green" : (statut_affectation == "rejetee" || statut_affectation=="annulee") ? "red" : "orange"
                    MouseArea {
                        anchors.fill: parent
                        onClicked : {
                            listePersonnesInscritesBenevoles.currentIndex = index;
                            console.log("id_disponibilte: " + id_disponibilite)
                            app.setIdDisponibilite(id_disponibilite);


                        }
                    }
                }
                highlight: Rectangle { visible: (listePersonnesInscritesBenevoles.currentIndex == -1)? false: true; z: 5; color: "blue"; radius: 5; opacity: 0.5; width: listePersonnesInscritesBenevoles.width ; height:13 ;y: (listePersonnesInscritesBenevoles.currentIndex == -1)? 0:listePersonnesInscritesBenevoles.currentItem.y}
                highlightFollowsCurrentItem: false

                focus: true

            }
            ScrollBar {
                flickable : listePersonnesInscritesBenevoles
            }



        }

    }


}



