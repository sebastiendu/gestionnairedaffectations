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
                        // 0 id, 3 min, 4 max, 5 debut, 6 fin, 7 effectif, 8 besoin, 9 faim
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width * modelData.split('|')[1] // debut
                            width: parent.width * modelData.split('|')[2] // durée
                            height: parent.height
                            color: "gray" // TODO : calculer la bonne couleur en fonction de la faim
                            border.color: "black"
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                Rectangle {
                                    color: "#f3eea5"
                                    border.color: "black"
                                    anchors.centerIn: parent
                                    width: 200
                                    height: 50
                                    visible: parent.containsMouse
                                    Label {
                                        anchors.fill: parent
                                        text: "%1: de %2 à %3\n%4 personnes affectées (min %5, max %6)" // FIXME
                                        /*.arg(
                                            modelData.split('|')[0], // id
                                            modelData.split('|')[5], // debut
                                            modelData.split('|')[6], // fin
                                            modelData.split('|')[7], // effectif
                                            modelData.split('|')[3], // min
                                            modelData.split('|')[4] // max
                                        )*/
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        font.pointSize: 7
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        model: app.toursParPosteModel
    }
}
