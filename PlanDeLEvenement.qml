import QtQuick 2.5
import QtQuick.Controls 1.4

Image {
    id: image

    property var modeleListeDesPostes // id_poste, nom, min, max, nombre_affectations_*
    property bool modifiable: false
    readonly property int cote: Math.min(width, height)

    sourceSize { height: 1000; width: 1000 }
    fillMode: Image.PreserveAspectFit
    source: "image://plan/" + app.id_evenement

    Rectangle {
        id: cadre

        width: cote; height: cote
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
                app.supprimerPoste();
                event.accepted = true
            }
        }

        Repeater {
            model: modeleListeDesPostes
            delegate: Rectangle {
                property int _id_poste: id_poste

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
                            onTriggered: app.supprimerPoste();
                        }
                    }

                    onReleased: if (drag.active) {
                                    app.fiche_du_poste.setData(0, "posx", (parent.x + parent.width /2) / cote);
                                    app.fiche_du_poste.setData(0, "posy", (parent.y + parent.height/2) / cote);
                                    app.enregistrerPoste();
                                }
                    onPressed: {
                        app.setIdPoste(parent._id_poste); // TODO: essayer [[view.]model.]id_poste
                        if (mouse.button == Qt.RightButton && modifiable) {
                            contextMenu.popup();
                        }
                    }
                }
            }
        }
    }
}
