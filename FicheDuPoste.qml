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
                id: _nom
                placeholderText: qsTr("Nom du poste")
                text: nom
                font.pointSize: 12 // FIXME
            }

            ColumnLayout {
                spacing: 0

                Label {
                    text: qsTr("Description du poste")
                }

                TextArea { // FIXME: si description est vide, submitAll() fails
                    id: _description
                    text: description
                    tabChangesFocus: true
                }
            }

            CheckBox {
                id: _autonome
                text: qsTr("Ce poste est autonome")
                checked: autonome
            }

            Button {
                text: qsTr("Valider")
                enabled: _nom.text != ""
                isDefault: true
                activeFocusOnPress: true
                onClicked: {
                    app.fiche_du_poste.setData(0, "nom", _nom.text);
                    app.fiche_du_poste.setData(0, "description", _description.text);
                    app.fiche_du_poste.setData(0, "autonome", _autonome.checked);
                    app.enregistrerPoste();
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
