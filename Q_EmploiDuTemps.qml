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
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width * modelData.split('|')[1] // debut
                            width: parent.width * modelData.split('|')[2] // durée
                            height: parent.height
                            color: "yellow"
                            border.color: "gray"
                            Text {
                                anchors.fill: parent
                                text: modelData.split('|')[0] // id
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
        model: app.toursParPosteModel
    }
}
