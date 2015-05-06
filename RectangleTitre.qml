import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Item {

    property string titre: ""

    Rectangle {

        border.color: "black"
        radius: 5
        anchors.fill: parent


        Rectangle {
            height: _ajouterUnPoste.height
            width: _ajouterUnPoste.width
            anchors.horizontalCenter: parent.horizontalCenter

            Label {

                id: _ajouterUnPoste
                styleColor: "white"
                anchors.top: parent.top
                anchors.topMargin: -_ajouterUnPoste.height /2
                text: "   " + titre + "   "
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

}
