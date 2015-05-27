import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Window {

    title: titre
    width: 300
    height: date.height + heure.height + heure.anchors.topMargin
    modality: Qt.WindowModal
    property string champ: ""
    property string valeur: "" // La date
    property int idtour : 0 // L'id du tour à modifier
    property int heureRecu: 0
    property int minutesRecu : 0
    property string titre: "Ajouter un tour"
    property string attribut : "" // Peut etre tour ou evenement


    Calendar {
        id: date
        width: 300
        height: 300
        selectedDate: valeur
    }


    SpinBox {
        id: heure
        value: heureRecu
        maximumValue: 23
        suffix: " heure"
        anchors.top: date.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        width: parent.width /2
    }

    SpinBox {
        id: minute
        value: minutesRecu
        maximumValue: 59
        suffix: " minutes"
        anchors.top: date.bottom
        anchors.topMargin: 20
        anchors.right: parent.right
        width: parent.width /2

    }


    onClosing: {
        if(attribut == "tour")
        {
            console.log("tour");
            if(champ == "debut") app.modifierTourDebut(date.selectedDate, heure.value, minute.value, idtour);
            else if(champ == "fin") app.modifierTourFin(date.selectedDate, heure.value, minute.value, idtour);
        }
        else if(attribut == "evenement")
        {
            console.log("evnt");
            if(champ == "debut") app.setDebutEvenement(date.selectedDate, heure.value, minute.value, idtour);
            else if(champ == "fin") app.setFinEvenement(date.selectedDate, heure.value, minute.value, idtour);
        }
    }

}
