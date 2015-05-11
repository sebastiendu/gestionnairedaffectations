import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2


import "fonctions.js" as Fonctions
Item {
    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
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
