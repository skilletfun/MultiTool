import QtQuick 2.12
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import '../adds'

Rectangle {
    id: root

    signal extract(var arch)
    signal pack(var files)

    onExtract: {
        archiver.extract(arch);
    }

    onPack: {
        archiver.pack(files);
    }

    DragAndDrop {
        id: dropArchive
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.horizontalCenter
        anchors.margins: 20

        _text: "Drag & Drop 'Archive' here"

//=====================================================================
// Extract archive
//=====================================================================

        onDropped: {
            root.extract(drop.urls);
        }
    }

    DragAndDrop {
        id: dropFiles
        anchors.left: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20

        _text: "Drag & Drop 'Files' here"

//=====================================================================
// Pack archive to 'archive.zip'
//=====================================================================

        onDropped: {
            root.pack(String(drop.urls));
        }
    }
}
