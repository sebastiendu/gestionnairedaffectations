import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4

Item {

    ColumnLayout {
        anchors.fill: parent
        ListView {
            id: liste
            model: app.affectation_de_la_disponibilite_au_tour // TODO setIdDisponibilite et setIdTour rechargent ce modele
            delegate: Button { // TODO Remplacer ce bouton par la fiche de l'affectation
                Layout.preferredHeight: 20
                Layout.fillWidth: true
                text: "Ouvrir la fiche de l'affectation du participant " + app.id_disponibilite + " au tour " + app.id_tour // TODO : les nommer
                onClicked: app.setIdAffectation(liste.model.currentIndex);
            }
        }

        TextField {
            Layout.fillHeight: true
            Layout.fillWidth: true
            // visible: liste.currentIndex == -1 && fiche_de_la_disponibilite.currentIndex > -1 && fiche_du_tour.currentIndex > -1 // FIXME
            id: commentaire
            placeholderText: "Commentaire optionnel relatif à cette affectation"
        }

        Button {
            Layout.preferredHeight: 20
            Layout.fillWidth: true
            // visible: liste.currentIndex == -1 && fiche_de_la_disponibilite.currentIndex > -1 && fiche_du_tour.currentIndex > -1 // FIXME
            text: "+ Affecter le participant " + app.id_disponibilite + " au tour " + app.id_tour // TODO : les nommer
            onClicked: app.creerAffectation(commentaire.text);
        }

    }

}
