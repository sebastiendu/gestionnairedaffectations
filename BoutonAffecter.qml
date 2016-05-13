import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button {
    visible: app.fiche_de_l_affectation_de_la_disponibilite_au_tour.rowCount() === 0 && app.id_tour > 0 && app.id_disponibilite > 0
    style: ButtonStyle {
        label: Label {
            text: visible ? qsTr("Affecter %1 %2 au poste %3 %4 de %5 à %6")
            .arg(app.fiche_de_la_personne.data(0, "prenom"))
            .arg(app.fiche_de_la_personne.data(0, "nom"))
            .arg(app.fiche_du_poste      .data(0, "nom"))
            .arg(app.fiche_du_tour       .data(0, "debut").toLocaleDateString())
            .arg(app.fiche_du_tour       .data(0, "debut").toLocaleTimeString(null, {hour: "numeric", minute: "2-digit"}))
            .arg(app.fiche_du_tour       .data(0, "fin").toLocaleTimeString(null, {hour: "numeric", minute: "2-digit"}))
                          : ""
            wrapMode: Text.Wrap
        }
    }

    onClicked: {
        app.setIdAffectation(-1); // FIXME : Nécessaire ?
        app.fiche_de_l_affectation.insertRows(0, 1);
        app.enregistrerAffectation();
    }
}
