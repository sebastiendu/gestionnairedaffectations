import QtQuick 2.0

Item {

 property int valeurmin: 0
 property int valeurmax: 0
 property int valeur: 0
 property string couleurDefinie : "" // Vaut orange si au moins un personne n'a PAS encore accepté

    Rectangle {
        anchors.fill:parent
        border.color: "black"

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            //color: "green"
           // color: (couleurDefinie != "") ? couleurDefinie : (valeur < min) ? "grey" : (valeur > max ) ? "red" : "green"
            color: (valeur > max ) ? "red" : (valeur < min) ? "grey" : (couleurDefinie != "") ? couleurDefinie : "green"
            width: (valeur/max > 1) ? parent.width : parent.width * (valeur/max)
            height: parent.height
        }
    }


}

