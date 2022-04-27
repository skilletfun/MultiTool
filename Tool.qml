import QtQuick 2.12

Rectangle {
    id: root
    height: 80
    width: height
    border.width: 1
    radius: height/2

    color: current_color

    property bool active: false
    property color current_color: active ? 'white' : '#F6F6F6'

    property alias source: icon.source

    signal click()

    Rectangle {
        height: parent.height
        width: height/2
        anchors.right: parent.right
        anchors.top: parent.top
        border.width: 1
        color: root.current_color
    }

    Rectangle {
        height: parent.height-2
        width: 1
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.left: parent.horizontalCenter
        color: root.current_color
    }

    Rectangle {
        id: right_vline
        visible: root.active
        height: parent.height-2
        width: 1
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.right: parent.right
        color: root.current_color
    }

    Image {
        id: icon

        anchors.centerIn: parent
        mipmap: true

        width: parent.width * 0.5
        height: parent.height * 0.5
    }

    MouseArea {
        id: area
        anchors.fill: parent
        onReleased: { root.click(); }
    }
}
