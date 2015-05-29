import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtMultimedia 5.3

import "fonctions.js" as Fonctions

Item {
    anchors.fill: parent

    Rectangle {
        id: block
        anchors.fill: parent
        // color: "#2ecc71"

        Connections {
            target: app
            onInscriptionOk:  {
                ding.play();
                _nomBenevole.vider();
                _prenomBenevole.vider();
                _adresseBenevole.vider();
                _codePostalBenevole.vider();
                _communeBenevole.vider();
                _courrielBenevole.vider();
                _numPortableBenevole.vider();
                _numDomicileBenevole.vider();
                _professionBenevole.vider();
                _datenaissanceBenevole.vider();
                _competencesBenevole.vider();
                _languesBenevole.vider();
                _listeAmis.vider();
                _joursEtHeuresDispo.vider();
                _typePoste.vider();
                _commentaireBenevole.text =""
                _commentaireDisponibilite.text = ""
                _nomBenevole.focusField();
            }
        }

        RectangleTitre {
            id: blockInformations
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 20
            anchors.leftMargin: 10
            width: parent.width*0.5 -10
            titre: "Informations"
            couleur : "#bdc3c7"
            height: 550

            LabelTextField {
                id: _nomBenevole
                texte: "Nom"
                anchors.top: parent.top
                anchors.topMargin:30
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }

            LabelTextField {
                id: _prenomBenevole
                texte: "Prenom"
                anchors.top: _nomBenevole.bottom
                anchors.topMargin:10
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }

            LabelTextField {
                id: _adresseBenevole
                texte: "Adresse Postale"
                anchors.top: _prenomBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }


            LabelTextField {
                id: _codePostalBenevole
                texte: "Code postal"
                anchors.top: _adresseBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }


            LabelTextField {
                id: _communeBenevole
                texte: "Commune"
                anchors.top: _codePostalBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }

            LabelTextField {
                id: _courrielBenevole
                texte: "Courriel"
                anchors.top: _communeBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }


            LabelTextField {
                id: _numPortableBenevole
                texte: "Numero de portable"
                anchors.top: _courrielBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }


            LabelTextField {
                id: _numDomicileBenevole
                texte: "Numero du domicile"
                anchors.top: _numPortableBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }


            LabelTextField {
                id: _professionBenevole
                texte: "Profession"
                anchors.top: _numDomicileBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }


            LabelTextField {
                id: _datenaissanceBenevole
                texte: "Date de naissance "
                placeHolder: "AAAA-MM-JJ"
                memeTexte: false
                anchors.top: _professionBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }

            LabelTextField {
                id: _languesBenevole
                texte: "Langues"
                anchors.top: _datenaissanceBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }


            LabelTextField {
                id: _competencesBenevole
                texte: "Competences"
                anchors.top: _languesBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }

            Label {
                id: l_commentaireBenevole
                text: "Commentaire: "
                anchors.top: _competencesBenevole.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.30
            }

            TextArea {
                id: _commentaireBenevole

                anchors.top: _competencesBenevole.bottom
                anchors.topMargin:5
                anchors.left: l_commentaireBenevole.right
                anchors.leftMargin: 10
                height: 100;
            }
        }


        RectangleTitre {
            id: blockDisponibilite
            titre: "Disponibilité"
            anchors.top: parent.top
            anchors.topMargin: blockInformations.anchors.topMargin
            anchors.left: blockInformations.right
            anchors.leftMargin: 5
            width: blockInformations.width
            height: blockInformations.height
            couleur : "#bdc3c7"

            LabelTextField {
                id: _joursEtHeuresDispo
                texte: "Jours et heures "
                anchors.top: parent.top
                anchors.topMargin:30
                anchors.left: parent.left
                anchors.leftMargin: parent.width *0.2
                taille: 300

            }

            LabelTextField {
                id: _listeAmis
                texte: "Liste amis"
                anchors.top: _joursEtHeuresDispo.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width *0.2
                taille: 300

            }

            LabelTextField {
                id: _typePoste
                texte: "Type de poste souhaité"
                anchors.top: _listeAmis.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width *0.2
                taille: 300

            }


            Label {
                id: l_commentaireDisponibilite
                text: "Commentaire: "
                anchors.top: _typePoste.bottom
                anchors.topMargin:9
                anchors.left: parent.left
                anchors.leftMargin: parent.width *0.2
            }

            TextArea {
                id: _commentaireDisponibilite

                anchors.top: _typePoste.bottom
                anchors.topMargin:5
                anchors.left: l_commentaireDisponibilite.right
                anchors.leftMargin: 10
                width: 300
                height: 100;
            }

        }

        Button {
            text: "Inscrire le bénévole"
            anchors.top: blockDisponibilite.bottom
            anchors.topMargin: 25

            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: { console.log("TODO: Faire la requete d'inscription (attendre modification de la base");
                app.inscrireBenevole(_nomBenevole.valeur, _prenomBenevole.valeur, _adresseBenevole.valeur,
                                     _codePostalBenevole.valeur, _communeBenevole.valeur,_courrielBenevole.valeur,
                                     _numPortableBenevole.valeur, _numDomicileBenevole.valeur, _professionBenevole.valeur,
                                     _datenaissanceBenevole.valeur, _languesBenevole.valeur, _competencesBenevole.valeur,
                                     _commentaireBenevole.text, _joursEtHeuresDispo.valeur, _listeAmis.valeur, _typePoste.valeur, _commentaireDisponibilite.text);

                // strdate et strfdate
            }
        }

        SoundEffect {
            id: ding
            source: "Ding_Sound_Effect.wav"
            volume: 0.3
        }

    }

}
