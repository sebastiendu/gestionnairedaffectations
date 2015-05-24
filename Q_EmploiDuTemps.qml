import QtQuick 2.0
import QtQuick 2.3
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import fr.ldd.qml 1.0

Item {
    ListView {
        id: joursView
        anchors.fill: parent
        orientation: ListView.Horizontal
        model: app.sequence_emploi_du_temps
        delegate: Text {
            text: libelle_sequence
            height: parent.parent.height
            width: proportion * parent.parent.width
            color: "lightgray"
            font.bold: true
            style: Text.Outline
            styleColor: "gray"
            font.pixelSize: width
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            rotation: -90
        }
    }
    ListView {
        anchors.fill: parent
        model: app.toursParPosteModel
        delegate: Component {
            Rectangle {
                color: "transparent"
                height: parent.parent.height / (parent.parent.model.rowCount() + 1)
                width: parent.parent.width
                Text {
                    anchors.fill: parent
                    text: nom
                    font.bold: true
                    style: Text.Outline
                    fontSizeMode: Text.Fit
                    font.pixelSize: height
                    color: "white"
                    styleColor: "gray"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                Repeater {
                    model: tours // styleData.value
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
                        opacity: 0.75
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
}
