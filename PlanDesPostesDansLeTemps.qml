import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Item {

    ColumnLayout {
        anchors.fill: parent

        PlanDeLEvenement { // L'image du plan avec la représentation des postes
            Layout.fillWidth: true; Layout.fillHeight: true
            modeleListeDesPostes: app.proxy_de_la_liste_des_postes_de_l_evenement_par_heure
        }

        Text { // Date et heure selectionnées
            Layout.fillWidth: true; Layout.preferredHeight: 20
            text: qsTr("Le %1 à %2")
            .arg(app.heure.toLocaleDateString())
            .arg(app.heure.toLocaleTimeString(null, { hour: "numeric", minute: "2-digit" }))
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Slider { // La ligne du temps
            Layout.fillWidth: true;
            Layout.preferredHeight: 50
            Layout.minimumHeight: 10

            maximumValue: app.remplissage_par_heure.rowCount() - 1
            stepSize: 1
            onValueChanged: {
                app.heure = app.remplissage_par_heure.getDataFromModel(value, "heure");
                app.setIdPoste(-1); // aucun poste selectionné
                app.setIdTour(-1); // aucun tour selectionné
            }
            style: SliderStyle {
                groove: RowLayout {
                    spacing: 0
                    height: parent.parent.height

                    Repeater {
                        model: app.remplissage_par_heure

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Rectangle {
                                width: parent.height
                                height: parent.width
                                transform: Rotation { angle: -90; origin { x: height/2; y: height/2 } }

                                ProgressBarAffectation {
                                    anchors.fill: parent
                                    acceptees: nombre_affectations_validees_ou_acceptees
                                    proposees: nombre_affectations_proposees
                                    possibles: nombre_affectations_possibles
                                    minimum: min
                                    maximum: max
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
