import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Rectangle {
    Layout.fillWidth: true; Layout.fillHeight: true
    Layout.preferredWidth: 200 // FIXME

    ListView {
        id: fiche_du_poste
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
        }
    }
}
