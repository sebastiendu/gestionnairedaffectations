import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2


Rectangle {
    anchors.top : tableauTours.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.topMargin: 25
    anchors.bottomMargin: 25
    anchors.margins: 15
    border.color: "black"
    radius: 5


    Rectangle {
        height: _ajouterUnPoste.height
        width: _ajouterUnPoste.width
        anchors.horizontalCenter: parent.horizontalCenter
        Label {

            id: _ajouterUnPoste
            styleColor: "white"
            anchors.top: parent.top
            anchors.topMargin: -_ajouterUnPoste.height /2
            text: " Ajouter un tour "
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
