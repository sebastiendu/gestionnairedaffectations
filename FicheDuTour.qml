import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

Item {
    ListView {
        interactive: false
        model: app.fiche_du_tour
        delegate: GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: 2
            rowSpacing: 2

            Text {
                text: "Poste"
                Layout.preferredWidth : parent.width / 2
            }
            Text {
                text: nom
                Layout.preferredWidth : parent.width / 2
            }

            Text {
                text: "Début"
            }
            Text {
                Layout.fillWidth: true
                text: debut
            }

            Text {
                text: "Fin"
            }
            Text {
                Layout.fillWidth: true
                text: fin
            }

            Text {
                text: "Minimum"
            }
            Text {
                Layout.fillWidth: true
                text: min
            }

            Text {
                text: "Maximum"
            }
            Text {
                Layout.fillWidth: true
                text: max
            }

        }

    }

}
