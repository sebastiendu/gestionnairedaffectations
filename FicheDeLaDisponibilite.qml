import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Rectangle {
    color: "#333333"
    implicitWidth: 350 // TODO pas codé en dur
    implicitHeight: children[0].implicitHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        Label {
            text: qsTr("Fiche de la disponibilité")
            font.pointSize: 16
            color: "#CCCCCC"
        }

        ListView {
            Layout.fillWidth: true
            implicitHeight: 200 // TODO pas codé en dur
            interactive: false
            model: app.fiche_de_la_disponibilite
            delegate: GridLayout {
                width: parent.width
                columns: 2
                columnSpacing: 2
                rowSpacing: 2

                Text {
                    text: "Inscription"
                }
                Text {
                    text: date_inscription.toLocaleDateString()
                    Layout.fillWidth: true
                }

                Text {
                    text: "Amis"
                    visible: liste_amis != ""
                }
                Text {
                    text: liste_amis
                    visible: liste_amis != ""
                }

                Text {
                    text: "Type de poste"
                    visible: type_poste != ""
                }
                Text {
                    text: type_poste
                    visible: type_poste != ""
                }

                Text {
                    text: "Commentaire"
                    visible: commentaire != ""
                }
                Text {
                    text: commentaire
                    visible: commentaire != ""
                }

                Text {
                    text: "Statut"
                }
                Text {
                    text: statut
                }
            }
        }
    }
}
