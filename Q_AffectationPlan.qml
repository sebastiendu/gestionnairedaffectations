import QtQuick 2.3
import QtQuick.Layouts 1.1

// Comme AffectationListe mais sans la liste des postes et tours, remplacée par le plan et la fiche du poste

RowLayout {
    anchors.fill: parent

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

        ChoixDeLHeure {
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true

                PlanDeLEvenement {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    modeleListeDesPostes: app.proxy_de_la_liste_des_postes_de_l_evenement_par_heure
                }

                FicheDeLAffectation {
                }
            }

            ColumnLayout {

                ListeDesToursDuMoment {
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
}
