import QtQuick 2.3
import "fonctions.js" as Fonctions

Item {
    ListView {
        id: joursView
        anchors.fill: parent
        orientation: ListView.Horizontal
        model: app.sequence_emploi_du_temps
        delegate: Rectangle {
            height: parent.height
            width: proportion * parent.parent.width
            color: "transparent"
            Rectangle {
                anchors.centerIn: parent
                rotation: -90
                width: parent.height
                height: parent.width
                gradient: Gradient {
                    GradientStop {
                        position: 0;
                        color: "#8f8f8f";
                    }
                    GradientStop {
                        position: .25;
                        color: "#9f9f9f";
                    }
                    GradientStop {
                        position: .75;
                        color: "#9f9f9f";
                    }
                    GradientStop {
                        position: 1;
                        color: "#8f8f8f";
                    }
                }
                Text {
                    anchors.fill: parent
                    text: libelle_sequence
                    color: "lightgray"
                    font.bold: true
                    style: Text.Outline
                    styleColor: "gray"
                    fontSizeMode: Text.Fit
                    font.pixelSize: height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    ListView {
        id: listeTour
        anchors.fill: parent
        model: app.toursParPosteModel
        delegate: Component {
            Rectangle {
                gradient: Gradient {
                    GradientStop {
                        position: 0;
                        color: "#80808088";
                    }
                    GradientStop {
                        position: .25;
                        color: "#8f8f8f88";
                    }
                    GradientStop {
                        position: .75;
                        color: "#8f8f8f88";
                    }
                    GradientStop {
                        position: 1;
                        color: "#80808088";
                    }
                }
                height: parent.parent.height / (parent.parent.model.rowCount() + 1)
                width: parent.width
                Text {
                    anchors.fill: parent
                    text: nom
                    font.bold: true
                    style: Text.Outline
                    fontSizeMode: Text.Fit
                    font.pixelSize: height
                    color: "white"
                    styleColor: "gray"
                    font.letterSpacing: width / (20 * text.length)
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                Repeater {
                    model: tours // styleData.value
                    // 0 id, 1 debut, 2 durée, 3 min, 4 max, 5 debut, 6 fin, 7 effectif, 8 besoin, 9 faim, 10 taux, 11 id_poste
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: parent.width * modelData.split('|')[1] // debut
                        width: parent.width * modelData.split('|')[2] // durée
                        height: parent.height
                        radius: 5
                        //border.color: modelData.split('|')[10] === '100' ? "darkgreen" : modelData.split('|')[10] > 100 ? "#888800"  : "darkred" // taux
                        //border.width: modelData.split('|')[10] / 100
                        color: modelData.split('|')[9] === '0' ? "green" : modelData.split('|')[9] < 0 ? "red"  : "yellow" // faim
                        opacity: 0.75
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                fenetre.visible = true
                                console.info("setIdTour(" + modelData.split('|')[0] + ") (TODO)");
                                app.setIdTourPoste(modelData.split('|')[0]);

                                nomPoste.text = app.fiche_poste_tour.getDataFromModel(0,"nom");
                                date.text = Fonctions.dateTour(new Date(app.fiche_poste_tour.getDataFromModel(0,"debut")),new Date(app.fiche_poste_tour.getDataFromModel(0,"fin"))).trim();
                               // fin.text = app.fiche_poste_tour.getDataFromModel(0,"fin");

                                affectationsOk.text = (app.fiche_poste_tour.getDataFromModel(0,"nombre_affectations_validees_ou_acceptees") == "" ) ? "aucune" : app.fiche_poste_tour.getDataFromModel(0,"nombre_affectations_validees_ou_acceptees");
                                affectationsMax.text = "/ " + app.fiche_poste_tour.getDataFromModel(0,"max") + " (minimum: " + app.fiche_poste_tour.getDataFromModel(0,"min")+ ")";
                                affectationsProposees.text = "<i>"+ app.fiche_poste_tour.getDataFromModel(0,"nombre_affectations_proposees") +" affectations proposées </i>"
                            }
                        }
                    }
                }



                }
            }

    }

    Rectangle {
        id : fenetre
        visible: false
        color: "white"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: parent.height*0.20
        anchors.leftMargin: parent.width*0.25
        width: parent.width*0.50
        height: nomPoste.height + nomPoste.anchors.topMargin + date.height + date.anchors.topMargin + affectationsOk.height + affectationsOk.anchors.topMargin + affectationsProposees.height + affectationsProposees.anchors.topMargin + 10

        Text{
            visible: fenetre.visible
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.rightMargin: 10
            font.pixelSize: 18
            text: "X"

            MouseArea {
                anchors.fill: parent
                onClicked : fenetre.visible = false
            }
        }


            Text {
                id: nomPoste
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.left: parent.left
                anchors.leftMargin: parent.width/2 - width/2
                font.pixelSize: 18
                font.bold: true
            }

            Text {
                id: date
                anchors.top: nomPoste.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: parent.width/2 - width/2

            }

            Text {
                id: affectationsOk
                anchors.top: date.bottom
                anchors.topMargin:20
                anchors.left: parent.left
                anchors.leftMargin: parent.width/2 - (affectationsOk.width+affectationsMax.anchors.leftMargin+affectationsMax.width)/2
                font.pixelSize: 14
            }

            Text {
                id: affectationsMax
                anchors.top: affectationsOk.top
                anchors.left: affectationsOk.right
                anchors.leftMargin: 10
                font.pixelSize: 14
            }

            Text {

                id: affectationsProposees
                anchors.top: affectationsOk.bottom
                anchors.topMargin: 15
                anchors.left: parent.left
                anchors.leftMargin: parent.width/2 - width/2
            }



    }
}
