import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import '../adds'

Rectangle {
    id: root

    property bool b_drop: true

    signal dropped(var drop)
    signal changeIndex(var index_src, var index_dest)
    signal deleteFileFromModel(var index)

    DragAndDrop {
        id: dropFiles
        visible: parent.b_drop
        anchors.fill: parent
        anchors.margins: 20

        _text: "Drag & Drop 'Files for Rename' here"

        onDropped: {
            root.dropped(drop);
            parent.b_drop = false;
        }
    }

    Item {
        visible: !parent.b_drop
        anchors.fill: parent

        MouseArea {
            id: area
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: containsMouse ? parent.width/2.5 : parent.width/8
            anchors.margins: 5
            anchors.topMargin: 20
            hoverEnabled: true

            Behavior on width { NumberAnimation { duration: 150 } }

            ListView {
                id: smallView
                model: filesModel
                spacing: 5
                anchors.fill: parent
                anchors.margins: 2
                clip: true

                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        easing.type: Easing.OutQuad
                        duration: 200
                    }
                }

                delegate: DroppableRect {
                    id: rect
                    _spacing: smallView.spacing
                    width: smallView.width
                    height: 40

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        font.pixelSize: 15
                        text: name
                    }

                    onDropped: {
                        root.changeIndex(srcIndex, destIndex);
                    }

                    onDoubleClicked: {
                        root.deleteFileFromModel(index);
                    }
                }
            }
        }

        Rectangle {
            id: vLine
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: area.right
            anchors.leftMargin: 5
            anchors.margins: 20
            color: 'grey'
        }

        Text {
            anchors.bottom: mask.top
            anchors.bottomMargin: 50
            anchors.left: mask.left
            anchors.right: mask.right
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 14

            text: 'Arabic:  ?A:1:1?\nRome:  ?R:1:1?\nExample:  File_?A:1:1'
        }

        TextField {
            id: mask
            height: 60
            anchors.left: vLine.right
            anchors.right: parent.right
            anchors.margins: 60
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 14
            placeholderText: 'Type mask for rename...'

            background: Rectangle {
                border.width: 1; radius: mask.height/2 - 8; border.color: mask.focus ? 'blue' : 'black'
            }

            onAccepted: { focus = false; }
        }

        Button {
            id: startRename
            enabled: mask.text != ''
            anchors.top: mask.bottom
            anchors.topMargin: 50
            anchors.horizontalCenter: mask.horizontalCenter
            width: 200
            height: 50
            text: "Rename"
            font.pixelSize: 14
            anchors.margins: 20

            background: Rectangle {
                color: startRename.down ? '#e7e7e7' : 'white'; border.width: 1; radius: startRename.height/2 - 8
            }

            onReleased: {
                var arr = [];
                for (var i = 0; i < filesModel.count; i++)
                {
                    arr.push(filesModel.get(i).url);
                }
                renamer.rename_files(String(arr), mask.text);
                root.b_drop = true;
                filesModel.clear();
            }
        }
    }


    ListModel {
        id: filesModel
    }

    onDropped: {
        for (var i = 0;; i++)
        {
            var s = String(drop.urls[i]);
            var arr = s.split('/');
            var n = String(arr[arr.length -1]);

            if (s === "undefined") break;
            else filesModel.append({"name": n, "url": drop.urls[i]});
        }
    }

    onChangeIndex: {
        filesModel.move(index_src, index_dest, 1);
    }

    onDeleteFileFromModel: {
        filesModel.remove(index);
    }
}
