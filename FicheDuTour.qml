import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4

Item {
    ListView {
        interactive: false
        anchors.fill: parent
        model: app.tour
        clip: true

        delegate: GridLayout {
            width: parent.width
            columns: 2;
            columnSpacing: 2
            rowSpacing: 2

            Text {
                text: "Poste"
            }

            Text {
                id: _id_poste
                Layout.fillWidth: true
                text: id_poste
            }

            Text {
                text: "Début"
            }

            Text {
                id: _debut
                Layout.fillWidth: true
                text: debut
            }

            Text {
                text: "Fin"
            }

            Text {
                id: _fin
                Layout.fillWidth: true
                text: fin
            }

            Text {
                text: "Minimum"
            }

            Text {
                id: _min
                Layout.fillWidth: true
                text: min
            }

            Text {
                text: "Maximum"
            }

            Text {
                id: _max
                Layout.fillWidth: true
                text: max
            }

            Text {
                text: "Participants affectés"
            }

            Button {
                // TODO : visible: app.id_tour defined and app.id_disponibilite defined and (id_disponibilite, id_tour) pas déjà dans affectation
                text: "+"
                tooltip: "Affecter ce participant à ce tour"
                // TODO : ouvrir une dialog pour confirmer le nom du participant et le nom du poste ainsi que début et fin du tour
                // et permettre de préciser un commentaire
                onClicked: app.creerAffectation("pas de commentaire");
            }

            ScrollView {
                flickableItem.interactive: true
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 2
                ListView {
                    id: listeDesAffectations
                    model: app.affectations_acceptees_validees_ou_proposees_du_tour // FIXME : pourquoi cacher les "possibles" ?
                    clip: true
                    focus: true
                    Keys.onUpPressed: decrementCurrentIndex()
                    Keys.onDownPressed: incrementCurrentIndex()
                    onCurrentItemChanged: app.setIdAffectation(currentItem._id_affectation)

                    delegate: RowLayout {
                        property int _id_affectation: id_affectation

                        Text {
                            text: (index + 1) + "/" + max + " : " + prenom_personne + " " + nom_personne + (ville ? ", " + ville : "")
                            MouseArea {
                                anchors.fill: parent
                                onClicked: listeDesAffectations.currentIndex = index
                            }
                        }

                        Text {
                            text: commentaire_affectation
                            clip: true
                        }

                        Button {
                            visible: index == listeDesAffectations.currentIndex
                            text: "-"
                            tooltip: "Annuler cette affectation"
                            // TODO : ouvrir une dialog pour confirmer le nom du participant et le nom du poste ainsi que début et fin du tour
                            // et permettre de modifier le commentaire
                            onClicked: app.annulerAffectation("pas de commentaire");
                        }

                    }
                    section.property: "statut_affectation"
                    section.delegate: Text {
                        text: "Affectation " + section
                        font.bold: true
                        color: (section == "acceptee" || section ==  "validee")
                               ? "green"
                               : (section == "rejetee" || section=="annulee")
                                 ? "red"
                                 : "orange"
                    }
                    highlight: Rectangle {
                        color: "blue"
                        opacity: 0.5
                        width: listeDesAffectations.width
                        height: 13
                    }

                }

            }

        }

    }

}
