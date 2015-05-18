import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2


import "fonctions.js" as Fonctions

Item {

    anchors.fill: parent
    Rectangle
    {

        anchors.fill: parent
        color: "pink"
        Label {
            id : _soumettreAffectations
            text : "Soumettre par email les affectations pour validation par chaque bénévole"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 20
            anchors.leftMargin:20
            font.pixelSize: 16
        }

        CheckBox {
            id: _checkboxAffecationsJamaisSoumises
            anchors.top: _soumettreAffectations.bottom
            anchors.topMargin: 10
            anchors.left: _soumettreAffectations.left
            anchors.leftMargin: 50
            text: "Les affectations proposées qui n'ont jamais été soumises à l'approbation du bénévole"
        }

        CheckBox {
            id: _checkboxAffecationsNonTraitees
            anchors.top: _checkboxAffecationsJamaisSoumises.bottom
            anchors.topMargin: 10
            anchors.left: _soumettreAffectations.left
            anchors.leftMargin: 50
            text: "Les affectations qui ont déjà été soumises mais que le bénévole n'a pas encore traité"
        }

        CheckBox {
            id: _checkboxAffecationsRelance
            anchors.top: _checkboxAffecationsNonTraitees.bottom
            anchors.topMargin: 10
            anchors.left: _soumettreAffectations.left
            anchors.leftMargin: 50
            text: "Les affectations qui ont fait l'objet d'une relance mais n'ont pas obtenu de réaction"
        }

        Label {
            id: _envoyerMessage
            anchors.top: _checkboxAffecationsRelance.bottom
            anchors.topMargin: 100
            anchors.left: _soumettreAffectations.left
            anchors.leftMargin: 50
            text: "Envoyer un message à "
        }

        Button {
            id: _boutonGenerer
            anchors.top: _envoyerMessage.top
            anchors.topMargin: -5 // Simplement pour que le bouton soit centré avec le texte
            anchors.left: _envoyerMessage.right
            anchors.leftMargin: 10
            text: "Generer l'adresse mail"
            onClicked: _adresseEmail.text = app.creerLotDAffectations(
               _checkboxAffecationsJamaisSoumises.checked,
               _checkboxAffecationsNonTraitees.checked,
               _checkboxAffecationsRelance.checked
            )
        }

        Label {
            id: _adresseEmail
            anchors.top: _boutonGenerer.bottom
            anchors.topMargin: 100
            anchors.left: _soumettreAffectations.left
            anchors.leftMargin: 50
            text: ""
            textFormat: Text.PlainText
        }
    }
}
