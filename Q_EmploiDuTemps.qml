import QtQuick 2.0
import QtQuick 2.3
import QtQuick.Controls 1.2
import fr.ldd.qml 1.0

// Il faut un modèle qui donne
// la liste des postes de l'évenement
// avec pour chacun
// une barre correspondant aux horaires on/off
Item {
    TableView {
        anchors.fill: parent
        TableViewColumn{
            role: "nom"
            title: "Poste"
        }
        TableViewColumn{
            role: "id"
            title: "Tours"
        }
        model: app.toursParPosteModel
    }
}
