import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

Window {
    id: parametresDeConnexionWindow
    title: "Paramètres de connexion à la base de données"
    minimumWidth: 400
    minimumHeight: 200
    modality: Qt.WindowModal
    RowLayout {
        anchors.centerIn: parent
        spacing: 16
        ColumnLayout {
            spacing: 8
            Column {
                Label {
                    text: "Host Name"
                }
                TextField {
                    id: hostname
                    text: app.settings.value("database/hostName")
                    onEditingFinished: app.settings.setValue("database/hostName", text)
                }
            }
            Column {
                Label {
                    text: "Port"
                }
                TextField {
                    id: port
                    text: app.settings.value("database/port")
                    onEditingFinished: app.settings.setValue("database/port", text)
                }
            }
            Column {
                Label {
                    text: "Database Name"
                }
                TextField {
                    id: databaseName
                    text: app.settings.value("database/databaseName")
                    onEditingFinished: app.settings.setValue("database/databaseName", text)
                }
            }
        }
        ColumnLayout {
            spacing: 8
            Column {
                Label {
                    text: "User Name"
                }
                TextField {
                    id: userName
                    text: app.settings.value("database/userName")
                    onEditingFinished: app.settings.setValue("database/userName", text)
                }
            }
            Column {
                Label {
                    text: "Password"
                }
                TextField {
                    echoMode: TextInput.PasswordEchoOnEdit
                    id: password
                    text: app.settings.value("database/password")
                    focus: true
                    onEditingFinished: app.settings.setValue("database/password",
                                                             rememberPassword.checked ? text : "")
                }
                CheckBox {
                    id: rememberPassword
                    text: "enregistrer"
                    checked: app.settings.value("database/rememberPassword")
                    onCheckedStateChanged: {
                        app.settings.setValue("database/rememberPassword", checked)
                        app.settings.setValue("database/password", (checked ? password.text : ""))
                    }
                }
            }
            Button {
                action: Action {
                    text: "Ouvrir la connexion"
                    onTriggered: {
                        if(app.ouvrirLaBase(password.text)) {
                            close();
                        } else {
                            messageDErreur.text=app.messageDErreurDeLaBase()
                            messageDErreur.open()
                        }
                    }
                }
            }
        }
    }
    MessageDialog {
        id: messageDErreur
        title: "Connexion impossible"
    }
}
