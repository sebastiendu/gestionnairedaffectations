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

import "variables.js" as Variables

Item {
    id:root


    Rectangle {

        id: blockParent


        anchors.fill: parent
        anchors.top: parent.top
        anchors.left:parent.left


        ListView {
            id: listeDebut

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 5
            model: debut
            height: 13
            delegate: Text {

                text: date
                height: 13
                Component.onCompleted: {
                    console.log("Debut chargé") ;
                    Variables.setDebut(date);
                    console.log(Variables.getDebut());

                    if(Variables.getFin()!="" && Variables.getDebut()!="")
                    {
                        listeHeures.append({"heure": "15h20"});
                        ajouterHoraires(Variables.getDebut(), Variables.getFin());
                    }

                    function ajouterHoraires(debut, fin)
                    {

                        Variables.heureCourante = debut;
                        var i=0

                        while(i++<10)// while(heureCourante<fin)
                        {
                            Variables.heureCourante.setHours ( Variables.heureCourante.getHours() + 1 );
                            console.log(Variables.heureCourante);
                        }
                    }
                }
            }


        }

        Rectangle {
            id: blockEmploiTemps
            anchors.top: listeDebut.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            ListView {
                id: chargement
                anchors.fill: parent
                model: listeHeures
                delegate: Text {
                    text: heure
                    height: 13
                }
            }
        }


        ListView {
            id: listeFin
            anchors.top : blockEmploiTemps.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 5
            model: fin
            delegate: Text {
                text: date
                height: 13

                Component.onCompleted: {
                    console.log("Fin chargé") ;
                    Variables.setFin(date);
                    console.log(Variables.getFin());

                    if(Variables.getFin()!="" && Variables.getDebut()!="")
                    {
                        listeHeures.append({"heure": "15h20"});
                        ajouterHoraires(Variables.getDebut(), Variables.getFin());
                    }
                }
            }
            height: 13

        }


        ListModel {
            id: debut

            ListElement {
                date: "13/11/2014 9h00"
            }

        }

        ListModel {
            id: fin

            ListElement {
                date: "15/11/2014 17h00"
            }

        }

        ListModel {
            id: listeHeures
        }


        function ajouterHoraires(debut, fin)
        {

            Variables.heureCourante = debut;
            i=0

            while(i++<10)// while(heureCourante<fin)
            {
                heureCourante.setHours ( heureCourante.getHours() + 1 );
                console.log(heureCourante);
            }
        }


    }

}
