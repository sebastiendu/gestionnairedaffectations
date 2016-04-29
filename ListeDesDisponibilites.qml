import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Item { // TODO : plusieurs états : "selon le nombre d'affectations (les sans-tour en premier)", "alphabétique" (ViewSection.FirstCharacter)
    ColumnLayout {
        anchors.fill: parent;

        TextField {
            Layout.fillWidth: true
            onEditingFinished: liste.model.setFilterFixedString(text);
            placeholderText: qsTr("Recherche de participants disponibles")
        }

        ScrollView { // contient la liste des disponibles
            flickableItem.interactive: true
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: liste
                model: app.proxy_de_la_liste_des_disponibilites_de_l_evenement
                cacheBuffer: 800
                delegate: Rectangle {
                    property int _id_disponibilite: id_disponibilite
                    height: children[0].height
                    width: parent.width

                    Text {
                        width: parent.width
                        text: qsTr("%1 %2%3")
                        .arg(prenom_personne)
                        .arg(nom_personne)
                        .arg(ville ? qsTr(", %1").arg(ville) : "")
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: liste.currentIndex = index
                    }
                }
                section.property: "nombre_affectations"
                section.delegate: Rectangle {
                    width: parent.width
                    height: children[0].height
                    color: "lightsteelblue"

                    Text {
                        text: section == 0
                              ? qsTr("Participants disponibles sans affectation")
                              : section == 1
                                ? qsTr("Participants déjà affectés à un tour de travail")
                                : qsTr("Participants déjà affectés à %1 tours de travail").arg(section)
                        font.bold: true
                    }
                }
                highlight: Rectangle {
                    width: liste.currentItem.width
                    height: liste.currentItem.height
                    z: 5
                    color: "blue"
                    opacity: 0.5
                    y: liste.currentItem.y
                }
                highlightFollowsCurrentItem: false
                focus: true
                Keys.onUpPressed: decrementCurrentIndex()
                Keys.onDownPressed: incrementCurrentIndex()
                onCurrentItemChanged: app.setIdDisponibilite(currentItem._id_disponibilite);
            }
        }
    }
}
