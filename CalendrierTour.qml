import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Window {
    id: ajouterTour
    title: "Ajouter un Tour"
    width: 300
    height: date.height + heure.height
    modality: Qt.WindowModal
    property string champ: ""
    property string valeur: ""
    property int idtour : 0 // L'id du tour à modifier
    property int heureRecu: 0
    property int minutesRecu : 0

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
                        anchors.left: parent.left
                        width: parent.width /2
                    }

                    SpinBox {
                        id: minute
                        value: minutesRecu
                        maximumValue: 59
                        suffix: " minutes"
                        anchors.top: date.bottom
                        anchors.right: parent.right
                        width: parent.width /2

                    }


    onClosing: {
       if(champ == "debut") app.modifierTourDebut(date.selectedDate, heure.value, minute.value, idtour);
       else if(champ == "fin") app.modifierTourFin(date.selectedDate, heure.value, minute.value, idtour);

    }

}
