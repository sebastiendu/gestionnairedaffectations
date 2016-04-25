import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
//import fr.ldd.qml 1.0
import QtWebKit 3.0
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0

import "fonctions.js" as Fonctions

Item  {
    anchors.fill: parent

    Rectangle {
        id: affectations
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.fill: parent


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
                    model: app.disponibilite
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
                        Text { text: (age == null) ? 'Âge :\t' + age + " ans" : "" }
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
            source: "image://plan/" + app.idEvenement
            z:3

            Rectangle {

                id: rectangleAutourPlan
                anchors.top: plan.top
                anchors.topMargin: 0
                anchors.fill:parent
                color:"transparent"


                Repeater {
                    id: leRepeater
                    model: app.planCourant



                    delegate: Rectangle {
                        id: imageMarqueur
                        //source: "marqueurs/rouge.png"
                        x: (plan.width > plan.height) ? (posx * plan.height)+ ((plan.width-plan.height)/2) : posx * plan.width
                        y: (plan.width > plan.height) ? posy * plan.height : (posy * plan.width)+ ((plan.height-plan.width)/2)
                        height: (plan.width > plan.height) ? (70/1000) * plan.height : (70/1000) * plan.width
                        width: (plan.width > plan.height) ? (70/1000) * plan.width : (70/1000) * plan.width
                        radius: 100
                        border.width: 5
                        border.color: (nombre_affectations_validees_ou_acceptees > max) ? "red" : (nombre_affectations_validees_ou_acceptees < min) ? "grey" : (nombre_affectations_proposees != 0) ? "orange" : "green"

                        transform: Translate {
                            x: -width/2
                            y: -height/2
                        }


                        MouseArea {

                            hoverEnabled: true


                            onEntered : {
                                if(Fonctions.bulleClique == false) {
                                    allongerRectangle.start();
                                    elargirRectangle.start();
                                    remonterRectangle.start();
                                    app.setIdTour(id_tour);
                                    app.setIdPoste(id_poste);
                                    interieurCercle.model = app.affectations_acceptees_validees_ou_proposees_du_tour;
                                    fichePoste.model = app.fiche_poste;
                                    imageMarqueur.radius =5 ;
                                }
                            }

                            onExited : {
                                if(Fonctions.bulleClique == false) {
                                    retrecirRectangle.start();
                                    affinerRectangle.start();
                                    redescendreRectangle.start();
                                    app.setIdDisponibilite(-1);
                                    app.setIdTour(-1) ;
                                    app.setIdPoste(-1);
                                    imageMarqueur.radius =100}
                            }




                            NumberAnimation { id: allongerRectangle; target: imageMarqueur; property: "width"; to: 300; duration: 200}
                            NumberAnimation { id: elargirRectangle; target: imageMarqueur; property: "height"; to: 100; duration: 200}
                            NumberAnimation { id: derondirRectangle; target: imageMarqueur; property: "radius"; to: 5; duration: 200}
                            NumberAnimation { id: remonterRectangle; target: imageMarqueur; property: "z"; to: 200; duration: 200}

                            NumberAnimation { id: retrecirRectangle; target: imageMarqueur; property: "width"; to: Math.round((plan.width > plan.height) ? (70/1000) * plan.height : (70/1000) * plan.width); duration: 200}
                            NumberAnimation { id: affinerRectangle; target: imageMarqueur; property: "height"; to: Math.round((plan.width > plan.height) ? (70/1000) * plan.height : (70/1000) * plan.width); duration: 200}
                            NumberAnimation { id: redescendreRectangle; target: imageMarqueur; property: "z"; to: 100; duration: 200}



                            anchors.fill : parent


                        }



                        GridView {
                            id: interieurCercle
                            cellWidth: 15
                            cellHeight: 15
                            property int compteur: interieurCercle.count
                            //anchors.centerIn: parent
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 12
                            width: (parent.width - anchors.leftMargin)
                            height: parent.height -anchors.topMargin
                            anchors.topMargin: 12
                            clip: true




                            delegate: Rectangle {
                                color: Fonctions.couleurCercle(statut_affectation)
                                radius: 100
                                width: 13
                                height: 13
                                border.color: "black"
                                border.width: 1




                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("Il s'agit de : " + nom_personne);
                                        Fonctions.bulleClique = !(Fonctions.bulleClique);
                                        app.setIdDisponibilite(id_disponibilite);

                                    }
                                    z:105




                                }
                            }





                        }



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
                            app.setIdPosteTour(id_poste);
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
                        text: '<b><h2>' + Fonctions.heureMinutes(debut) + " - " + Fonctions.heureMinutes(fin) + "</h2></b><br>"
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
                leRepeater.model = app.planCourant;
                app.setIdPoste(-1)
                app.setIdTour(-1)
                _listeDesAffectes.text = ""
                Fonctions.bulleClique = false;

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
                    color: "green"
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
                            text: Fonctions.heureMinutes(app.heure)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

    }
}
