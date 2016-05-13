import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4

Rectangle {
    color: "#333333"
    implicitWidth: 350 // TODO pas codé en dur
    implicitHeight: children[0].implicitHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        Label {
            text: qsTr("Fiche du poste")
            font.pointSize: 16
            color: "#CCCCCC"
        }

        ListView {
            Layout.fillWidth: true
            implicitHeight: 300 // TODO pas codé en dur
            interactive: false
            model: app.fiche_du_poste
            delegate: ColumnLayout {
                width: parent.width

                TextField {
                    id: _nom
                    Layout.fillWidth: true
                    placeholderText: qsTr("Nom du poste")
                }

                ColumnLayout {
                    spacing: 0

                    Label {
                        text: qsTr("Description")
                        color: "#CCCCCC"
                    }

                    TextArea {
                        id: _description
                        Layout.fillWidth: true
                        tabChangesFocus: true
                    }
                }

                CheckBox {
                    id: _autonome
                    checked: autonome
                    style: CheckBoxStyle {
                        label: Label {
                            text: qsTr("Ce poste est autonome")
                            color: "#CCCCCC"
                        }
                    }
                }

                Button {
                    text: qsTr("Enregistrer")
                    Layout.fillWidth: true
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

                Button {
                    text: qsTr("Ajouter un tour")
                    Layout.fillWidth: true
                    enabled: model.id > 0
                    onClicked: {
                        app.setIdTour(-1);
                        app.fiche_du_tour.insertRows(0, 1);
                        app.fiche_du_tour.setData(0, "id_poste", model.id);
                    }
                }
                Component.onCompleted: {
                    _nom.text = nom;
                    _description.text = description;
                    _autonome.checked = autonome;
                }
            }
        }
    }
}
