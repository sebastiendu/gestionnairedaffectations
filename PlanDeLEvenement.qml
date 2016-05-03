import QtQuick 2.0
import QtQuick.Controls 1.4

Image {
    id: image

    property var modeleListeDesPostes // id_poste, nom, min, max, nombre_affectations_*
    property var fonctionSelectionnerPoste: app.setIdPoste // (id_poste)
    property var fonctionAjouterPoste // (x, y)
    property var fonctionDeplacerPoste // (id_poste, x, y)
    property var fonctionSupprimerPoste // (id_poste)
    readonly property int cote: Math.min(width, height)

    sourceSize { height: 1000; width: 1000 }
    fillMode: Image.PreserveAspectFit
    source: "image://plan/" + app.idEvenement

    Rectangle {
        id: cadre

        width: cote; height: cote
        anchors.centerIn: parent

        color: "transparent"
        border { color: "black"; width: 1 }

        MouseArea {
            anchors.fill: parent
            onClicked: if (fonctionAjouterPoste) fonctionAjouterPoste(mouse.x/cote, mouse.y/cote)
            cursorShape: if (fonctionAjouterPoste) Qt.CrossCursor
        }

        Repeater {
            model: modeleListeDesPostes
            delegate: Rectangle {
                property int _id_poste: id_poste

                height: cote * 0.07
                width: height
                y: posy * cote - height / 2
                x: posx * cote - width / 2

                Rectangle { // TODO : Remplacer cette barre par des cercles concentriques
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

                Text {
                    anchors.fill: parent

                    text: nom
                    font.pixelSize: width/4
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton | Qt.LeftButton
                    cursorShape: fonctionDeplacerPoste
                                 ? drag.active
                                   ? Qt.DragMoveCursor
                                   : Qt.PointingHandCursor
                    : Qt.ArrowCursor
                    drag {
                        target: fonctionDeplacerPoste ? parent : null
                        minimumX: 0
                        minimumY: 0
                        maximumX: cadre.width  - parent.width
                        maximumY: cadre.height - parent.height
                    }

                    onReleased: if (drag.active) {
                                    fonctionDeplacerPoste(parent._id_poste, parent.x/cote, parent.y/cote);
                                } else if (mouse.button == Qt.LeftButton) {
                                    fonctionSelectionnerPoste(parent._id_poste);
                                }
                    onPressed: if (mouse.button == Qt.RightButton && fonctionSupprimerPoste) {
                                   contextMenu.popup();
                               }
                    Menu {
                        id: contextMenu

                        MenuItem {
                            text: qsTr("Supprimer")
                            onTriggered: fonctionSupprimerPoste(parent._id_poste);
                        }
                    }
                }
            }
        }
    }
}
