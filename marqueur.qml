import QtQuick 2.0
import QtQuick.Controls 1.2


Image {
    id: marqueur
    width: 45
    height:65
    source: "marqueurs/rouge.png"
    x: 10
    y: 10

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        drag.target: parent



        onClicked:
        {
            if(mouse.button == Qt.RightButton)
            {
                contextMenu.popup();
            }

            if(mouse.button == Qt.LeftButton)
            {

                // marqueur.source = "marqueurs/rouge_brillant.png"
                console.log(marqueur.id + "")
            }
        }
    }

    Menu {
        id: contextMenu

        MenuItem {
            text: qsTr("Supprimer")
            onTriggered: {
                marqueur.destroy()
            }
        }
    }

}


