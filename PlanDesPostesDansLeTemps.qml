import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Item {

    ColumnLayout {
        anchors.fill: parent

        Image { // L'image du plan avec la représentation des postes

            Layout.fillWidth: true; Layout.fillHeight: true

            sourceSize { height: 1000; width: 1000 }
            fillMode: Image.PreserveAspectFit
            source: "image://plan/" + app.idEvenement

            Rectangle { // Rectangle autour du plan
                id: cadre

                property int cote: Math.min(parent.width, parent.height)

                width: cote; height: cote
                anchors.centerIn: parent

                color: "transparent"
                border { color: "black"; width: 1 }

                Repeater { // les postes sur le plan

                    model: app.planCourant
                    delegate: Rectangle { // le marqueur de position du poste
                        // TODO : revoir ces cercles de couleur pour représenter les mêmes informations que l'indicateur de remplissage de ListeDesTours
                        height: cadre.cote * 0.07
                        width: height
                        radius: height / 2
                        border.width: 5
                        border.color: nombre_affectations_validees_ou_acceptees > max
                                      ? "red"
                                      : nombre_affectations_validees_ou_acceptees < min
                                        ? "grey"
                                        : nombre_affectations_proposees > 0
                                          ? "orange"
                                          : "green"

                        y: posy * cadre.cote - height / 2
                        x: posx * cadre.cote - width / 2

                        MouseArea {
                            anchors.fill: parent

                            onClicked: app.setIdTour(id_tour)
                        }
                    }
                }
            }
        }

        Slider { // La ligne du temps
            Layout.fillWidth: true; Layout.preferredHeight: 20

            minimumValue: app.heureMin.getTime() // TODO : Arrondir à l'heure juste
            maximumValue: app.heureMax.getTime()
            stepSize: 3600000
            updateValueWhileDragging: true // TODO : evaluer si l'on a un accès rapide à la base
            onValueChanged: {
                app.heure = new Date(value);
                app.setIdPoste(-1); // aucun poste selectionné
                app.setIdTour(-1); // aucun tour selectionné
            }

            style: SliderStyle {
                groove: Rectangle { // TODO : remplacer ça par autant de rectangles que de périodes de temps et montrer le taux de remplissage avec la couleur
                    implicitWidth: 200; implicitHeight: 8
                    color: "green"
                }
                handle: Rectangle {
                    anchors.centerIn: parent
                    implicitWidth: 55; implicitHeight: 34

                    color: control.pressed ? "white" : "lightgray"
                    border { color: "gray"; width: 2 }
                    radius: 12

                    Rectangle { // la date et l'heure selectionnées
                        anchors.topMargin: 10
                        anchors.fill:parent
                        color: "transparent"
                        Text {
                            text: app.heure.toLocaleTimeString(null, { hours: "numeric", minutes: "2-digit" })
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}
