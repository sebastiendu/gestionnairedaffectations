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
            text: qsTr("Fiche de l'affectation")
            font.pointSize: 16
            color: "#CCCCCC"
        }

        ListView {
            Layout.fillWidth: true
            implicitHeight: 260 // TODO pas codé en dur
            interactive: false
            model: app.fiche_de_l_affectation
            delegate: ColumnLayout { // dispo, tour, date, statut, commentaire
                width: parent.width

                Label { // FIXME définir ceci proprement (réfléchir au scénario d'utilisation de Q_Affectation{sListe,Plan})
                    text: qsTr("de %1 %2 au poste %3 de %4 à %5") // FIXME : pas les bonnes variables - se baser sur liste_des_affectations_du_tour ou liste_des_affectations_de_la_disponibilite
                    .arg(app.fiche_de_la_personne.data(0, "prenom"))
                    .arg(app.fiche_de_la_personne.data(0, "nom"))
                    .arg(app.fiche_du_poste.data(0, "nom"))
                    .arg(app.fiche_du_tour.data(0, "debut").toLocaleTimeString(null, {hour: "numeric", minute: "2-digit"}))
                    .arg(app.fiche_du_tour.data(0, "fin").toLocaleTimeString(null, {hour: "numeric", minute: "2-digit"}))
                    color: "#CCCCCC"
                }
                ExclusiveGroup { // FIXME faire respecter le schéma états-transitions
                    id: _statut
                }
                RowLayout {
                    Layout.fillWidth: true

                    RadioButton {
                        exclusiveGroup: _statut
                        readonly property string valeur: "possible"
                        text: qsTr("possible")
                        Component.onCompleted: checked = (statut === valeur)
                    }

                    RadioButton {
                        exclusiveGroup: _statut
                        readonly property string valeur: "validee"
                        text: qsTr("validée")
                        Component.onCompleted: checked = (statut === valeur)
                    }

                    RadioButton {
                        exclusiveGroup: _statut
                        readonly property string valeur: "proposee"
                        text: qsTr("proposée %1").arg(date_et_heure_proposee.toLocaleString())
                        Component.onCompleted: checked = (statut === valeur)
                    }

                    RadioButton {
                        exclusiveGroup: _statut
                        readonly property string valeur: "acceptee"
                        text: qsTr("acceptée")
                        Component.onCompleted: checked = (statut === valeur)
                    }

                    RadioButton {
                        exclusiveGroup: _statut
                        readonly property string valeur: "rejetee"
                        text: qsTr("rejetée")
                        Component.onCompleted: checked = (statut === valeur)
                    }

                    RadioButton {
                        exclusiveGroup: _statut
                        readonly property string valeur: "annulee"
                        text: qsTr("annulée")
                        Component.onCompleted: checked = (statut === valeur)
                    }
                }

                ColumnLayout {
                    spacing: 0

                    Label {
                        text: qsTr("Commentaire")
                        color: "#CCCCCC"
                    }

                    TextArea {
                        id: _commentaire
                        Layout.fillWidth: true
                        tabChangesFocus: true
                    }
                }

                Button {
                    text: qsTr("Enregistrer")
                    Layout.fillWidth: true
                    isDefault: true
                    activeFocusOnPress: true
                    onClicked: {
                        app.fiche_de_l_affectation.setData(0, "statut", _statut.current.valeur);
                        app.fiche_de_l_affectation.setData(0, "commentaire", _commentaire.text);
                        app.enregistrerAffectation();
                    }
                }

                Component.onCompleted: {
                    _commentaire.text = commentaire;
                }
            }
        }
    }
}
