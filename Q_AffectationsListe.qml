import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.2

Item {
    RowLayout {
        anchors.fill: parent

        ColumnLayout { // liste des dispo et fiche du participant
            Layout.preferredWidth: parent.width / 2
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

        Rectangle { // Liste des tours, boutons et fiche du tour TODO remplacer par un layout avec un spacing et virer les margins des blocks regroupés ici
            id: blockPosteTour
            Layout.preferredWidth: parent.width/2
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "white"

            ListeDesToursParPoste {
                id: listeDesToursParPoste
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 10
                anchors.bottom: parent.verticalCenter
            }

            Button {
                id: _boutonEnvoyer // TODO : Renommer
                anchors.top: listeDesToursParPoste.bottom
                anchors.left: parent.left
                anchors.leftMargin: 10
                text : "→"
                onClicked : {
                    console.log("Cliqué");
                    app.affecterBenevole();
                    app.setIdDisponibilite(-1)
                    listePersonnesInscritesBenevoles.model = app.affectations_acceptees_validees_ou_proposees_du_tour;
                    listeDesToursParPoste.model = app.poste_et_tour;

                }
            }

            Button {
                id: _boutonRecevoir // TODO : Renommer
                anchors.top: _boutonEnvoyer.bottom
                anchors.topMargin: 10
                anchors.left: parent.left
                text : "←"
                anchors.leftMargin: 10
                onClicked: {
                    console.log("index:" + listePersonnesInscritesBenevoles.currentIndex);
                    console.log("model: " + listePersonnesInscritesBenevoles.model.getDataFromModel(listePersonnesInscritesBenevoles.currentIndex,"id_affectation"))
                    app.desaffecterBenevole(listePersonnesInscritesBenevoles.model.getDataFromModel(listePersonnesInscritesBenevoles.currentIndex,"id_affectation"));
                    app.setIdDisponibilite(-1)
                    listePersonnesInscritesBenevoles.model = app.affectations_acceptees_validees_ou_proposees_du_tour;
                    listeDesToursParPoste.model = app.poste_et_tour;
                    // _boutonRecevoir.checkable = true

                }
            }

            FicheDuTour {
                id: blockFichePoste
                anchors.top: listeDesToursParPoste.bottom
                anchors.left: _boutonEnvoyer.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30
                anchors.topMargin: 15
                anchors.leftMargin: 10
                anchors.rightMargin: 10
            }


        }

    }

}
