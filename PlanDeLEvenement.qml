import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

Rectangle {
    property var modeleListeDesPostes // id_poste, nom, min, max, nombre_affectations_*
    property bool modifiable: false
    readonly property real cote: Math.min(image.width, image.height)

    color: "#333333"
    implicitHeight: children[0].implicitHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        Label {
            Layout.fillWidth: true
            text: qsTr("Plan de %1").arg(app.fiche_de_l_evenement.data(0,"nom"))
            font.pointSize: 16
            color: "#CCCCCC"
        }

        Image {
            id: image

            function supprimerPoste() {
                if (
                        app.liste_des_postes_de_l_evenement.data(app.liste_des_postes_de_l_evenement.getIndexFromId(app.id_poste), "nombre_tours")
                        +
                        app.liste_des_postes_de_l_evenement.data(app.liste_des_postes_de_l_evenement.getIndexFromId(app.id_poste), "nombre_affectations")
                        > 0 ) {
                    demandeDeConfirmation.open();
                } else {
                    app.supprimerPoste();
                }
            }

            Layout.preferredWidth: cote
            Layout.preferredHeight: cote
            Layout.fillHeight: true
            Layout.fillWidth: true
            sourceSize { height: 1000; width: 1000 }
            fillMode: Image.PreserveAspectFit
            source: "image://plan/" + app.id_evenement

            Rectangle {
                id: cadre

                implicitHeight: cote
                implicitWidth : cote
                anchors.centerIn: parent

                color: "transparent"
                border { color: "black"; width: 1 }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: if (modifiable) Qt.CrossCursor
                    onClicked: if (modifiable) {
                                   app.setIdPoste(-1);
                                   app.fiche_du_poste.insertRows(0, 1);
                                   app.fiche_du_poste.setData(0, "posx", mouse.x/cote);
                                   app.fiche_du_poste.setData(0, "posy", mouse.y/cote);
                                   // TODO montrer la position du nouveau poste sur le plan
                               }
                }

                Keys.onDeletePressed: { // FIXME : n'arrive jamais
                    if (modifiable && app.id_poste) {
                        supprimerPoste();
                        event.accepted = true
                    }
                }

                Repeater {
                    model: modeleListeDesPostes
                    delegate: Rectangle {
                        property int _id_poste: id_poste
                        property int _id_tour: model.id_tour ? id_tour : 0

                        height: cote * 0.08
                        width: cote * 0.08
                        y: posy * cote - height / 2
                        x: posx * cote - width / 2

                        border.width: 1
                        border.color: app.id_poste === id_poste ? "#77FF77" : "#007700"
                        color: app.id_poste === id_poste ? "#FFFF77" : "#777700"
                        radius: height/2

                        Rectangle { // TODO : Remplacer cette barre par des cercles concentriques
                            width: parent.height/2
                            height: parent.width/2
                            anchors.centerIn: parent
                            transform: Rotation { angle: -90; origin { x: width/4; y: height/4 } }

                            ProgressBarAffectation {
                                anchors.fill: parent
                                acceptees: nombre_affectations_validees_ou_acceptees
                                proposees: nombre_affectations_proposees
                                possibles: nombre_affectations_possibles
                                minimum: min
                                maximum: max
                            }
                        }

                        Text {
                            anchors.fill: parent

                            text: nom
                            font.pixelSize: height/4

                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton | Qt.LeftButton
                            cursorShape: modifiable
                                         ? drag.active
                                           ? Qt.DragMoveCursor
                                           : Qt.PointingHandCursor
                            : Qt.ArrowCursor
                            drag {
                                target: modifiable ? parent : null
                                minimumX: 0
                                minimumY: 0
                                maximumX: cadre.width  - parent.width
                                maximumY: cadre.height - parent.height
                            }

                            Menu {
                                id: contextMenu

                                MenuItem {
                                    text: qsTr("Supprimer")
                                    onTriggered: supprimerPoste();
                                }
                            }

                            onReleased: if (drag.active) {
                                            app.fiche_du_poste.setData(0, "posx", (parent.x + parent.width /2) / cote);
                                            app.fiche_du_poste.setData(0, "posy", (parent.y + parent.height/2) / cote);
                                            app.enregistrerPoste();
                                        }
                            onPressed: {
                                app.setIdPoste(parent._id_poste); // TODO: essayer [[view.]model.]id_poste
                                if (parent._id_tour) app.setIdTour(parent._id_tour);
                                if (mouse.button == Qt.RightButton && modifiable) {
                                    contextMenu.popup();
                                }
                            }
                        }
                    }
                }
            }

            MessageDialog {
                id: demandeDeConfirmation
                modality: Qt.ApplicationModal
                title: "Suppression d'un poste avec des tours"
                icon: StandardIcon.Warning
                text: qsTr("Faut-il vraiment supprimer le poste %1 avec ses tours et affectations ?")
                .arg(app.fiche_du_poste.data(0, "nom"))
                informativeText: qsTr("Ce poste a %1 tours de travail et %2 affectations.")
                .arg(app.liste_des_postes_de_l_evenement.data(app.liste_des_postes_de_l_evenement.getIndexFromId(app.id_poste), "nombre_tours"))
                .arg(app.liste_des_postes_de_l_evenement.data(app.liste_des_postes_de_l_evenement.getIndexFromId(app.id_poste), "nombre_affectations"))
                standardButtons: StandardButton.Yes | StandardButton.No
                onYes: app.supprimerPoste();
            }
        }
    }
}
