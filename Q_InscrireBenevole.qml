import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2


import "fonctions.js" as Fonctions

Item {
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: green

        Label {
            id: l_nomBenevole
            text: "Nom: "
            anchors.top: parent.top
            anchors.topMargin:29
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _nomBenevole
            placeholderText: "Nom"
            anchors.top: parent.top
            anchors.topMargin:25
            anchors.left: l_nomBenevole.right
        }

        Label {
            id: l_prenomBenevole
            text: "Prenom: "
            anchors.top: _nomBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _prenomBenevole
            placeholderText: "Prenom"
            anchors.top: _nomBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_prenomBenevole.right
        }

        Label {
            id: l_adresseBenevole
            text: "Adresse Postale: "
            anchors.top: _prenomBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _adresseBenevole
            placeholderText: "Adresse"
            anchors.top: _prenomBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_prenomBenevole.right
        }

        Label {
            id: l_codePostalBenevole
            text: "Code postal: "
            anchors.top: _adresseBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _codePostalBenevole
            placeholderText: "Code Postal"
            anchors.top: _adresseBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_codePostalBenevole.right
        }

        Label {
            id: l_communeBenevole
            text: "Commune: "
            anchors.top: _codePostalBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _communeBenevole
            anchors.top: _codePostalBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_communeBenevole.right
        }

        Label {
            id: l_courrielBenevole
            text: "Courriel: "
            anchors.top: _communeBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _courrielBenevole
            placeholderText: "Adresse courriel"
            anchors.top: _communeBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_courrielBenevole.right
        }

        Label {
            id: l_numPortableBenevole
            text: "Numero de portable: "
            anchors.top: _courrielBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _numPortableBenevole
            placeholderText: "Portable"
            anchors.top: _courrielBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_numPortableBenevole.right
        }

        Label {
            id: l_numDomicileBenevole
            text: "Numero du domicile: "
            anchors.top: _numPortableBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _numDomicileBenevole
            placeholderText: "Numero du domicile"
            anchors.top: _numPortableBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_numDomicileBenevole.right
        }

        Label {
            id: l_professionBenevole
            text: "Profession: "
            anchors.top: _numDomicileBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _professionBenevole
            placeholderText: "Profession"
            anchors.top: _numDomicileBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_professionBenevole.right
        }

        Label {
            id: l_datenaissanceBenevole
            text: "Date de naissance "
            anchors.top: _professionBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _datenaissanceBenevole
            placeholderText: "JJ/MM/AAAA"
            anchors.top: _professionBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_datenaissanceBenevole.right
        }

        Label {
            id: l_languesBenevole
            text: "Langues: "
            anchors.top: _datenaissanceBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _languesBenevole
            placeholderText: "Langues"
            anchors.top: _datenaissanceBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_languesBenevole.right
        }

        Label {
            id: l_competencesBenevole
            text: "Competences: "
            anchors.top: _languesBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextField {
            id: _competencesBenevole
            placeholderText: "Competence"
            anchors.top: _languesBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_competencesBenevole.right
        }

        Label {
            id: l_commentaireBenevole
            text: "Commentaire: "
            anchors.top: _competencesBenevole.bottom
            anchors.topMargin:9
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.40
        }

        TextArea {
            id: _commentaireBenevole

            anchors.top: _competencesBenevole.bottom
            anchors.topMargin:5
            anchors.left: l_competencesBenevole.right
            height: 100;
        }

        Button {
            text: "Inscrire le bénévole"
            anchors.top: _commentaireBenevole.bottom
            anchors.topMargin: 25

            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: { console.log("TODO: Faire la requete d'inscription (attendre modification de la base");
                app.inscrireBenevole(_nomBenevole.text, _prenomBenevole.text, _adresseBenevole.text,
                                     _codePostalBenevole.text, _communeBenevole.text,_courrielBenevole.text,
                                     _numPortableBenevole.text, _numDomicileBenevole.text, _professionBenevole.text,
                                     _datenaissanceBenevole.text, _languesBenevole.text, _competencesBenevole.text,
                                     _commentaireBenevole.text );
            }
        }

    }
}
