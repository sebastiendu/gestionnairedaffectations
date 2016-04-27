import QtQuick 2.0
import QtQuick.Layouts 1.2

Item {
    ListView {
        anchors.fill: parent
        interactive: false
        model: app.fiche_de_l_affectation
        delegate: ColumnLayout { // TODO : terminer
            width: parent.width
            height: children[0].height * 4
            Text {
                text: "Affectation du participant disponible " + id_disponibilite + " au tour " + id_tour
            }
            Text {
                text: "date_et_heure_proposee"
            }
            Text {
                text: "statut"
            }
            Text {
                text: "commentaire"
            }
        }
    }
}
