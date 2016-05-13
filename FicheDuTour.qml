import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

Rectangle {
    color: "#333333"
    implicitWidth: 350 // TODO pas codé en dur
    implicitHeight: children[0].implicitHeight

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4

        Label {
            text: qsTr("Fiche du tour")
            font.pointSize: 16
            color: "#CCCCCC"
        }

        ListView {
            Layout.fillWidth: true
            implicitHeight: 160 // TODO pas codé en dur
            interactive: false
            model: app.fiche_du_tour
            delegate: ColumnLayout {
                width: parent.width
                // TODO : "de ... à ..."
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Layout.Right

                    TextField { // TODO DateSpinBox
                        id: _date_debut
                        Layout.fillWidth: true
                        implicitWidth: 11 * font.pointSize
                        placeholderText: qsTr("Date de début")
                    }

                    TextField { // TODO TimeSpinBox
                        id: _heure_debut
                        Layout.fillWidth: true
                        implicitWidth: 6 * font.pointSize
                        placeholderText: qsTr("Heure de début")
                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Layout.Right

                    TextField {
                        id: _date_fin
                        Layout.fillWidth: true
                        implicitWidth: 11 * font.pointSize
                        placeholderText: qsTr("Date de fin")
                    }

                    TextField {
                        id: _heure_fin
                        Layout.fillWidth: true
                        implicitWidth: 6 * font.pointSize
                        placeholderText: qsTr("Heure de fin")
                    }

                }

                SpinBox {
                    id: _min
                    Layout.fillWidth: true
                    implicitWidth: (prefix.length + suffix.length + 4) * font.pointSize
                    minimumValue: 1
                    maximumValue: _max.value
                    prefix: qsTr("au moins ")
                    suffix: qsTr(" personnes requises")
                }

                SpinBox {
                    id: _max
                    Layout.fillWidth: true
                    implicitWidth: (prefix.length + suffix.length + 4) * font.pointSize
                    minimumValue: _min.value
                    maximumValue: 99 // TODO : permettre plus
                    prefix: qsTr("au plus ")
                    suffix: qsTr(" personnes admises")
                }

                Button {
                    property var locale: Qt.locale()

                    function dateEtHeureEnsemble(d, t) {
                        d.setHours(t.getHours());
                        d.setMinutes(t.getMinutes());
                        return d;
                    }

                    Layout.fillWidth: true
                    text: qsTr("Enregistrer")
                    isDefault: true
                    onClicked: {
                        app.fiche_du_tour.setData(0, "debut", dateEtHeureEnsemble(
                                                      Date.fromLocaleDateString(locale, _date_debut .text, Locale.ShortFormat),
                                                      Date.fromLocaleTimeString(locale, _heure_debut.text, Locale.ShortFormat)));
                        app.fiche_du_tour.setData(0, "fin", dateEtHeureEnsemble(
                                                      Date.fromLocaleDateString(locale, _date_fin .text, Locale.ShortFormat),
                                                      Date.fromLocaleTimeString(locale, _heure_fin.text, Locale.ShortFormat)));
                        app.fiche_du_tour.setData(0, "min", _min.value);
                        app.fiche_du_tour.setData(0, "max", _max.value);
                        app.enregistrerTour();
                    }
                }

                Component.onCompleted: {
                    _date_debut.text = debut.toLocaleDateString(Locale.ShortFormat);
                    _heure_debut.text = debut.toLocaleTimeString(Locale.ShortFormat);
                    _date_fin.text = fin.toLocaleDateString(Locale.ShortFormat);
                    _heure_fin.text = fin.toLocaleTimeString(Locale.ShortFormat);
                    _max.value = max
                    _min.value = min
                }
            }
        }
    }
}
