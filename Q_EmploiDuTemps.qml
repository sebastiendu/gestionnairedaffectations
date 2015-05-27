import QtQuick 2.3

Item {
    ListView {
        id: joursView
        anchors.fill: parent
        orientation: ListView.Horizontal
        model: app.sequence_emploi_du_temps
        delegate: Rectangle {
            height: parent.height
            width: proportion * parent.parent.width
            color: "transparent"
            Rectangle {
                anchors.centerIn: parent
                rotation: -90
                width: parent.height
                height: parent.width
                gradient: Gradient {
                    GradientStop {
                        position: 0;
                        color: "#8f8f8f";
                    }
                    GradientStop {
                        position: .25;
                        color: "#9f9f9f";
                    }
                    GradientStop {
                        position: .75;
                        color: "#9f9f9f";
                    }
                    GradientStop {
                        position: 1;
                        color: "#8f8f8f";
                    }
                }
                Text {
                    anchors.fill: parent
                    text: libelle_sequence
                    color: "lightgray"
                    font.bold: true
                    style: Text.Outline
                    styleColor: "gray"
                    fontSizeMode: Text.Fit
                    font.pixelSize: height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    ListView {
        id: listeTour
        anchors.fill: parent
        model: app.toursParPosteModel
        delegate: Component {
            Rectangle {
                gradient: Gradient {
                    GradientStop {
                        position: 0;
                        color: "#80808088";
                    }
                    GradientStop {
                        position: .25;
                        color: "#8f8f8f88";
                    }
                    GradientStop {
                        position: .75;
                        color: "#8f8f8f88";
                    }
                    GradientStop {
                        position: 1;
                        color: "#80808088";
                    }
                }
                height: parent.parent.height / (parent.parent.model.rowCount() + 1)
                width: parent.width
                Text {
                    anchors.fill: parent
                    text: nom
                    font.bold: true
                    style: Text.Outline
                    fontSizeMode: Text.Fit
                    font.pixelSize: height
                    color: "white"
                    styleColor: "gray"
                    font.letterSpacing: width / (20 * text.length)
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                Repeater {
                    model: tours // styleData.value
                    // 0 id, 1 debut, 2 durée, 3 min, 4 max, 5 debut, 6 fin, 7 effectif, 8 besoin, 9 faim, 10 taux
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: parent.width * modelData.split('|')[1] // debut
                        width: parent.width * modelData.split('|')[2] // durée
                        height: parent.height
                        radius: 5
                        //border.color: modelData.split('|')[10] === '100' ? "darkgreen" : modelData.split('|')[10] > 100 ? "#888800"  : "darkred" // taux
                        //border.width: modelData.split('|')[10] / 100
                        color: modelData.split('|')[9] === '0' ? "green" : modelData.split('|')[9] < 0 ? "yellow"  : "red" // faim
                        opacity: 0.75
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: console.info("setIdTour(" + modelData.split('|')[0] + ") (TODO)")

                            onEntered: {
                                 info.visible = true
                                 info.y = y
                                 //resumeTour.text = parent.index
                                 titreTour.text = id
                            }
                            onExited: {
                                info.visible = false
                            }
                        }
                    }
                }



                }
            }

        Rectangle {
            id: info
            color: "white"
            radius:5
            border.color: "black"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: parent.width*0.3
            width: parent.width*0.4
            visible: false
            height: 50

            Text {
                id: titreTour
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.topMargin: 10

            }

            Text {
                id: resumeTour
                anchors.top: titreTour.bottom
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.topMargin: 10
            }
        }
    }
}
