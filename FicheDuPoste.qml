import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1

Rectangle {

    ListView {
        anchors.fill: parent
        model: app.fiche_du_poste

        delegate: ColumnLayout {

            TextField {
                placeholderText: qsTr("Nom du poste")
                text: nom
                font.pointSize: 12 // FIXME

                onEditingFinished: app.fiche_du_poste.setData(0, "nom", text)
            }

            ColumnLayout {
                spacing: 0

                Label {
                    text: qsTr("Description du poste")
                }

                TextArea { // FIXME: si description est vide, submitAll() fails
                    text: description
                    tabChangesFocus: true
                    onTextChanged: app.fiche_du_poste.setData(0, "description", text)
                }
            }

            CheckBox {
                text: qsTr("Ce poste est autonome")
                checked: autonome
                onClicked: app.fiche_du_poste.setData(0, "autonome", checked)
            }

            Button {
                text: qsTr("Valider")
                enabled: nom != ""
                isDefault: true
                activeFocusOnPress: true
                onClicked: {
                    if (model.id) {
                        if (app.fiche_du_poste.submitAll()) {
                            app.liste_des_postes_de_l_evenement.reload();
                        } else {
                            console.log("Echec de l'enregistrement des valeurs", model.id, nom, description, autonome, posx, posy);
                        }
                    } else app.insererPoste(nom, description, autonome, posx, posy)
                }
            }
//MessageDialog  {
//    visible: false
//    modality: Qt.ApplicationModal
//    title: "Supprimer le poste"
//    icon: StandardIcon.Warning
//    text: qsTr("Attention, le poste <i>%1</i> \
//a %2 tours de travail et %3 affectations. \
//<br><br>Voulez-vous vraiment <u>supprimer</u> ce poste, ses tours et les affectations liées ?")
//    .arg(nom)
//    .arg(nombre_tours)
//    .arg(nombre_affectations)
//    standardButtons: StandardButton.Yes | StandardButton.No

//    onNo: Qt.close
//    onYes: {
//        // TODO : app.fiche_du_poste.deleteRow(0);
//        Qt.close;
//    }
//}
        }
    }
}
