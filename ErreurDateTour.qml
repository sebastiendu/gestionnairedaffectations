import QtQuick 2.3
import QtQuick.Dialogs 1.1



MessageDialog  {

    property string erreur: ""
    title: "Erreur"
    icon: StandardIcon.Critical
    standardButtons: StandardButton.Ok
    text:  "<b>Erreur</b><br><br>"+erreur


    visible: true
    modality: Qt.ApplicationModal

}
