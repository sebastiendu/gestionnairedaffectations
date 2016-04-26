import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Item {
    ColumnLayout {
        anchors.fill: parent

        ScrollView {
            flickableItem.interactive: true
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: liste
                model: app.affectations_acceptees_validees_ou_proposees_du_tour // FIXME : pourquoi cacher les "possibles" ?
                delegate: Rectangle {
                    property int _id_affectation: id_affectation
                    height: children[0].height
                    width: parent.width
                    RowLayout {
                        width: parent.width
                        Text {
                            text: index + 1
                        }
                        ColumnLayout {
                            spacing: 0
                            Layout.fillWidth: true

                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                text: prenom_personne + " " + nom_personne + (ville ? ", " + ville : "")
                                elide: Text.ElideRight
                            }

                            Text {
                                visible: commentaire_affectation != ""
                                Layout.fillWidth: true;
                                Layout.alignment: Qt.AlignHCenter
                                text: commentaire_affectation
                                elide: Text.ElideRight
                                wrapMode: Text.Wrap
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: liste.currentIndex = index
                            }
                        }
                        Button {
                            enabled: index == liste.currentIndex && statut_affectation != "rejetee" && statut_affectation != "annulee"
                            Layout.alignment: Qt.AlignRight
                            text: "-"
                            tooltip: "Annuler cette affectation"
                            onClicked: {
                                app.setIdAffectation(id_affectation); // par sécurité
                                // TODO : ouvrir une dialog pour confirmer le nom du participant et le nom du poste ainsi que début et fin du tour
                                // et permettre de modifier le commentaire
                                app.annulerAffectation("pas de commentaire");
                            }

                        }
                    }


                }
                section.property: "statut_affectation"
                section.delegate: Rectangle {
                    width: parent.width
                    height: children[0].height
                    color: "lightsteelblue"

                    Text {
                        text: "Affectation " + section
                        font.bold: true
                        color: (section == "acceptee" || section ==  "validee")
                               ? "green"
                               : (section == "rejetee" || section=="annulee")
                                 ? "red"
                                 : "orange"
                    }
                }
                highlight: Rectangle {
                    z: 5
                    color: "blue"
                    opacity: 0.5
                }
                focus: true
                Keys.onUpPressed: decrementCurrentIndex()
                Keys.onDownPressed: incrementCurrentIndex()
                onCurrentItemChanged: app.setIdAffectation(currentItem._id_affectation)
            }

        }

        Button {
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: 20
            Layout.fillWidth: true
            // TODO : visible: app.id_disponibilite defined and (id_disponibilite, id_tour) pas déjà dans affectation
            text: "+"
            tooltip: "Affecter ce participant à ce tour"
            // TODO : ouvrir une dialog pour confirmer le nom du participant et le nom du poste ainsi que début et fin du tour
            // et permettre de préciser un commentaire
            onClicked: app.creerAffectation("pas de commentaire");
        }
    }
}
