import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Window {
    id: root
    title: "Nouvel évènement"
    width: 500
    height: 600
    Column {
        spacing: 16
        anchors.fill: parent
        anchors.margins: 20
        TextField {
            width: parent.width
            id: nom
            placeholderText: "Nom de l'évènement"
            focus: true
        }
        SplitView {
            Column {
                spacing: 4
                Label {
                    text: "Début"
                }
                Calendar {
                    id: datedebut
                    width: 200
                    height: 200
                }
                SpinBox {
                    id: heuredebut
                    maximumValue: 23
                    suffix: " heure"
                    width: datedebut.width
                }
            }
            Column {
                spacing: 4
                Label {
                    text: "Fin"
                }
                Calendar {
                    id: datefin
                    width: 200
                    height: 200
                }
                SpinBox {
                    id: heurefin
                    maximumValue: 23
                    suffix: " heure"
                    width: datefin.width
                }
            }
        }
        TextField {
            width: parent.width
            id: lieu
            placeholderText: "Lieu"
        }
        Column {
            width: parent.width
            spacing: 4
            CheckBox {
                id: fait_suite_a
                text: "Fait suite à"
            }
            ComboBox {
                id: id_evenement_precedent
                enabled: fait_suite_a.checked
                model: app.liste_des_evenements
                textRole: "nom"
                width: parent.width
            }
        }
        Button {
            action: Action {
                text: "Ok"
                enabled: nom.text.length > 0
                onTriggered: {
                    app.enregistrerNouvelEvenement(
                        nom.text,
                        datedebut.selectedDate,
                        datefin.selectedDate,
                        heuredebut.value,
                        heurefin.value,
                        lieu.text,
                        app.liste_des_evenements.getIdFromIndex(id_evenement_precedent.currentIndex)
                    )
                    root.close()
                }
            }
        }
    }
}
