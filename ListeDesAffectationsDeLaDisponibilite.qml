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
                model: app.liste_des_affectations_de_la_disponibilite
                delegate: Rectangle {
                    property int _id_affectation: id_affectation
                    height: children[0].height
                    width: parent.width
                    RowLayout {
                        width: parent.width
                        ColumnLayout {
                            spacing: 0
                            Layout.fillWidth: true
                            RowLayout {
                                width: parent.width

                                Text {
                                    Layout.fillWidth: true
                                    text: nom_poste + " de " + heure_debut + " à " + heure_fin + " (" + duree + ")"
                                    font.bold: true
                                    // TODO affichage de description_poste avec un petit [+] ? ou la fiche complete du poste
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Affectation " + statut_affectation +
                                          (statut_affectation == "proposee"
                                           ? " " + date_et_heure_proposee
                                           : "")
                                    color: (statut_affectation == "acceptee" || statut_affectation ==  "validee")
                                           ? "green"
                                           : (statut_affectation == "rejetee" || statut_affectation=="annulee")
                                             ? "red"
                                             : "orange"
                                    font.strikeout: statut_affectation == "rejetee" || statut_affectation == "annulee"
                                }
                            }

                            Text {
                                visible: commentaire_affectation != ""
                                Layout.fillWidth: true;
                                text: commentaire_affectation
                                horizontalAlignment: Text.AlignRight
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
                section.property: "date_debut"
                section.delegate: Rectangle {
                    width: parent.width
                    height: children[0].height
                    color: "lightsteelblue"
                    Text {
                        text: section // FIXME : date au format long
                        font.bold: true
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
