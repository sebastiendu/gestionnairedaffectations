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
            fonctionDeplacerPoste: function (id_poste, x, y) {
                app.setIdPoste(id_poste);
                app.fiche_du_poste.setData(0, "posx", x);
                app.fiche_du_poste.setData(0, "posy", y);
                app.fiche_du_poste.submit();
            }
            fonctionSupprimerPoste: function (id_poste) {
                app.setIdPoste(id_poste);
                app.rafraichirStatistiquePoste(id_poste, "hop"); // FIXME
                if (app.getNombreDeTours() > 0 || app.getNombreDAffectations() > 0) {
                    Fonctions.afficherFenetreSupprimerPoste(id_poste); // FIXME
                }
                else {
                    app.fiche_du_poste.removeRows(0, 1); // TODO : implémenter
                }
            }
        }

        FicheDuPoste {
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.preferredWidth: 200 // FIXME
        }
    }
}
