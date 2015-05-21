import QtQuick 2.0
import QtQuick 2.3
import QtQuick.Controls 1.2
import fr.ldd.qml 1.0

Item {
    TableView {
        anchors.fill: parent
        TableViewColumn{
            role: "nom"
            title: "Poste"
            width: 100
        }
        TableViewColumn{
            role: "tours"
            title: "Tours"
            width: parent.width - 98
            delegate: Item {
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    Repeater {
                        model: styleData.value
                        // 0 id, 1 debut, 2 durée, 3 min, 4 max, 5 debut, 6 fin, 7 effectif, 8 besoin, 9 faim, 10 taux
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width * modelData.split('|')[1] // debut
                            width: parent.width * modelData.split('|')[2] // durée
                            height: parent.height
                            radius: 5
                            border.color: modelData.split('|')[10] === '100' ? "darkgreen" : modelData.split('|')[10] > 100 ? "darkyellow"  : "darkred"
                            color: modelData.split('|')[9] === '0' ? "green" : modelData.split('|')[9] < 0 ? "yellow"  : "red" // faim
                            opacity: 0.5
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: console.info("setIdTour(" + modelData.split('|')[0] + ") (TODO)")
                            }
                        }
                    }
                }
            }
        }
        model: app.toursParPosteModel
    }
}
