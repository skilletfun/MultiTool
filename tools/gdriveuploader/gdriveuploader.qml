import QtQuick 2.12
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import '../adds'

Rectangle {
    id: root

    property string urls: ''

    Rectangle {
        id: dropped_files_rect
        anchors.left: parent.left
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 20

        property bool flag_dropped: false

        DragAndDrop {
            id: dropFiles
            visible: !parent.flag_dropped
            anchors.fill: parent

            _text: "Drag & Drop 'Files' here"

            onDropped: {
                parent.flag_dropped = true;
                root.urls = String(drop.urls);

                var arr = String(drop.urls).split(',');
                var result = [];
                for (var i = 0; i < arr.length; i++)
                {
                    if (arr[i].length > 32) result.push('...' + arr[i].slice(arr[i].length - 32));
                    else result.push(arr[i]);
                }
                dropped_fiels_list.model = result
            }
        }

        Rectangle {
            visible: parent.flag_dropped
            anchors.fill: parent
            border.width: 2
            border.color: 'green'

            ListView {
                id: dropped_fiels_list
                anchors.fill: parent
                anchors.topMargin: 50
                anchors.margins: 2
                clip: true
                spacing: 10

                delegate: Rectangle {
                    width: dropped_fiels_list.width
                    height: 20
                    color: "transparent"
                    Text {
                        text: modelData
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        font.pointSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Image {
                anchors.left: parent.right
                anchors.bottom: parent.top
                anchors.margins: -40
                fillMode: Image.PreserveAspectFit
                width: 32
                height: width
                mipmap: true
                source: 'reset.png'

                MouseArea {
                    anchors.fill: parent
                    onReleased: { dropped_files_rect.flag_dropped = false; }
                }
            }
        }
    }

    TextField {
        id: gdrive_field
        anchors.top: dropped_files_rect.top
        anchors.left: parent.horizontalCenter
        anchors.margins: 20
        anchors.right: parent.right
        height: 50
        placeholderText: "Paste GDrive URL here..."
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 14
        selectionColor: "#00de4b"

        background: Rectangle {
            border.width: 1; radius: 5; color: gdrive_field.focus ? '#f2f2f2' : 'white'
        }

        onAccepted: { focus = false; }

        Image {
            visible: parent.text != ''
            source: 'star.png'
            mipmap: true
            height: 24
            width: height
            anchors.right: parent.left
            anchors.bottom: parent.top

            MouseArea {
                anchors.fill: parent
                onReleased: { add_favore.visible = true; add_favore_field.focus = true; }
            }

            Rectangle {
                id: add_favore
                visible: false
                border.width: 1
                height: 30
                width: 150
                anchors.left: parent.right
                anchors.leftMargin: 10
                anchors.bottom: parent.top
                anchors.bottomMargin: -20

                TextField {
                    id: add_favore_field
                    anchors.fill: parent
                    font.pointSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    onAccepted: {
                        focus = false;
                        add_favore.visible = false;
                        favorite_list.model = gdriveuploader.add_favorite(text, gdrive_field.text);
                    }
                }
            }
        }
    }

    ListView {
        id: favorite_list
        anchors.top: gdrive_field.bottom
        anchors.bottom: upload.top
        anchors.left: gdrive_field.left
        anchors.right: gdrive_field.right
        anchors.topMargin: 20
        anchors.bottomMargin: 20
        clip: true
        spacing: 5
        model: gdriveuploader.get_favorite_list()

        delegate: Rectangle {
            width: favorite_list.width
            height: 30
            color: area.containsMouse ? '#f2f2f2' : "transparent"
            radius: 5
            Text {
                text: modelData
                anchors.left: parent.left
                anchors.leftMargin: 20
                font.pointSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                onReleased: { gdrive_field.text = gdriveuploader.get_favorite(modelData); }
            }
            Image {
                visible: area.containsMouse
                source: 'delete.png'
                mipmap: true
                height: parent.height * 0.9
                width: height
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10
                MouseArea {
                    anchors.fill: parent
                    onReleased: { favorite_list.model = gdriveuploader.remove_favorite(modelData); }
                }
            }
        }
    }

    Button {
        id: upload
        enabled: dropped_files_rect.flag_dropped
        height: 50
        width: gdrive_field.width * 0.7
        anchors.bottom: dropped_files_rect.bottom
        anchors.horizontalCenter: gdrive_field.horizontalCenter
        text: 'Upload'
        font.pixelSize: 14

        background: Rectangle {
            border.width: 1; radius: 5; color: upload.down ? '#f2f2f2' : 'white'
        }

        onReleased: { gdriveuploader.upload(String(root.urls), gdrive_field.text); }
    }
}
