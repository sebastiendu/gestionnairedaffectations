import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Item {

    RowLayout {
        anchors.fill: parent

        PlanDeLEvenement {
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.preferredWidth: cote
            Layout.preferredHeight: cote

            modeleListeDesPostes: app.liste_des_postes_de_l_evenement
            modifiable: true
        }

        FicheDuPoste {
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.preferredWidth: 200 // FIXME
        }
    }
}
