import QtQuick 2.3
import QtQuick.Layouts 1.1

RowLayout {

    PlanDeLEvenement {
        Layout.maximumWidth: parent.width - colonneDeDroite.width
        Layout.fillHeight: true
        Layout.fillWidth: true
        modeleListeDesPostes: app.liste_des_postes_de_l_evenement
        modifiable: true
    }

    ColumnLayout {
        id: colonneDeDroite

        FicheDuPoste {
        }

        ListeDesToursDuPoste {
            Layout.fillHeight: true
        }

        FicheDuTour {
        }
    }
}
