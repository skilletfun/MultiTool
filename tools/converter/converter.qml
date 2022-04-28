import QtQuick 2.12
import QtQuick.Controls 2.12
import '../adds'

Rectangle {
    id: root

    DragAndDrop {
        anchors.fill: parent
        anchors.margins: 20

        _offsetY: -50
        _text: "Drag & Drop files here"

        onDropped: {
            converter.convert(String(drop.urls), destSuffix.currentText);
        }
    }

    Text {
        id: to
        text: qsTr("To")
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 70
        anchors.bottomMargin: 56
        font.pixelSize: 16
    }

//=====================================================================
// Suffix of converted file, that you would like to get
//=====================================================================

    ComboBox {
        id: destSuffix
        model: ["png", "jpeg", "webp", "ico"]
        height: 50
        width: 180
        anchors.bottom: parent.bottom
        anchors.left: to.right
        anchors.margins: 40
        font.pixelSize: 16
        background: Rectangle { border.width: 2; }

        delegate: Rectangle {
            height: 40
            width: destSuffix.width
            Text {
                text: modelData
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
                font.pointSize: 12
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    destSuffix.currentIndex = index;
                    destSuffix.popup.close();
                }
            }
        }
    }
}
