import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Item {
    ColumnLayout {
        anchors.fill: parent;
        spacing: 2;

        TextField {
            Layout.fillWidth: true
            onEditingFinished: liste.model.setFilterFixedString(text);
            placeholderText: "Recherche de participants disponibles"
            Layout.preferredHeight: 14
        }

        ScrollView { // contient la liste des disponibles
            flickableItem.interactive: true
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: liste
                anchors.fill: parent
                model: app.benevoles_disponibles
                cacheBuffer: 800
                delegate: Rectangle {
                    property int _id_disponibilite: id_disponibilite
                    height: 13
                    width: parent.width

                    RowLayout { // nom et ville TODO
                        spacing: 2
                        width: parent.width

                        Text { // prenom et nom
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            text: prenom_personne + ' ' + nom_personne
                            clip: true
                            Layout.preferredWidth: parent.width * 2 / 3
                        }

                        Text { // ville
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            text: ville
                            clip: true
                            Layout.preferredWidth: parent.width / 3
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: liste.currentIndex = index
                    }
                }
                section.property: "nombre_affectations"
                section.delegate: Rectangle {
                    width: parent.width
                    height: 15
                    color: "lightsteelblue"

                    Text {
                        text: "Participants disponibles " + (
                                  section == 0 ? "sans affectation" :
                                                 section == 1 ? "déjà affectés à un tour de travail" :
                                                                "déjà affectés à " + section + " tours de travail"
                                  )
                        font.bold: true
                    }
                }
                clip: true
                highlight: Rectangle {
                    z: 5
                    color: "blue"
                    opacity: 0.5
                    height: 13
                }
                focus: true
                Keys.onUpPressed: decrementCurrentIndex()
                Keys.onDownPressed: incrementCurrentIndex()
                onCurrentItemChanged: app.setIdDisponibilite(currentItem._id_disponibilite);
            }
        }
    }
}
