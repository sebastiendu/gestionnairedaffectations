import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Rectangle {
    color: "#333333"
    implicitWidth: 350 // TODO pas codé en dur
    implicitHeight: children[0].implicitHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        Label {
            text: qsTr("Fiche de la personne")
            font.pointSize: 16
            color: "#CCCCCC"
        }

        ListView {
            Layout.fillWidth: true
            implicitHeight: 200 // TODO pas codé en dur
            interactive: false
            model: app.fiche_de_la_personne
            delegate: GridLayout {
                width: parent.width
                columns: 2
                columnSpacing: 2
                rowSpacing: 2

                Text {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    text: prenom + " " + nom
                }

                Text {
                    id: _adresse
                    Layout.rowSpan: 2
                    text: "Adresse"
                    visible: adresse != "" || code_postal != "" || ville != ""
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
                    // visible: age > 0  // FIXME age is not defined
                }
                Text {
                    /// text: age + " ans"
                    // visible: age > 0
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
                    text: "Commentaire"
                    visible: commentaire != ""
                }
                Text {
                    text: commentaire
                    wrapMode: Text.WordWrap
                    visible: commentaire != ""
                }
            }
        }
    }
}
