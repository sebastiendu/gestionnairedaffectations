import QtQuick 2.0
import QtQuick.Layouts 1.2

Item {

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListeDesDisponibilites {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                FicheDeLaDisponibilite {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                ListeDesAffectationsDeLaDisponibilite {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListeDesTours {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                FicheDuTour {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                ListeDesAffectationsDuTour {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

            }

        }

        FicheDeLAffectation {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        FicheDUneNouvelleAffectation {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
