import QtQuick 2.0

Item { // une barre de progression qui indique un niveau de remplissage certain ou incertain
    // grise tant que la valeur est sous le minimum requis,
    // vert (certain) ou orange (incertain) quand elle est bien entre min et max
    // rouge si elle dépasse le maximum
    property int valeurmin: 0
    property int valeurmax: 2
    property int valeur: 1
    property bool certain: true
    property color couleurPasAssez: "grey"
    property color couleurBien: "green"
    property color couleurTrop: "red"
    property color couleurBienMaisIncertain: "orange"

    Rectangle { // le cadre
        anchors.fill: parent
        anchors.margins: 1
        border.color: (valeur > max) ? couleurTrop : (valeur < min) ? couleurPasAssez : certain ? couleurBien : couleurBienMaisIncertain
        border.width: 2

        Rectangle { // le remplissage
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: parent.border.width
            border.width: 0
            color: parent.border.color
            width: valeurmax > 0 ? (parent.width - 2*anchors.margins) * Math.min(valeur/valeurmax, 1) : 0;
        }
    }
    Text {
        anchors.fill: parent
        text: valeur + " / " + (
                  valeurmax == valeurmin
                  ? valeurmax
                  : "(" + valeurmin + "-" + valeurmax + ")"
                  )
        horizontalAlignment: Text.Center
        clip: true
    }

}

