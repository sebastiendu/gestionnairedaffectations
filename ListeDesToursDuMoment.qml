import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Rectangle {
    color: "#333333"
    implicitWidth: 350 // TODO pas codé en dur
    implicitHeight: children[0].implicitHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        Label {
            text: qsTr("Liste des tours à %1").arg(app.heure.toLocaleTimeString(null, {hour: "numeric", minute: "2-digit"}))
            font.pointSize: 16
            color: "#CCCCCC"
        }
        ScrollView {
            Layout.fillWidth: true
//            implicitHeight: 200 // TODO pas codé en dur

            flickableItem.interactive: true

            ListView {
                id: liste

                model: app.proxy_de_la_liste_des_postes_de_l_evenement_par_heure
                delegate: Rectangle {
                    property int _id_tour: id_tour
                    property int _id_poste: id_poste

                    height: children[0].height
                    width: parent.width

                    Text {
                        text: qsTr("De %1 à %2 (%3) : %4")
                        .arg(debut.toLocaleTimeString(null, {hour: "2-digit", minute: "2-digit"}))
                        .arg(fin.toLocaleTimeString(null, {hour: "2-digit", minute: "2-digit"}))
                        .arg((new Date(0,0,0,0,0,0,fin-debut)).toLocaleTimeString(null, {hour: "numeric", minute: "2-digit"}))
                        .arg(nom)
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideLeft
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: liste.currentIndex = index
                    }
                }
                highlight: Rectangle {
                    width: liste.currentItem.width
                    height: liste.currentItem.height
                    z: 5
                    color: "blue"
                    opacity: 0.5
                    y: liste.currentItem.y
                }
                highlightFollowsCurrentItem: false
                focus: true

                Keys.onUpPressed: decrementCurrentIndex()
                Keys.onDownPressed: incrementCurrentIndex()
                onCurrentItemChanged: {
                    app.setIdPoste(currentItem._id_poste);
                    app.setIdTour(currentItem._id_tour);
                }
            }
        }
    }
}
