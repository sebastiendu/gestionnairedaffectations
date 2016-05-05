import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import "fonctions.js" as Fonctions

Item {

    RowLayout {
        anchors.fill: parent

        PlanDeLEvenement {
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.preferredWidth: cote
            Layout.preferredHeight: cote

            modeleListeDesPostes: app.liste_des_postes_de_l_evenement
            fonctionAjouterPoste: function (x, y) {
                app.setIdPoste(-1);
                if(app.fiche_du_poste.insertRows(0, 1)) {
                    if(app.fiche_du_poste.setData(0, "posx", x)
                            && app.fiche_du_poste.setData(0, "posy", y)
                            ) {
                        // TODO montrer la position du nouveau poste sur le plan
                    } else {
                        console.log("une erreur s'est produite avec setData");
                    }
                } else {
                    console.log("une erreur s'est produite avec insertRows")
                }
            }
            fonctionDeplacerPoste: function (x, y) {
                if (app.fiche_du_poste.setData(0, "posx", x)
                        && app.fiche_du_poste.setData(0, "posy", y)
                        ) {
                    if (app.fiche_du_poste.submitAll()) {
                    } else {
                        console.log("submitAll faillit");
                    }
                } else {
                    console.log("setData a raté");
                }
            }
            fonctionSupprimerPoste: function (id_poste) { // TODO : déplacer dans FicheDuPoste
                app.fiche_du_poste.removeRows(0, 1);
            }
        }

        FicheDuPoste {
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.preferredWidth: 200 // FIXME
        }
    }
}
