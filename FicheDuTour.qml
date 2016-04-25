import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4

Item {
    ListView { // juste une ligne avec la fiche du tour (pour pouvoir avoir un model)
        interactive: false
        anchors.fill: parent
        model: app.tour
        clip: true
        spacing: 2
        height: 300
        width: 300

        delegate: GridLayout {
            width: parent.width
            columns: 2;
            columnSpacing: 2
            rowSpacing: 2
            height: 300

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

            ScrollView { // avec la liste de affectations
                flickableItem.interactive: true
                Layout.fillHeight: true
                Layout.fillWidth: true
                ListView {
                    id: listeDesAffectations
                    model: app.affectations_acceptees_validees_ou_proposees_du_tour
                    clip: true

                    delegate: Text {
                        property int _id_affectation: id_affectation
                        height: 13
                        z: 1
                        width: parent.width
                        text: prenom_personne + " " + nom_personne
                        font.bold: true
                        color: (statut_affectation == "acceptee" ||statut_affectation ==  "validee") ? "green" : (statut_affectation == "rejetee" || statut_affectation=="annulee") ? "red" : "orange"

                        MouseArea {
                            anchors.fill: parent
                            onClicked : listeDesAffectations.currentIndex = index;
                        }
                    }
                    highlight: Rectangle {
                        z: 5
                        color: "blue"
                        opacity: 0.5
                        width: listeDesAffectations.width
                        height: 13
                    }
                    focus: true
                    Keys.onUpPressed: decrementCurrentIndex()
                    Keys.onDownPressed: incrementCurrentIndex()
                    onCurrentItemChanged: app.setIdAffectation(currentItem._id_affectation)
                }

            }

        }

    }

}
