/**
 * This element shows a timetable for a week divided into
 * days. The days are divided into 7 two-hour time slots.
 *
 * An event can be added into each of these slots, which will
 * emit the eventAdded signal.
 *
 * Currently only one event can be added to a single slot. They
 * can be removed, which will emit the eventRemoved signal.
 *
 * A model must be explicitly given to the model property. This is
 * kind of assumed to be a Timekeeper object.
 */
import QtQuick 2.0
import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import fr.ldd.qml 1.0
import QtWebKit 3.0
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0

import "variables.js" as Variables
import "fonctions.js" as Fonctions

Item {
    id:root

// DateTimePicker { }
/*
    Rectangle {

        id: blockParent


        anchors.fill: parent
        anchors.top: parent.top
        anchors.left:parent.left



        // Le rectangle contenant la liste des horaires
        Rectangle {

            id: blockEmploiTemps
            anchors.fill: parent
            clip: true
            ListView {
                id: listeDesHeures
                anchors.fill: parent
                model: listeHeures
                clip: true

                delegate: Text {
                    //text: Fonctions.dateEmploiDuTemps(heure)
                    text: Fonctions.dateEmploiDuTemps(heure)+" \t \t "+Fonctions.dateFR(heure)
                    // Si heure = 00 ou debut nom du jour sinon heure seule
                    height: 13
                }
            }
        }


        // Le model contenant les horaires
        ListModel {
            id: listeHeures
        }


        // L'item permettant de charger le début, puis de peupler la liste
        Item {
            id: chargeurDeDebut

            Component.onCompleted: {
                console.log("Debut chargé") ;
                Variables.setDebut("ok");

                if(Variables.getFin()!="" && Variables.getDebut()!="")
                {
                    ajouterHoraires();
                }

                function ajouterHoraires()
                {

                    var heureCourante = new Date(app.heureMin.getTime());
                    var heureDeFin = new Date(app.heureMax.getTime());

                    listeHeures.append({"heure": heureCourante}); // On met la 1ere heure en tete de liste

                    while(heureCourante < heureDeFin)// while(heureCourante<fin)
                    {
                        heureCourante.setHours (heureCourante.getHours() + 1 );
                        listeHeures.append({"heure": heureCourante});
                    }

                    listeHeures.append({"heure": heureDeFin});
                }
            }
        }


        // L'item permettant de charger la fin, puis de peupler la liste
        Item {
            id: chargeurDeFin
            Component.onCompleted: {
                console.log("Fin chargé") ;
                Variables.setFin("ok");

                if(Variables.getFin()!="" && Variables.getDebut()!="")
                {
                    ajouterHoraires();
                }

                function ajouterHoraires()
                {

                    var heureCourante = new Date(app.heureMin.getTime());
                    var heureDeFin = new Date(app.heureMax.getTime());

                    listeHeures.append({"heure": heureCourante}); // On met la 1ere heure en tete de liste

                    while(heureCourante < heureDeFin)// while(heureCourante<fin)
                    {
                        heureCourante.setHours (heureCourante.getHours() + 1 );
                        listeHeures.append({"heure": heureCourante});
                    }

                    listeHeures.append({"heure": heureDeFin});
                }
            }
        }







    } */

}
