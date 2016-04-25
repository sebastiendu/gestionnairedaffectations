import QtQuick 2.0
import QtQuick.Layouts 1.2

Item {
    ListView {
        interactive: false
        anchors.fill: parent
        model: app.disponibilite
        clip: true

        delegate: GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: 2
            rowSpacing: 2

            Text {
                Layout.columnSpan: 2
                text: "<img src='personne.png'/>     <b>" + prenom + " " + nom + "</b>"
            }

            Text {
                text: "Inscription"
            }
            Text {
                text: date_inscription.toLocaleDateString()
            }

            Text {
                text: "Amis"
            }
            Text {
                text: liste_amis
            }

            Text {
                text: "Type de poste"
            }
            Text {
                text: "type_poste"
            }

            Text {
                text: "Commentaire"
            }
            Text {
                text: commentaire_disponibilite
            }

            Text {
                text: "Statut"
            }
            Text {
                text: statut_disponibilite
            }

            Text {
                Layout.rowSpan: 2
                text: "Adresse"
            }
            Text {
                text: adresse
            }
            Text {
                text: code_postal + ' ' + ville
            }

            Text {
                Layout.rowSpan: 2
                text: "Contact"
            }
            Text {
                text: portable + " " + domicile
            }
            Text {
                text: email
            }

            Text {
                text: "Âge"
            }
            Text {
                text: age + " ans"
            }

            Text {
                text: "Profession"
            }
            Text {
                text: profession
            }

            Text {
                text: "Compétences"
            }
            Text {
                text: competences
            }

            Text {
                text: "Langues"
            }
            Text {
                text: langues
            }

            Text {
                text: "Commentaire"
            }
            Text {
                text: commentaire_personne
                wrapMode: Text.WordWrap
            }

            Text {
                text: "Disponibilite"
            }
            Text {
                text: commentaire_disponibilite
                wrapMode: Text.WordWrap
            }
        }
    }
}
