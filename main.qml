import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

Window {
    width: 900
    height: 600
    visible: true
    title: qsTr("MultiTool")
    color: '#F6D3B2'

    Rectangle {
        id: loader_rect
        anchors.right: parent.right
        anchors.left: tools_view.right
        anchors.leftMargin: -1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 30
        border.width: 1

        Loader {
            id: loader
            source: tools_view.qml
            anchors.fill: parent
            anchors.margins: 1
        }
    }

    ListView {
        id: tools_view
        anchors.left: parent.left
        width: 80
        anchors.top: loader_rect.top
        anchors.topMargin: 15
        anchors.bottom: parent.bottom
        anchors.leftMargin: 25
        model: initer.get_model()
        spacing: 10

        property int current_index: -1
        property string qml: ''

        delegate: Tool {

            active: index == tools_view.current_index
            source: modelData[0]
            onClick: { tools_view.current_index = index; tools_view.qml = modelData[1]; }
        }
    }
}
