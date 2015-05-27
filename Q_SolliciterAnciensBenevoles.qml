import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2


import "fonctions.js" as Fonctions
Item {

    BusyIndicator {
     id: busyIndication
     anchors.centerIn: parent
    running: false

     }

    Button {
     anchors.horizontalCenter: parent.horizontalCenter
     anchors.bottom: parent.bottom
     anchors.bottomMargin: 100
     text: busyIndication.running ? "Stop Busy Indicator" : "Start Busy Indicator"

     onClicked: busyIndication.running = true;
     }

}
