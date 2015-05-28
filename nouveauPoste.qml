import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2



Window {
    id: nouveauPoste
    title: "Nouveau Poste"
    width: 400
    height: 330
    minimumWidth: 300
    minimumHeight: 200

    Label {
        id: _nom
        text:  "nom: "
        x: parent.width/2 - _nom.width/2
        anchors.top: parent.top
        anchors.topMargin: 10
    }

    TextField {
        id: _nomP
        anchors.top: _nom.bottom
        anchors.topMargin: 10
        anchors.leftMargin: parent.width * 0.05
        anchors.left: parent.left
        width: parent.width * 0.90 // 90% de la taille de la fenetre

    }

    Label {
        id: _description
        anchors.top: _nomP.bottom
        anchors.topMargin: 10
        text: "description: "
        x: parent.width/2 - _description.width/2
    }

    TextArea {
        id: _descriptionP

        anchors.top: _description.bottom
        anchors.topMargin: 20
        width: parent.width * 0.90
        anchors.left: parent.left
        anchors.leftMargin:  parent.width * 0.05

    }

    CheckBox {
        id: autonome
        anchors.top: _descriptionP.bottom
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: (parent.width - width)/2
        anchors.bottom: _button.top
        anchors.bottomMargin: 10
        text: "Le poste est autonome"
    }

    Button {
        id: _button
        text: "Valider"
        onClicked : {
            if(_nomP.text == "" || _descriptionP.text == "")
            {
                console.log("Erreur, veuillez remplir les deux champs");
            }
            else{
                app.insererPoste(_nomP.text, _descriptionP.text , autonome.checked, app.getRatioX() , app.getRatioY());
            }
            nouveauPoste.close();
        }

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        x: parent.width/2 - _button.width/2
    }
}
