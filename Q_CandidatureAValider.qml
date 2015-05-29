import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtMultimedia 5.3

// import "fonctions.js" as Fonctions
Item {
    id: tab
    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
        color: "#bdc3c7"

        Connections {
            target: app
            onCandidatureValidee: {
               listView.model =  app.candidatures_en_attente;
                console.log("rechargement");
                ficheBenevole.model = null;
                sound.play();
            }

            onCandidatureRejetee: {
                listView.model =  app.candidatures_en_attente;
                ficheBenevole.model = null;
                // sadTrumpet.play()
            }
        }

        SoundEffect {
            id: sound
            volume: 0.3
            source: "Sound.wav"
        }

        BusyIndicator {
            id: chargement
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: parent.width/2 - 100
            anchors.topMargin: parent.height/2 - 30
            running: false
            z: 500

            style: Component {

                Item {
                Rectangle {
                    color: Qt.rgba(0,0,0,0.2)
                    width: 10000
                    height: 10000
                    transform: Translate { y: -5000; x:-5000 }
                    visible: chargement.running
                }

                Rectangle {
                    color: "white"
                    border.color: "black"
                    width: _texteChargement.width+50
                    height: 50
                    visible: chargement.running
                    Text {
                        id: _texteChargement
                        text: "Recherche de possibles doublons…"
                        visible: chargement.running
                        anchors.centerIn: parent
                    }


                }
            }
            }

        }

        Rectangle {
            id: rectangleCandidats
            color: "white"
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin:15
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
                anchors.topMargin:10
                anchors.bottom: rectangleCandidats.bottom
                anchors.bottomMargin: 10
                anchors.right: rectangleCandidats.right
                anchors.left: rectangleCandidats.left
                anchors.margins: 10
                clip: true



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
                                anchors.verticalCenter: parent.verticalCenter
                                Text { text: nom_personne + " " + prenom_personne }
                            }

                        }

                        MouseArea {
                            anchors.fill: parent;
                            onClicked:{

                                listView.currentIndex = index;
                                app.setIdDisponibilite(id_disponibilite);
                                ficheBenevole.model = app.fiche_benevole;
                                app.setIdDoublons(id_personne);
                                listeDoublons.model = app.personnes_doublons;

                            }

                            onEntered: {
                                chargement.running = true;
                            }

                            onExited: {
                                chargement.running = false;
                            }
                        }
                    }
                }


                ListView {
                    id: listView
                    anchors.fill: parent
                    anchors.margins: 5
                    model: app.candidatures_en_attente
                    delegate: listDelegate
                    highlight: Rectangle {visible: (listView.currentIndex == -1 ) ? false: true; z:5;color: Qt.rgba(0,0,1,0.5); radius: 5; opacity: 0.5; width: listView.width ; height:50; y: (listView.currentIndex == -1 ) ? 0: listView.currentItem.y;x: (listView.currentIndex == -1 ) ? 0: listView.currentItem.x}
                    focus: true
                    highlightFollowsCurrentItem: false
                }

                Component.onCompleted: {
                    listView.currentIndex = -1
                }

                ScrollBar {
                    flickable: listView;
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

            }

            Rectangle {

                id: blockFicheCandidat
                anchors.top: _ficheDuCandidatSelectionne.bottom
                anchors.topMargin: 15
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 100
                anchors.left: parent.left
                anchors.right: parent.right


                ListView {
                    id: ficheBenevole
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 5
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.left: parent.left
                    clip:true

                    delegate: Column {

                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            font.family: "Helvetica [Cronyx]";
                            text: "<img src='personne.png'/>     <b>" + prenom + " " + nom + "</b><br><br>";

                        }

                        Text {
                            font.family: "Helvetica [Cronyx]";
                            text: (commentaire_personne== "") ? "" : "<i>\" "+commentaire_personne+ " </i> \" <br><br>"
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            font.family: "Helvetica [Cronyx]";
                            text: (commentaire_disponibilite== "") ? "" : "<i>\" "+commentaire_disponibilite+ " </i> \" <br><br>"

                            wrapMode: Text.WordWrap
                        }

                        TextEdit { text: 'Inscription :\t' + date_inscription.toLocaleDateString(); readOnly: true}
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
                            text: 'Disponibilite : ' + commentaire_disponibilite
                            wrapMode: Text.WordWrap
                            width: parent.width}
                    }
                }

                Button {
                    id: boutonInscrireCeBenevole
                    anchors.top: blockFicheCandidat.bottom
                    anchors.topMargin: (parent.anchors.bottomMargin- height)/2
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    width: parent.width * 0.70 - 15
                    text: "Inscrire ce bénévole"
                    visible: (ficheBenevole.model) ? true: false
                    onClicked: app.validerCandidature();

            }

                Button {
                    id: boutonRejeter
                    anchors.top: blockFicheCandidat.bottom
                    anchors.topMargin: (parent.anchors.bottomMargin- height)/2
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    width: parent.width * 0.30 -10
                    text: "Rejeter"
                    visible: (ficheBenevole.model) ? true: false
                    onClicked: { app.rejeterCandidature() }
                }

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

            }

            Component {
                id: listDoublonsDelegate

                Rectangle {

                    id: cadreCandidat
                    width: parent.width
                    height: 50
                    color: Qt.rgba(0, 1, 0, score)
                    anchors.margins: 3

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 5
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
                            anchors.verticalCenter: parent.verticalCenter
                            Text { text: nom + " " + prenom }
                        }

                    }

                    MouseArea {
                        anchors.fill: parent;
                        onClicked:{
                            listeDoublons.currentIndex = index
                            app.setIdPersonne(id)
                            ficheDoublon.model = app.fiche_personne

                        }
                    }
                }
            }


            ListView {
                id: listeDoublons
                anchors.top: _doublonPossibles.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                delegate: listDoublonsDelegate

                focus: true
                clip: true
            }

            ScrollBar {
                flickable: listeDoublons
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

                }

                ListView {
                    id: ficheDoublon
                    anchors.top: _ficheDuDoublon.bottom
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 100
                    anchors.margins: 5
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.left: parent.left

                    clip:true

                    delegate: Column {

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.left: parent.left

                        Text {
                            font.family: "Helvetica [Cronyx]";
                            text: "<img src='personne.png'/>     <b>" + prenom + " " + nom + "</b><br><br>";

                        }

                        Text {
                            font.family: "Helvetica [Cronyx]";
                            text: (commentaire_personne== "") ? "" : "<i>\" "+commentaire_personne+ " </i> \" <br><br>"
                            wrapMode: Text.Wrap
                        }

                        Text {
                            font.family: "Helvetica [Cronyx]";
                            text: (commentaire_disponibilite== "") ? "" : "<i>\" "+commentaire_disponibilite+ " </i> \" <br><br>"

                            wrapMode: Text.Wrap
                        }

                        TextEdit { text: 'Inscription :\t' + date_inscription.toLocaleDateString(); readOnly: true}
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
                            text: 'Disponibilite : ' + commentaire_disponibilite
                            wrapMode: Text.WordWrap
                            width: parent.width}

                    }
                }

                Button {
                    anchors.top: ficheDoublon.bottom
                    anchors.topMargin: (ficheDoublon.anchors.bottomMargin - height)/2
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Inscrire cette fiche et rejeter l'autre"
                    visible: ficheDoublon.model ? true : false
                    onClicked : { }
                }


            }
        }
    }

