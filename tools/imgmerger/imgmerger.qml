import QtQuick 2.12
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import "../adds"

Rectangle {
    id: root

    property bool b_append_enabled: false

    signal deleteImageFromModel(var index)
    signal dropped(var drop)
    signal changeIndex(var index_src, var index_dest)

    DragAndDrop {
        id: dropFolder
        visible: !parent.b_append_enabled
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.horizontalCenter
        anchors.margins: 20

        _text: "Drag & Drop 'Folder' here"

        onDropped: {
            var d = JSON.parse(imgmerger.get_list_from_url(drop.urls[0]));
            root.dropped(d);
            b_append_enabled = true;
        }
    }

    Text {
        visible: !parent.b_append_enabled
        anchors.centerIn: parent
        text: "or"
        font.pixelSize: 20
    }

    DragAndDrop {
        id: dropFiles
        visible: !parent.b_append_enabled
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.horizontalCenter
        anchors.margins: 20

        _text: "Drag & Drop 'Files' here"

        onDropped: {
            b_append_enabled = true;
            root.dropped(drop);
        }
    }

    ListModel {
        id: imgUrlsModel
    }

    //==============================
    // Left list with small images
    //==============================

    ListView {
        id: smallView
        visible: parent.b_append_enabled
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width/7
        anchors.margins: 20
        model: imgUrlsModel
        spacing: 5
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
            height: width * 1.5

            Image {
                id: icon
                source: url
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.bottomMargin: 25
                anchors.margins: 5
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                font.pixelSize: 15
                text: name
            }

            // Left List allows you 'Drag&Drop' images and change their positions
            onDropped: {
                root.changeIndex(srcIndex, destIndex);
            }

            // On Double Click appropriate image will be deleted from pool
            onDoubleClicked: {
                root.deleteImageFromModel(index);
            }

            // On click Main List will be scrolled to appropriate image
            onReleased: {
                mainView.positionViewAtIndex(index, ListView.Center);
            }
        }
    }

    Rectangle {
        visible: parent.b_append_enabled
        id: v_line
        width: 2
        color: 'grey'
        anchors.left: smallView.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 20
    }

    //=================================
    // Main view with large images
    //=================================

    ListView {
        id: mainView
        visible: parent.b_append_enabled
        model: imgUrlsModel
        clip: true
        anchors.left: v_line.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 20

        property bool visibleCutline: false

        ScrollBar.vertical: ScrollBar {
            anchors.top: mainView.top
            anchors.right: mainView.right
            anchors.bottom: mainView.bottom
            active: true
        }

        delegate: Image {
            width: mainView.width * 0.9
            source: url
            fillMode: Image.PreserveAspectFit
            mipmap: true
            cache: false

            Rectangle {
                id: cutline
                visible: mainView.visibleCutline && areaImg.containsMouse
                y: areaImg.mouseY
                height: 1
                width: mainView.width
            }

            MouseArea {
                id: areaImg
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                anchors.fill: parent
                hoverEnabled: true

                // Merge images while press and hold
                onPressAndHold: {
                    if (mainView.visibleCutline)
                    {
                        var images = [];
                        for (var i = 0; i <= index; i++) images.push(imgUrlsModel.get(i).url);
                        imgmerger.merge_images(String(images));
                        mainView.visibleCutline = false;
                        imgUrlsModel.clear();
                        root.b_append_enabled = false;
                    }
                }

                // If pressed Left Button and 'Cutline' is visible, images will be cropped
                onReleased: {
                    if (mouse.button == Qt.LeftButton && mainView.visibleCutline) merge(index, mouseY, parent.height);

                    // If pressed Right Button, 'Cutline' visibility will be reversed
                    else if (mouse.button == Qt.RightButton) mainView.visibleCutline = !mainView.visibleCutline;
                }
            }
        }
    }

    onChangeIndex: {
        imgUrlsModel.move(index_src, index_dest, 1);
    }

    onDropped: {
        mainView.visibleCutline = false;

        for (var i = 0;; i++)
        {
            var path = String(drop.urls[i]);
            var path_arr = path.split('/');
            var filename = String(path_arr[path_arr.length-1]);

            if (path === "undefined" || !(path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".jpeg"))) break;
            else imgUrlsModel.append({"name": filename, "url": drop.urls[i]});
        }
    }

    onDeleteImageFromModel: {
        mainView.visibleCutline = false;
        imgUrlsModel.remove(index);
    }

    function merge(index, mouseY, height)
    {
        var images = [];
        for (var i = 0; i <= index; i++) images.push(imgUrlsModel.get(i).url);

        for (var i = index; i >= 0; i--) root.deleteImageFromModel(i);

        imgUrlsModel.insert(0, {"name": "_temp.png",
                  "url": imgmerger.merge_images(String(images), mouseY, height)});
    }
}
