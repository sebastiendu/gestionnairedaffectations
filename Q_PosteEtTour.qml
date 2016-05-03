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
            fonctionAjouterPoste: function (x, y) { // FIXME
                app.setRatioX(x);
                app.setRatioY(y);
                Fonctions.afficherFenetreNouveauPoste();
            }
            fonctionDeplacerPoste: function (id_poste, x, y) { // FIXME
                app.setIdPoste(id_poste);
                app.modifierPositionPoste(x, y);
            }
            fonctionSupprimerPoste: function (id_poste) { // FIXME
                app.setIdPoste(id_poste);
                if (app.getNombreDeTours() > 0 || app.getNombreDAffectations() > 0) {
                    Fonctions.afficherFenetreSupprimerPoste(id_poste);
                }
                else {
                    app.supprimerPoste(id_poste);
                }
            }
        }

        Rectangle { // Bloc de définition du poste et de ses tours, invisible par défaut
            id: descriptionPoste
            visible: false
            Layout.fillWidth: true; Layout.fillHeight: true

            Label {
                id : _nom
                text: "Poste:"
            }

            TextField {
                id: _nomPoste
                placeholderText: "Nom du poste"
                onEditingFinished: {
                    console.log("Edition finie, je suis appellé!!");
                    app.modifierNomPoste(_nomPoste.text)
                }
            }

            Label {
                id : _description
                text: "Description:"
            }

            TextArea { // TODO : Retour à la ligne automatique
                id: _descriptionPoste
            }

            Button {
                id: _btnSauvegarderChangements
                text: "Enregistrer"
                onClicked: {
                    app.modifierNomPoste(_nomPoste.text)
                    app.modifierDescriptionPoste(_descriptionPoste.text)
                    app.rechargerPlan();
                }
            }

            RectangleTitre {

                id: blockResponsable
                couleur : "#bdc3c7"
                titre: "Responsable"

                TableView { // liste des responsables
                    id: tableauResponsable

                    model: app.responsables
                    sortIndicatorVisible: true

                    TableViewColumn{ role: "id_personne"  ; title: "id" ;  visible: true}
                    TableViewColumn{ role: "nom"  ; title: "Nom" ;  horizontalAlignment: Text.AlignHCenter; width:(tableauTours.width/4)-1;}
                    TableViewColumn{ role: "prenom" ; title: "Prenom" ; horizontalAlignment: Text.AlignHCenter;width:(tableauTours.width/4)-1;}
                    TableViewColumn{ role: "portable"  ; title: "Téléphone" ;  horizontalAlignment: Text.AlignHCenter; width:(tableauTours.width/4)-1;}
                    TableViewColumn{ role: "email" ; title: "Email" ; elideMode: Text.ElideMiddle; width:(tableauTours.width/4)-1}

                    Connections {
                        target: app
                        onTableauResponsablesChanged: {
                            // tableauResponsable.model = app.responsables;
                            console.log("maj")
                        }
                    }
                }

                ComboBox {
                    id: choixResponsable

                    editable: true
                    model: app.liste_des_disponibilites_de_l_evenement
                    textRole: "nom_personne"

                    onCurrentIndexChanged: {
                        console.log(currentIndex) // On appelle la fonction permettant entre autre de charger toutes les informations du nouvel évenement
                    }
                }

                Button {
                    id: ajouterResponsable
                    text: " + "
                    onClicked: {
                        app.ajouterResponsable(
                                    app.liste_des_disponibilites_de_l_evenement.getDataFromModel(
                                        choixResponsable.currentIndex,"id_personne"
                                        )
                                    )
                    }
                }

                Button {
                    id: rejeterResponsable
                    text: " - "
                    onClicked: {
                        console.log("QML rejete : "+ app.responsables.getDataFromModel(tableauResponsable.currentRow,"id_personne"))
                        app.rejeterResponsable(app.responsables.getDataFromModel(tableauResponsable.currentRow,"id_personne"));
                    }
                }
            }

            TableView { // tableau modifiable des tours du poste
                id: tableauTours
                selectionMode: SelectionMode.SingleSelection
                model: app.fiche_poste_tour

                TableViewColumn{ role: "id";    title: "id";            horizontalAlignment: Text.AlignHCenter; width: 3*tableauTours.width/10 - 1; delegate: id_tour; visible: false }
                TableViewColumn{ role: "debut"; title: "Debut du tour"; horizontalAlignment: Text.AlignHCenter; width: 4*tableauTours.width/10 - 1; delegate: debut }
                TableViewColumn{ role: "fin";   title: "Fin du tour";   horizontalAlignment: Text.AlignHCenter; width: 4*tableauTours.width/10 - 1; delegate: fin }
                TableViewColumn{ role: "min";   title: "Min";           horizontalAlignment: Text.AlignHCenter; width:   tableauTours.width/10 - 1; delegate: nombre }
                TableViewColumn{ role: "max";   title: "Max";           horizontalAlignment: Text.AlignHCenter; width:   tableauTours.width/10 - 1; delegate: nombre }

                Component { // le champ date de debut
                    id: debut

                    Item {

                        Text {
                            id: inputDate
                            color: styleData.selected ? "white" : "black"
                            text: Fonctions.dateFR(styleData.value)
                        }

                        Button {
                            id: boutonCalendrier
                            width: parent.width*0.15
                            text: "v"
                            onClicked : { Fonctions.afficherFenetreAjouterTour("debut",styleData.value,tableauTours.model.getDataFromModel(styleData.row,"id"),styleData.value.getHours(),styleData.value.getMinutes())}
                        }
                    }
                }

                Component { // un champ date
                    id: fin

                    Item { // une date avec un bouton pour en selectionner une autre

                        Text { // date
                            id: inputDate
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            color: styleData.selected ? "white" : "black"
                            text: Fonctions.dateFR(styleData.value)
                        }

                        Button {
                            id: boutonCalendrier
                            width: parent.width*0.15
                            text: "v"
                            onClicked : { Fonctions.afficherFenetreAjouterTour("fin",styleData.value,tableauTours.model.getDataFromModel(styleData.row,"id"),styleData.value.getHours(),styleData.value.getMinutes())}
                        }
                    }
                }

                Component { // un champ nombre ???
                    id: nombre

                    Item { // ???

                        TextInput {
                            id: nouveauNombre // FIXME, même id utilisé plus bas
                            anchors.fill: parent
                            text: styleData.value
                            color: styleData.selected ? "white" : "black"
                            font.bold: activeFocus
                            font.pixelSize: activeFocus ? 16 : 13
                            // activeFocusOnPress: false
                            //   selectByMouse: true
                            horizontalAlignment: TextInput.AlignHCenter

                            onEditingFinished:  {
                                if(styleData.value != nouveauNombre.text)
                                {
                                    app.modifierTourMinMax(styleData.role, nouveauNombre.text, tableauTours.model.getDataFromModel(styleData.row,"id"))
                                    font.pixelSize = 13

                                    console.log("On enregistre");
                                }
                                else
                                    console.log("On enregistre pas")
                            }

                        }

                        MouseArea { // ???
                            id: zoneSelection // FIXME, même id utilisé plus bas
                            anchors.fill: parent
                            onClicked: {
                                console.log("clic");
                                tableauTours.selection.clear();
                                tableauTours.selection.select(styleData.row );
                                console.log(styleData.role);
                                nouveauNombre.forceActiveFocus();
                                console.log(tableauTours.model.getDataFromModel(styleData.row,"id"))
                            }
                        }
                    }
                }

                Component { // ???
                    id: id_tour

                    Item {

                        TextInput { // ???
                            //property int idDuTour: 0
                            id: nouveauNombre
                            anchors.fill: parent
                            text: styleData.value
                            // activeFocusOnPress: false
                            //   selectByMouse: true
                            onAccepted: console.log(styleData.value + " " +nouveauNombre.text)
                        }

                        MouseArea { // ???
                            id: zoneSelection
                            anchors.fill: parent
                            onClicked: {
                                tableauTours.selection.clear();
                                tableauTours.selection.select(styleData.row);
                                nouveauNombre.forceActiveFocus();
                            }
                        }
                    }
                }

                Connections { // ???
                    target: app
                    onTableauTourChanged: {
                        tableauTours.model = app.fiche_poste_tour;
                    }
                }
            }

            Button {
                id: _btnAjouterTour
                text: "+"
                onClicked: {
                    if(tableauTours.rowCount == 0) {
                        app.insererTour(app.heureMin,1,1);
                        tableauTours.selection.select(0);
                    }
                    else {
                        app.insererTour(tableauTours.model.getDataFromModel(tableauTours.rowCount-1,"fin"),tableauTours.model.getDataFromModel(tableauTours.rowCount-1,"min"),tableauTours.model.getDataFromModel(tableauTours.rowCount-1,"max"))
                        tableauTours.selection.select(tableauTours.rowCount-1);
                    }
                }
            }

            Button {
                id: _btnSupprimerTour
                text: "-"
                onClicked: {
                    app.supprimerTour(tableauTours.model.getDataFromModel(tableauTours.currentRow,"id"));
                }
            }
        }
    }
}
