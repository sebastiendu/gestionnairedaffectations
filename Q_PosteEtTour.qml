import QtQuick 2.0
import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import fr.ldd.qml 1.0
import QtWebKit 3.0
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0

import "fonctions.js" as Fonctions

Item {

    anchors.fill: parent

    Rectangle {
        anchors.fill : parent

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

                // ICI ON MET LE PLAN SUR ECOUTE
                Connections {
                    target: app
                    onPlanCompletChanged: {
                        repeaterPostesEtTours.model = app.planComplet;
                    }
                }

                x: (parent.width - width)/2
                y: (parent.height - height)/2
                height: Fonctions.min(parent.width, parent.height)
                width: Fonctions.min(parent.width, parent.height)

                MouseArea {
                    id: mouseAreaPlan
                    anchors.fill: parent
                    onClicked: {

                        app.setRatioX(mouse.x/parent.width)
                        app.setRatioY(mouse.y/parent.height)

                        Fonctions.afficherFenetreNouveauPoste();

                        // Fonctions.createSpriteObjects(rectangleBordurePlan, mouse.x, mouse.y)
                    }

                    cursorShape: Qt.CrossCursor
                }

                Repeater {
                    id: repeaterPostesEtTours
                    objectName: "repeaterPostesEtTours"
                    model: app.planComplet


                    delegate: Rectangle {
                        z:1

                        Rectangle {
                            id: nomBulle
                            color: "white"
                            height: _nomDuPoste.height+3
                            width: _nomDuPoste.width+5
                            border.color: "black"
                            border.width: 1
                            y: imageMarqueurPostesEtTours.y + _nomDuPoste.height -1
                            x: imageMarqueurPostesEtTours.x + imageMarqueurPostesEtTours.width/2 - (_nomDuPoste.width/2) -3
                            radius: 3
                            z:150
                            Text {
                                id: _nomDuPoste
                                //text: nom.size < 10 ? (" "+nom+" ") : (" "+nom.substring(0,9) + "… ") // bug … ?
                                text: " "+nom+" "
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter

                            }
                        }

                        Rectangle {
                            id: imageMarqueurPostesEtTours

                            // Formule compliquée pour placer le marqueur correctement en prenant en compte la taille de l'écran
                            x: (rectangleBordurePlan.width > rectangleBordurePlan.height) ? ((posx * rectangleBordurePlan.height)+ ((rectangleBordurePlan.width-rectangleBordurePlan.height)/2) -imageMarqueurPostesEtTours.width/2) : ((posx * rectangleBordurePlan.width) -imageMarqueurPostesEtTours.width/2)
                            y: (rectangleBordurePlan.width > rectangleBordurePlan.height) ? ((posy * rectangleBordurePlan.height)-imageMarqueurPostesEtTours.height/2) : ((posy * rectangleBordurePlan.width)+ ((rectangleBordurePlan.height-rectangleBordurePlan.width)/2)  -imageMarqueurPostesEtTours.height/2)

                            // Fonction compliqué pour adapter la taille du marqueur à la taille de l'écran
                            height: (rectangleBordurePlan.width > rectangleBordurePlan.height) ? (70/1000) * rectangleBordurePlan.height : (70/1000) * rectangleBordurePlan.width
                            width: (rectangleBordurePlan.width > rectangleBordurePlan.height) ? (70/1000) * rectangleBordurePlan.width : (70/1000) * rectangleBordurePlan.width

                            radius: 100
                            border.width: 4
                            border.color: "red"


                            z:1

                            MouseArea {
                                id: mouseArea
                                anchors.fill: imageMarqueurPostesEtTours
                                acceptedButtons: Qt.RightButton | Qt.LeftButton
                                drag.target: parent
                                cursorShape: Qt.PointingHandCursor
                                drag.maximumX: rectangleBordurePlan.width
                                drag.minimumX: 0
                                drag.maximumY: rectangleBordurePlan.height
                                drag.minimumY: 0
                                z:100

                                onReleased: {


                                    app.setRatioX((imageMarqueurPostesEtTours.x/rectangleBordurePlan.width)+(imageMarqueurPostesEtTours.width/rectangleBordurePlan.width)/2)
                                    app.setRatioY((imageMarqueurPostesEtTours.y/rectangleBordurePlan.height)+(imageMarqueurPostesEtTours.height/rectangleBordurePlan.height)/2)
                                    app.modifierPositionPoste(posx,posy);
                                    imageMarqueurPostesEtTours.border.color = "red";
                                    imageMarqueurPostesEtTours.border.width= 4

                                }

                                onPressed: {
                                    app.setIdPoste(id);
                                    imageMarqueurPostesEtTours.border.color = "#3498db";
                                    imageMarqueurPostesEtTours.border.width= 5
                                    imageMarqueurPostesEtTours.z = 149;

                                    if(mouse.button == Qt.RightButton)
                                    {
                                        contextMenu.popup();

                                    }

                                    if(mouse.button == Qt.LeftButton)
                                    {
                                        _nomPoste.text = nom;
                                        _descriptionPoste.text = description;
                                        app.setIdPosteTour(id);
                                        tableauTours.model = app.fiche_poste_tour;
                                        imageMarqueurPostesEtTours.z = 149;
                                        nomBulle.z = 150;

                                    }
                                }



                            }
                            Menu {
                                id: contextMenu

                                MenuItem {
                                    text: qsTr("Supprimer")
                                    onTriggered: {
                                        app.rafraichirStatistiquePoste(id,nom);
                                        if (app.getNombreDeTours() != 0 || app.getNombreDAffectations() !=0)
                                        {
                                            Fonctions.afficherFenetreSupprimerPoste(id);
                                        }
                                        else
                                        {
                                            app.supprimerPoste(id);
                                        }

                                    }
                                }
                            }
                        }




                    }
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
            // border.color: "black"
            // border.width: 1

            Label {
                id : _nom
                text: "Poste:"
                anchors.top: parent.top
                anchors.left: parent.left

                anchors.margins: 10
            }

            TextField {
                id: _nomPoste
                placeholderText: "Nom du poste"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 10
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
                selectionMode: SelectionMode.SingleSelection
                itemDelegate :editableDelegate
                TableViewColumn{ role: "id_tour"  ; title: "id" ; width:(3*(tableauTours.width/10)); visible: true;delegate: nombre}
                TableViewColumn{ role: "debut"  ; title: "Debut du tour" ; width:(3*(tableauTours.width/10));delegate: debut}
                TableViewColumn{ role: "fin" ; title: "Fin du tour" ;width:(3*(tableauTours.width/10)); delegate: fin}
                TableViewColumn{ role: "min"  ; title: "Nb. min" ;width:(tableauTours.width/5); delegate: nombre}
                TableViewColumn{ role: "max" ; title: "Nb. max" ;width:(tableauTours.width/5); delegate: nombre}



                // TODO : - ERREUR :  Property 'getMonth' of object  is not a function
                // TODO : - ENREGISTRER DANS LA BASE LES INFORMATION
                // TODO : - RECHARGER LE MODEL AVEC ORDER BY
                // TODO : - RECUPERER LE ID CORRECTEMENT


                Component {
                    id: debut

                    Item {

                        TextInput {
                            id: inputDate
                            anchors.fill: parent
                            text: Fonctions.dateFR(styleData.value)
                            onAccepted: console.log("debut: "+styleData.value +  styleData.row.id_tour  + styleData.id_tour+ " " + id_tour.value + " " + id.value)


                        }

                         MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("clic");
                                tableauTours.selection.clear();
                                tableauTours.selection.select(styleData.row );
                                inputDate.positionAt(mouseX,mouseY);
                                inputDate.forceActiveFocus();
                                //  inputDate.color = "white"

                            }
                        }





                    }

                }

                Component {
                    id: fin

                    Item {


                        TextInput {
                            id: inputDate
                            anchors.fill: parent
                            text: Fonctions.dateFR(styleData.value)
                            onAccepted: console.log("fin: " + styleData.value + " " + inputDate.text + " " + styleData.role + " " + styleData.row + " " + styleData.column)


                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("clic");
                                tableauTours.selection.clear();
                                tableauTours.selection.select(styleData.row );
                                inputDate.positionAt(mouseX,mouseY);
                                inputDate.forceActiveFocus();
                                //  inputDate.color = "white"

                            }
                        }




                    }

                }



                Component {
                    id: nombre

                    Item {



                        TextInput
                        {
                            id: nouveauNombre
                            anchors.fill: parent
                            text: styleData.value
                            // activeFocusOnPress: false
                            //   selectByMouse: true
                            onAccepted: console.log(styleData.value + " " +nouveauNombre.text)

                        }

                        MouseArea {
                            id: zoneSelection
                            anchors.fill: parent
                            onClicked: {
                                console.log("clic");
                                tableauTours.selection.clear();
                                tableauTours.selection.select(styleData.row );

                                nouveauNombre.forceActiveFocus();

                            }
                        }

                    }
                }

            }

            Button {
                id: _btnAjouterTour
                text: "+"
                anchors.top: tableauTours.bottom
                anchors.right: _btnSupprimerTour.left
                anchors.topMargin: 5
                onClicked: { Fonctions.afficherFenetreAjouterTour() }
            }

            Button {
                id: _btnSupprimerTour
                text: "-"
                anchors.top: tableauTours.bottom
                anchors.right: parent.right
                anchors.topMargin: 5
                anchors.rightMargin: 15
            }



        }





    }
}
