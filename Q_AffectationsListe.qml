import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.2

Item {
    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout { // liste des dispo et fiche du participant
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
            }

            ColumnLayout { // liste des tours et fiche du tour
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListeDesToursParPoste {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                FicheDuTour {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

            }

        }

    }

}
