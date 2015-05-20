import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2


import "fonctions.js" as Fonctions

Item {

    anchors.fill: parent
    Rectangle
    {
        id: _rectangleHaut
        /*color: "pink"
        border.color: "red"// DEBUG */
        width: parent.width*0.60
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: (parent.width - width)/2
        height: 250


        Label {
            id : _soumettreAffectations
            text : "Soumettre à chaque bénévole par email (pour validation) les affectations qui ont été :"
            anchors.top: _rectangleHaut.top
            anchors.left: _rectangleHaut.left
            anchors.topMargin: 20
            anchors.leftMargin:20
            width: parent.width*0.9
            font.pixelSize: 16
            wrapMode: "WordWrap"
        }

        CheckBox {
            id: _checkboxAffecationsJamaisSoumises
            anchors.top: _soumettreAffectations.bottom
            anchors.topMargin: 10
            anchors.left: _soumettreAffectations.left
            anchors.leftMargin: 50
            onClicked: {
                _adresseEmail.visible=false
                _boutonGenerer.visible=true
                curseurDifferentPourLienEmail.visible=false
            }
        }

        Text {
            anchors.left : _checkboxAffecationsJamaisSoumises.right
            anchors.top : _checkboxAffecationsJamaisSoumises.top
            text: "Proposées mais qui n'ont jamais été soumises à l'approbation du bénévole (1er envoi)"
            wrapMode: "WordWrap"
            width: parent.width * 0.8
        }

        CheckBox {
            id: _checkboxAffecationsNonTraitees
            anchors.top: _checkboxAffecationsJamaisSoumises.bottom
            anchors.topMargin: 20
            anchors.left: _soumettreAffectations.left
            anchors.leftMargin: 50

            onClicked: {
                _adresseEmail.visible=false
                _boutonGenerer.visible=true
                curseurDifferentPourLienEmail.visible=false
            }
        }
        Text {
            anchors.left : _checkboxAffecationsNonTraitees.right
            anchors.top : _checkboxAffecationsNonTraitees.top
            wrapMode: "WordWrap"
            width: parent.width * 0.8
            text: "Déjà soumises à l'approbation mais que le bénévole n'a pas encore traité (Relance)"
        }

        CheckBox {
            id: _checkboxAffecationsRelance
            anchors.top: _checkboxAffecationsNonTraitees.bottom
            anchors.topMargin: 20
            anchors.left: _soumettreAffectations.left
            anchors.leftMargin: 50
            onClicked: {
                _adresseEmail.visible=false
                _boutonGenerer.visible=true
                curseurDifferentPourLienEmail.visible=false
            }
        }
        Text {
            anchors.left : _checkboxAffecationsRelance.right
            anchors.top : _checkboxAffecationsRelance.top
            wrapMode: "WordWrap"
            width: parent.width * 0.8
            text: "Ayant fait l'objet d'une relance mais n'ont pas obtenu de réaction (2ème relance)"
        }


        Label {
            id: _envoyerMessage
            anchors.top: _checkboxAffecationsRelance.bottom
            anchors.topMargin: 50
            anchors.left: _soumettreAffectations.left
            anchors.leftMargin: 50
            text: "Envoyer un courriel à "
        }

        Button {
            id: _boutonGenerer
            visible: true
            anchors.top: _envoyerMessage.top
            anchors.topMargin: -5 // Simplement pour que le bouton soit centré avec le texte
            anchors.left: _envoyerMessage.right
            anchors.leftMargin: 10
            text: "Générer l'adresse mail"
            onClicked: {
                var debut ="<a href='mailto:";
                var mail = app.creerLotDAffectations(
                            _checkboxAffecationsJamaisSoumises.checked,
                            _checkboxAffecationsNonTraitees.checked,
                            _checkboxAffecationsRelance.checked
                            );
                var fin = "'>";
                var fin2 = "</a>";
                _adresseEmail.text=debut+mail+fin+mail+fin2;
                _tableauListeDesLotsDejaCrees.model = app.lotsDejaCrees;
                _boutonGenerer.visible = false
                _adresseEmail.visible = true
                curseurDifferentPourLienEmail.visible = true
            }
        }

        Text {
            id: _adresseEmail
            visible: false
            anchors.top: _envoyerMessage.top
            anchors.topMargin: _envoyerMessage.topMargin
            anchors.left: _boutonGenerer.left
            anchors.leftMargin: _boutonGenerer.leftMargin
            text: ""
            textFormat: Text.RichText
            onLinkActivated: Qt.openUrlExternally(link)
            z: 2


        }

        MouseArea {
            id: curseurDifferentPourLienEmail
            visible: false
            anchors.fill: _adresseEmail
            cursorShape: Qt.PointingHandCursor
            z : 1
        }
    }

    Rectangle
    {

        id: rectangleTableauListeDesLotsDejaCrees
        /*border.color:"blue"
        color: "yellow" // DEBUG */
        anchors.top: _rectangleHaut.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        width: parent.width*0.7
        anchors.bottom : parent.bottom
        anchors.bottomMargin: parent.height*0.1
        anchors.leftMargin: (parent.width - width)/2

        Label {
            id: _listeDesLotsDejaCrees
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            text: _tableauListeDesLotsDejaCrees.model.getDataFromModel(0,"date_de_creation") != ""?"Liste des lots déjà créés":"Aucun lot créé"
        }

        TableView {
            visible: _tableauListeDesLotsDejaCrees.model.getDataFromModel(0,"date_de_creation") != ""?true:false
            id: _tableauListeDesLotsDejaCrees
            anchors.top: _listeDesLotsDejaCrees.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            model: app.lotsDejaCrees

            /*rowDelegate: Rectangle {
                width:parent.width
                height: 20
            }*/

            TableViewColumn{
                id: colonne1;
                resizable : false;
                movable:false;
                role: "date_de_creation"  ;
                width: (rectangleTableauListeDesLotsDejaCrees.width*0.08 - 1) < 100 ? 100 : (rectangleTableauListeDesLotsDejaCrees.width*0.08)-1;
                title: "Date" ;
                horizontalAlignment: Text.AlignHCenter; // Pour que le titre de la colonne soit bien centré
                delegate: Text{
                    text:Fonctions.dateFR(styleData.value)
                    verticalAlignment: Text.AlignVCenter
                }
            }

            TableViewColumn{
                id: colonne2;
                resizable : false;
                movable:false;
                width: _tableauListeDesLotsDejaCrees.width - (colonne1.width+colonne3.width+colonne4.width+colonne5.width) - 2
                role: "titre";

                delegate: Text{
                    id: titre
                    text: styleData.value
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHLeft // Pour que le titre de la colonne soit à gauche
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    //wrapMode: Text.WrapAnywhere;
                    elide: Text.ElideRight
                }

                //width: (rectangleTableauListeDesLotsDejaCrees.width*0.25)-1;
                title: "Titre" ;
                horizontalAlignment: Text.AlignHCenter // Pour que le titre de la colonne soit à gauche
            }

            TableViewColumn{
                id: colonne3;
                resizable : false;
                movable:false;
                title: "Adresse mail";
                horizontalAlignment: Text.AlignHCenter
                width: rectangleTableauListeDesLotsDejaCrees.width*0.20 -1;
                delegate: Text{
                    wrapMode: Text.WrapAnywhere; // C'est pour que le texte ne déborde pas
                    text: "<a href='mailto:"+Fonctions.construireEmail(_tableauListeDesLotsDejaCrees.model.getDataFromModel(styleData.row,"id"),_tableauListeDesLotsDejaCrees.model.getDataFromModel(styleData.row,"cle"),app.settings.value("email/prefixe", ""),app.settings.value("email/domaine", ""))+"'>"+Fonctions.construireEmail(_tableauListeDesLotsDejaCrees.model.getDataFromModel(styleData.row,"id"),_tableauListeDesLotsDejaCrees.model.getDataFromModel(styleData.row,"cle"),app.settings.value("email/prefixe", ""),app.settings.value("email/domaine", ""))+"</a>"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    anchors.leftMargin: 20
                    onLinkActivated: Qt.openUrlExternally(link) // Permet que le lien soit cliquable




                }
            }

            TableViewColumn{
                id: colonne4;
                resizable : false;
                movable:false;
                role: "traite";
                width: (rectangleTableauListeDesLotsDejaCrees.width*0.08 - 1) < 80 ? 80 : (rectangleTableauListeDesLotsDejaCrees.width*0.08 - 1);
                title: "Etat" ;
                horizontalAlignment: Text.AlignHCenter; // Pour que le titre de la colonne soit bien centré
                delegate: Text{
                    text:(styleData.value==false)?"Non utilisée":"Utilisée"
                    verticalAlignment: Text.AlignVCenter
                }
            }
            TableViewColumn{
                id: colonne5;
                resizable : false;
                movable:false;
                width: rectangleTableauListeDesLotsDejaCrees.width * 0.09 - 1;
                title: "Expiré" ;
                horizontalAlignment: Text.AlignLeft // Pour que le titre de la colonne soit a gauche
                delegate: Rectangle{
                    color:(Fonctions.expire(_tableauListeDesLotsDejaCrees.model.getDataFromModel(styleData.row,"date_de_creation")))?"red":"green"
                    border.color: "white"
                    border.width: 1
                    }
            }

           }
      }

}
