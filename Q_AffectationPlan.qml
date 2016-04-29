import QtQuick 2.3
import QtQuick.Layouts 1.1

// Comme AffectationListe mais sans la liste des postes et tours, remplacée par le plan et la fiche du poste
// TODO : sortir le slider et le plan dans leur propre fichier

Item  {
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true

            ListeDesDisponibilites {
                Layout.fillWidth: true; Layout.fillHeight: true
            }

            FicheDeLaDisponibilite {
                Layout.fillWidth: true; Layout.fillHeight: true
            }

            ListeDesAffectationsDeLaDisponibilite {
                Layout.fillWidth: true; Layout.fillHeight: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true

            PlanDesPostesDansLeTemps {
                Layout.fillWidth: true; Layout.fillHeight: true
            }

            FicheDeLAffectation {
                Layout.fillWidth: true; Layout.fillHeight: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true

            ListeDesToursDuMoment {
                Layout.fillWidth: true; Layout.fillHeight: true
            }

            FicheDuPoste {
                Layout.fillWidth: true; Layout.fillHeight: true
            }

            FicheDuTour {
                Layout.fillWidth: true; Layout.fillHeight: true
            }

            ListeDesAffectationsDuTour {
                Layout.fillWidth: true; Layout.fillHeight: true
            }
        }
    }
}
