import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2

Window {
    visible: true
    width: 538
    height: 360
ToolBar {
    id: toolbar
    width: parent.width

    ListModel {
        id: delegatemenu
        ListElement { text: "Shiny delegate" }
        ListElement { text: "Scale selected" }
        ListElement { text: "Editable items" }
    }

    ComboBox {
        id: delegateChooser
        model: delegatemenu
        width: 150
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }
}

ListModel {
    id: largeModel
    Component.onCompleted: {
        for (var i=0 ; i< 50 ; ++i)
            largeModel.append({"name":"Person "+i , "age": Math.round(Math.random()*100), "gender": Math.random()>0.5 ? "Male" : "Female"})
    }
}


Item {
    anchors.fill: parent

    Component {
        id: editableDelegate
        Item {

            Text {
                width: parent.width
                anchors.margins: 4
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                elide: styleData.elideMode
                text: styleData.value !== undefined ? styleData.value : ""
                color: styleData.textColor
                visible: !styleData.selected
            }
            Loader {
                id: loaderEditor
                anchors.fill: parent
                anchors.margins: 4
                Connections {
                    target: loaderEditor.item
                    onAccepted: {
                        if (typeof styleData.value === 'number')
                            largeModel.setProperty(styleData.row, styleData.role, Number(parseFloat(loaderEditor.item.text).toFixed(0)))
                        else
                            largeModel.setProperty(styleData.row, styleData.role, loaderEditor.item.text)
                    }
                }
                sourceComponent: styleData.selected ? editor : null
                Component {
                    id: editor
                    TextInput {
                        id: textinput
                        color: styleData.textColor
                        text: styleData.value
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: textinput.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }
    TableView {
        model: largeModel
        anchors.margins: 12
        anchors.fill:parent

        TableViewColumn {
            role: "name"
            title: "Name"
            width: 120
        }
        TableViewColumn {
            role: "age"
            title: "Age"
            width: 120
        }
        TableViewColumn {
            role: "gender"
            title: "Gender"
            width: 120
        }


            itemDelegate: {
                return editableDelegate;
            }
        }
    }
}
