import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Window {
    id: ajouterTour
    title: "Ajouter un Tour"
    width: 200
    height: date.height + heuredebut.height
    modality: Qt.WindowModal
    property string champ: ""
    property string valeur: ""


                Column {
                    Calendar {
                        id: date
                        width: 200
                        height: 200
                    }

                    SpinBox {
                        id: heuredebut
                        maximumValue: 23
                        suffix: " heure"
                        width: 200
                    }
                }

    onClosing: {
        if(champ == "debut") app.modifierTourDebut(date.selectedDate, valeur);
        else if(champ == "fin") app.modifierTourFin(date.selectedDate, valeur);
    }

}
