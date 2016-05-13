import QtQuick 2.0
import QtQuick.Layouts 1.2

ColumnLayout {
    anchors.fill: parent

    RowLayout {

        ColumnLayout {

            ListeDesDisponibilites {
                Layout.fillHeight: true
            }

            FicheDeLaPersonne {
            }

            FicheDeLaDisponibilite {
            }

            ListeDesAffectationsDeLaDisponibilite {
                Layout.fillHeight: true
            }
        }

        ColumnLayout {

            BoutonAffecter {
                Layout.fillWidth: true
            }

            FicheDeLAffectation {
                Layout.fillWidth: true
            }
        }

        ColumnLayout {

            ListeDesTours {
                Layout.fillHeight: true
            }

            FicheDuPoste {
            }

            FicheDuTour {
            }

            ListeDesAffectationsDuTour {
                Layout.fillHeight: true
            }
        }
    }
}
