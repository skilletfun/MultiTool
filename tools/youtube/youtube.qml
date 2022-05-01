import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.platform 1.0

Rectangle {
    id: root

    property bool b_choose_folder: false
    property bool b_loading: false
    property bool b_loading_finished: false

    TextField {
        id: url_field

        visible: !b_loading && !b_loading_finished

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -50
        anchors.margins: 50
        height: 80

        horizontalAlignment: Text.AlignHCenter

        background: Rectangle { border.width: 2; radius: 5; }

        placeholderText: "Paste 'Video URL' or 'Playlist URL' here"
        font.pixelSize: 20
        selectionColor: "#00de4b"

        onAccepted: {
            focus = false;
            if (url_field.text != '' && root.b_choose_folder) root.b_loading = true;
        }
    }

    ListModel {
        id: videomodel

        onCountChanged: {
            if (count === 0)
            {
                root.b_loading = false;
                root.b_loading_finished = false;
                url_field.text = "";
            }
        }
    }

    Button {
        id: chooseSaveFolder
        visible: !b_loading && !b_loading_finished
        width: 200
        height: 50
        text: "Choose save folder"
        font.pixelSize: 16
        anchors.horizontalCenter: url_field.horizontalCenter
        anchors.top: url_field.bottom
        anchors.topMargin: 50
        background: Rectangle { border.width: 2; radius: 5;
            color: chooseSaveFolder.down ? '#f3f3f3' : 'white'
        }

        onReleased: {
            chooseSaveFolderDialog.open();
        }
    }

    FolderDialog {
        id: chooseSaveFolderDialog
        title: "Choose save folder"

        onAccepted: {
            youtube.set_save_folder(folder);
            root.b_choose_folder = true;
            if (url_field.text != "" && root.b_choose_folder) root.b_loading = true;
        }
    }

    Rectangle {
        visible: !root.b_loading && b_loading_finished
        anchors.fill: parent
        anchors.margins: 10

        Rectangle {
            id: rectt
            height: 60
            width: view_videos.width

            Button {
                id: videoDownloadAllBtn

                property bool b_download_video: false

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: 170
                anchors.leftMargin: 20
                anchors.margins: 10
                text: "Download all videos: " + (b_download_video ? "yes" : "no")
                font.pixelSize: 12

                background: Rectangle { radius: height/4; border.color: "#1700ff";
                    color: videoDownloadAllBtn.pressed ? "#6556ff" :
                    videoDownloadAllBtn.hovered ? "#9287ff" : "#ada5ff";}

                onReleased: {
                    b_download_video = !b_download_video;
                }

            }

            Button {
                id: audioDownloadAllBtn

                property bool b_download_audio: false

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 170
                anchors.left: videoDownloadAllBtn.right
                anchors.leftMargin: 20
                anchors.margins: 10
                text: "Download all audios: " + (b_download_audio ? "yes" : "no")
                font.pixelSize: 12

                background: Rectangle { radius: height/4; border.color: "#ff1400";
                    color: audioDownloadAllBtn.pressed ? "#ff5e50" :
                    audioDownloadAllBtn.hovered ? "#ff8e84" : "#ffb6b0";}

                onReleased: {
                    b_download_audio = !b_download_audio;
                }
            }

            Button {
                id: startDownload
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 100
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.margins: 10
                text: "START"
                font.pixelSize: 14
                background: Rectangle { border.width: 2; radius: 5;
                    color: startDownload.down ? '#f3f3f3' : 'white'
                }

                onReleased: {
                    youtube.download();
                    stats.visible = true;
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: 'black'
            }
        }

        ListView {
            id: view_videos
            clip: true
            anchors.top: rectt.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 5
            model: videomodel

            removeDisplaced: Transition {
                NumberAnimation { properties: "y"; duration: 300 }
            }

            delegate: Rectangle {
                id: rect
                clip: true
                height: 80
                width: view_videos.width
                border.color: 'grey'
                radius: 10

                Image {
                    id: _icon
                    height: parent.height * 0.8
                    anchors.left: parent.left
                    anchors.leftMargin: 25
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: image_url
                }

                Text {
                    id: _title
                    text: title
                    anchors.left: _icon.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                }

                MouseArea {
                    id: area
                    hoverEnabled: true
                    anchors.fill: parent

                    onDoubleClicked: {
                        root.removeIndex(index);
                    }
                }

                Rectangle {
                    id: downloadrect
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.left: parent.horizontalCenter
                    anchors.leftMargin: parent.width/4
                    color: 'white'
                    anchors.margins: 1
                    radius: 10

                    Button {
                        id: videoDownloadBtn
                        anchors.top: parent.top
                        anchors.bottom: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.leftMargin: 15
                        anchors.margins: 5
                        text: "Video: " + video_state
                        font.pixelSize: 12

                        background: Rectangle { radius: 5; border.color: "#1700ff";
                            color: videoDownloadBtn.pressed ? "#6556ff" :
                            videoDownloadBtn.hovered ? "#9287ff" : "#ada5ff";}

                        onReleased: {
                            root.setDownloadVideoYesNo(index, video_state === "no" ? "yes" : "no");
                        }
                        Connections {
                            target: videoDownloadAllBtn
                            function onReleased()
                            {
                                root.setDownloadVideoYesNo(index, videoDownloadAllBtn.b_download_video ? "yes" : "no");
                            }
                        }
                    }

                    Button {
                        id: audioDownloadBtn
                        anchors.top: parent.verticalCenter
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.leftMargin: 15
                        anchors.margins: 5
                        text: "Audio: " + audio_state
                        font.pixelSize: 12

                        background: Rectangle { radius: 5; border.color: "#ff1400";
                            color: audioDownloadBtn.pressed ? "#ff5e50" :
                            audioDownloadBtn.hovered ? "#ff8e84" : "#ffb6b0";}

                        onReleased: {
                            root.setDownloadAudioYesNo(index, audio_state === "no" ? "yes" : "no");
                        }

                        Connections {
                            target: audioDownloadAllBtn

                            function onReleased()
                            {
                                root.setDownloadAudioYesNo(index, audioDownloadAllBtn.b_download_audio ? "yes" : "no");
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: stats
        visible: false
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        border.width: 2
        border.color: 'blue'
        height: 50
        width: 250

        property int total: 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
            text: 'Total: ' + String(parent.total) + ' / ' + String(videomodel.count)
            font.pointSize: 12
        }

        BusyIndicator {
            visible: parent.total != videomodel.count
            anchors.right: parent.right
            anchors.rightMargin: 5
            height: parent.height * 0.9
            anchors.verticalCenter: parent.verticalCenter
        }

        Timer {
            id: tmr_stats
            interval: 1000
            repeat: true
            triggeredOnStart: false
            onTriggered: {
                parent.total = youtube.get_stats();
                if (parent.total === videomodel.count) stop();
            }
        }

        onVisibleChanged: {
            if (visible)
            {
                tmr_stats.start();
            }
        }
    }

    Text {
        visible: root.b_loading && !b_loading_finished
        text: "Loading..."
        font.family: "Lato"
        font.pixelSize: 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -50

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 20
            running: true
        }

        Timer {
            id: tmr
            interval: 100
            repeat: true
            triggeredOnStart: false
            onTriggered: {
                root.get_response();
            }
        }

        onVisibleChanged: {
            if (visible === true)
            {
                youtube.load(url_field.text);
                tmr.start();
            }
        }
    }

    function get_response()
    {
        var response = youtube.check_response();
        if (response !== '')
        {
            var js_arr = JSON.parse(response);
            for (var i = 0; i < js_arr.length; i++)
            {
                videomodel.append({"title": js_arr[i].title, "image_url": js_arr[i].image_url,
                                      "audio_state": js_arr[i].audio_state, "video_state": js_arr[i].video_state});
            }
            root.b_loading = false;
            root.b_loading_finished = true;
            tmr.stop();
        }
    }

    function removeIndex(index)
    {
        videomodel.remove(index);
        youtube.remove_by_index(index);
    }

    function setDownloadAudioYesNo(index, state)
    {
        videomodel.setProperty(index, "audio_state", state);
        youtube.set_audio_state(index, state);
    }

    function setDownloadVideoYesNo(index, state)
    {
        videomodel.setProperty(index, "video_state", state);
        youtube.set_video_state(index, state);
    }
}
