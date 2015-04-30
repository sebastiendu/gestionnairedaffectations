import QtQuick 2.0
import QtQuick.Controls 1.2


Rectangle {
    id: marqueur
    width: (45/640) * parent.width
    height:(45/640) * parent.height
  //  source: "marqueurs/rouge.png"
    radius: 100
    border.color:"#c0392b"
    border.width: 4
    x: ratioX * parent.width
    y: ratioY * parent.height

    //anchors.left: parent.left
   // anchors.top: parent.top

    property real ratioX : 10
    property real ratioY : 10

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        drag.target: parent
        cursorShape: Qt.PointingHandCursor
        drag.maximumX: marqueur.parent.width
        drag.minimumX: 0
        drag.maximumY: marqueur.parent.height
        drag.minimumY: 0

        onClicked:
        {
            if(mouse.button == Qt.RightButton)
            {
                contextMenu.popup();

            }

            if(mouse.button == Qt.LeftButton)
            {
                // marqueur.source = "marqueurs/rouge_brillant.png"
                console.log("ratioX : " + ratioX + ", longueurParent:" + marqueur.parent.width)
                console.log("ratioX * longueurParent = " + (ratioX * marqueur.parent.width))

            }
        }

        onReleased: {


            marqueur.ratioX = (marqueur.x / marqueur.parent.width);
            marqueur.ratioY = (marqueur.y / marqueur.parent.height);
            console.log("Position x: "  + marqueur.ratioX);
            console.log("Position y: " + marqueur.ratioY);

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


