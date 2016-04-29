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
                model: app.affectations_du_tour
                delegate: Rectangle {
                    property int _id_affectation: id_affectation
                    height: children[0].height
                    width: parent.width

                    ColorAnimation on color {
                        duration: 1000
                        from: "red"
                        to: color
                        running: app.id_affectation == id_affectation
                        alwaysRunToEnd: true
                    }

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
                                text: qsTr("%1 %2%3")
                                .arg(prenom_personne)
                                .arg(nom_personne)
                                .arg(ville ? qsTr(", %1").arg(ville) : "")
                                font.bold: true
                                elide: Text.ElideRight
                                font.strikeout: statut_affectation == "rejetee" || statut_affectation == "annulee"
                                color: (statut_affectation == "acceptee" || statut_affectation ==  "validee")
                                       ? "green"
                                       : (statut_affectation == "rejetee" || statut_affectation=="annulee")
                                         ? "red"
                                         : "orange"
                            }

                            Text {
                                Layout.fillWidth: true;
                                Layout.alignment: Qt.AlignHCenter
                                text: statut_affectation == "possible"
                                      ? qsTr("Affectation possible")
                                      : statut_affectation == "proposee"
                                        ? qsTr("Affectation proposée le %1").arg(date_et_heure_proposee.toLocaleDateString())
                                        : statut_affectation == "validee"
                                          ? qsTr("Affectation validée")
                                          : statut_affectation == "acceptee"
                                            ? qsTr("Affectation acceptée")
                                            : statut_affectation == "refusee"
                                              ? qsTr("Affectation refusée")
                                              : qsTr("Affectation annulée")
                                font.pointSize: 7
                            }

                            Text {
                                visible: commentaire_affectation != ""
                                Layout.fillWidth: true;
                                text: commentaire_affectation
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                wrapMode: Text.Wrap
                                font.pointSize: 7
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: liste.currentIndex = index
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
                        text: section == "possible"
                              ? qsTr("Affectations possibles")
                              : section == "proposee"
                                ? qsTr("Affectations proposées")
                                : section == "validee"
                                  ? qsTr("Affectations validées")
                                  : section == "acceptee"
                                    ? qsTr("Affectations acceptées")
                                    : section == "refusee"
                                      ? qsTr("Affectations refusées")
                                      : qsTr("Affectations annulées")
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

    }

}
