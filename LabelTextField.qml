import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Item {

    property string valeur: texteTextField.text // Ce que contient le textfield. Accessible en lecture uniquement
    property string texte: texte.text  // Le nom dans le placeholder + texte
    property bool memeTexte : true // Si le label et le placeholder doivent avoir le meme texte
    property string placeHolder : "" // La valeur du placeHolder si memeTexte est à faux
    property int taille : 0 // Taille du textField
    property int largeur: labelTexte.width + texteTextField.width + texteTextField.anchors.leftMargin // Largeur totale

    function vider() {
        texteTextField.text = "";
    }

    function focusField() {
        texteTextField.focus = true;
    }

    height: texteTextField.height

    Label {
        id: labelTexte
        text: texte + ": "
        anchors.top: parent.top
        anchors.topMargin: (texteTextField.height - height)/2
        anchors.left: parent.left

    }

    TextField {
        id: texteTextField
        placeholderText: (memeTexte == true) ? texte : placeHolder
        anchors.left: labelTexte.right
        anchors.leftMargin: 10
        width: (taille ==0) ? 200 : taille
    }
}
