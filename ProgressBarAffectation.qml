import QtQuick 2.0
import QtQuick.Layouts 1.1

Item { // une barre de progression qui indique un niveau de remplissage
    property int acceptees
    property int proposees
    property int possibles
    property int minimum
    property int maximum
    property int total: possibles + proposees + acceptees
    property int taille: Math.max(total, maximum)
    property real unite: width / taille

    Rectangle { // les bornes min et max
        anchors.fill: parent
        anchors.leftMargin: (minimum - 1) * unite
        anchors.rightMargin: (taille - maximum) * unite
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        border.color: "#4444CC"
        border.width: 2
    }

    RowLayout { // les blocs d'affectations
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4

        spacing: 0
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: acceptees * unite
            color: "#44CC44"
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: proposees * unite
            color: "#339933"
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: possibles * unite
            color: "#226622"
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: (taille - total) * unite
            color: "#CC4444"
        }
    }
}
