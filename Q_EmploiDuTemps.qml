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

Item {
    id:root

    property variant model
    signal timeSlotClicked (int day, int timeslot)


    /* Week - row containing 7 days: */
    Row {
        anchors.fill: parent
        spacing: 1

        Repeater {
            model: root.model
            id: dayrepeater

            /* Day - Column containing 7 timeslots: */
            Rectangle {
                id: dayColumn
                width: root.width / 7
                height: root.height
                opacity: 0

                //label:
                Rectangle {
                    id: daylabelContainer
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: daylabel.paintedHeight
                    color: "#888"

                    Text {
                        id: daylabel
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: day.toUpperCase()
                        color: "white"

                    }
                }

                //--------------------------
                //-------Animation effects:


                /** Fancy opacity animation that triggers the
                    next column too at about the halfway point. */
                SequentialAnimation {
                    id: animate
                    PropertyAnimation {
                        target: dayColumn;
                        from:0; to: 0.6; property: "opacity"
                        duration: 50
                    }
                    ScriptAction { script: showNext() }
                    PropertyAnimation {
                        target: dayColumn;
                        to: 1; property: "opacity"
                        duration: 100
                    }
                }

                /** shows this column */
                function show() {
                    animate.start()
                }

                /** shows the next column in the repeater */
                function showNext() {
                    if(index < 6) {
                        dayrepeater.itemAt(index+1).show();
                    }
                }

                /** hides this column */
                function hide() {
                    opacity = 0
                }


                //-------------------
                //---Time slots:

                Column {
                    anchors.top: daylabelContainer.bottom
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 1
                    width: parent.width
                    spacing: 1

                    Repeater {
                        model: dayModel

                        /* Two-hour time slot that can be clicked */
                        Rectangle {
                            id: timeslot
                            width: parent.width
                            height: parent.height / 7
                            color: timeslotArea.containsMouse ? "#EEE" : "#BBB"
                            clip: true

                            MouseArea {
                                id: timeslotArea
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: parent.visible

                                //when clicked, indicate day and slot by their Repeater indices:
                                onClicked: timeSlotClicked(day, index)
                            }

                            //hour label
                            Text {
                                text: hour
                                color: "#666"
                            }

                            //event description
                            Text {
                                text: dayEvent
                                anchors.centerIn: parent
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                width: parent.width
                            }
                        }
                    }

                }
            }
        }
    }

    // functions for fancy animations:

    function show() {
        dayrepeater.itemAt(0).show();
        visible = true
    }

    function hide() {
        for (var i=0; i<7; i++) {
            dayrepeater.itemAt(i).hide();
        }
        visible = false
    }
}
