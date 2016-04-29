import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Item { // TODO : implémenter plusieurs etats pour ce composant : "par poste", "par date de debut", "par taux de remplissage"
    ColumnLayout {
        anchors.fill: parent;

        TextField {
            Layout.fillWidth: true
            onEditingFinished: liste.model.setFilterFixedString(text);
            placeholderText: "Recherche de postes et tours"
        }

        ScrollView { // contient la liste des postes et des tours
            flickableItem.interactive: true
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: liste
                model: app.proxy_de_la_liste_des_tours_de_l_evenement
                cacheBuffer: 800
                delegate: Rectangle { // une ligne pour chaque tour du poste
                    property int _id_tour: id_tour
                    height: children[0].height
                    width: parent.width

                    RowLayout {
                        width: parent.width

                        Text { // date et heure début et fin
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            text: debut.toLocaleDateString()
                                  + " de " + debut.toLocaleTimeString(null, {hour: "2-digit", minute: "2-digit"})
                                  + " à " + fin.toLocaleTimeString(null, {hour: "2-digit", minute: "2-digit"})
                                  + " (" + (new Date(0,0,0,0,0,0,fin-debut)).toLocaleTimeString(null, {hour: "numeric", minute: "2-digit"}) + ")"
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideLeft
                        }

                        ProgressBarAffectation {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 5
                            acceptees: nombre_affectations_validees_ou_acceptees
                            proposees: nombre_affectations_proposees
                            possibles: nombre_affectations_possibles
                            minimum: min
                            maximum: max
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: liste.currentIndex = index
                    }
                }
                section.property: "nom"
                section.delegate: Rectangle { // une ligne d'entête pour chaque poste
                    width: parent.width
                    height: children[0].height
                    color: "lightsteelblue"

                    Text {
                        text: section
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
                onCurrentItemChanged: app.setIdTour(currentItem._id_tour);
            }
        }
    }
}
