import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Item {
    ListView {
        interactive: false
        anchors.fill: parent
        model: app.fiche_de_la_disponibilite
        clip: true

        delegate: GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: 2
            rowSpacing: 2

            Text {
                Layout.fillWidth: true
                Layout.columnSpan: 2
                text: "<img src='personne.png'/>     <b>" + prenom + " " + nom + "</b>"
            }

            Text {
                text: "Inscription"
            }
            Text {
                text: date_inscription.toLocaleDateString()
                Layout.fillWidth: true
            }

            Text {
                text: "Amis"
                visible: liste_amis != ""
            }
            Text {
                text: liste_amis
                visible: liste_amis != ""
            }

            Text {
                text: "Type de poste"
                visible: type_poste != ""
            }
            Text {
                text: type_poste
                visible: type_poste != ""
            }

            Text {
                text: "Commentaire"
                visible: commentaire_disponibilite != ""
            }
            Text {
                text: commentaire_disponibilite
                visible: commentaire_disponibilite != ""
            }

            Text {
                text: "Statut de la disponibilité"
            }
            Text {
                text: statut_disponibilite
            }

            Text {
                id: _adresse
                Layout.rowSpan: 2
                text: "Adresse"
                //visible: adresse != "" or code_postal != "" or ville != "" // FIXME problème avec le nom "adresse"
            }
            Text {
                text: adresse
                visible: _adresse.visible
            }
            Text {
                text: code_postal + ' ' + ville
                visible: _adresse.visible
            }

            Text {
                Layout.rowSpan: 2
                text: "Contact"
            }
            Text {
                text: portable + " " + domicile
            }
            Text {
                text: "<a href=\"mailto:" + email + "\">" + email + "</a>"
            }

            Text {
                text: "Âge"
                visible: age > 0
            }
            Text {
                text: age + " ans"
                visible: age > 0
            }

            Text {
                text: "Profession"
                visible: profession != ""
            }
            Text {
                text: profession
                visible: profession != ""
            }

            Text {
                text: "Compétences"
                visible: competences != ""
            }
            Text {
                text: competences
                visible: competences != ""
            }

            Text {
                text: "Langues"
                visible: langues != ""
            }
            Text {
                text: langues
                visible: langues != ""
            }

            Text {
                text: "Commentaire sur la personne"
                visible: commentaire_personne != ""
            }
            Text {
                text: commentaire_personne
                wrapMode: Text.WordWrap
                visible: commentaire_personne != ""
            }

            Text {
                text: "Commentaire sur sa disponibilité"
                visible: commentaire_disponibilite != ""
            }
            Text {
                text: commentaire_disponibilite
                wrapMode: Text.WordWrap
                visible: commentaire_disponibilite != ""
            }

            // TODO : liste des affectations
        }
    }
}
