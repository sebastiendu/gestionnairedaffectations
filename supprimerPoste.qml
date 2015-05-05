import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.1



MessageDialog  {

    title: "Supprimer le Poste"
    icon: StandardIcon.Warning
    standardButtons: StandardButton.Yes | StandardButton.No
    text:  "Etes-vous sur de vouloir <u>supprimer</u> le poste " + app.getNomPoste() + "?
            <br> Ce poste contient : <br><br>
             \t - " + app.getNombreDeTours() + " tour(s) <br>
             \t - " + app.getNombreDAffectations() + " affectation(s)"

    onYes: {
            app.supprimerPoste(app.getIdPoste());
            Qt.close;
        }

    onNo: {
             Qt.close;
        }

    visible: true
    modality: Qt.ApplicationModal

}
