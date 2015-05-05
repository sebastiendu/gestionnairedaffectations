import QtQuick 2.3
import QtQuick.Dialogs 1.1



MessageDialog  {

    title: "Supprimer le Poste"
    icon: StandardIcon.Warning
    standardButtons: StandardButton.Yes | StandardButton.No
    text:  "Etes-vous sur de vouloir <u>supprimer</u> le poste <i>" + app.getNomPoste() + "</i> ?
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
