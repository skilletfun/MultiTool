import QtQuick 2.12
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2

//=====================================================================
// Base Drag and Drop module for using in other modules
//=====================================================================

Rectangle {
    id: root

    signal dropped(var drop)

    property string _text: "Drag & Drop here"
    property color _textColor: "#1f4752"
    property color _arrowColor: "#1f4752"
    property color _borderColor: "green"
    property int _borderWidth: 2
    property bool _enableBorder: true
    property int _yOfArrow: sh._Y + 50
    property int _textContentWidth: drdrtext.contentWidth
    property color _blurColor: "#00262f"
    property double _blurOpacity: 0.2
    property int _pixelSizeText: 30
    property int _offsetY: -_pixelSizeText

    Shape {
        id: shape
        visible: root._enableBorder
        anchors.fill: parent

        ShapePath {
            id: shapepath
            strokeWidth: root._borderWidth
            strokeColor: root._borderColor
            startX: 0
            startY: 0
            strokeStyle: ShapePath.DashLine
            dashPattern: [8, 8]

            PathLine { x: root.width; y: 0 }
            PathLine { x: root.width; y: root.height }
            PathLine { x: 0; y: root.height }
            PathLine { x: 0; y: 0 }
        }
    }

    Text {
        id: drdrtext
        text: root._text
        color: root._textColor
        font.pixelSize: 30
        anchors.centerIn: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root._offsetY
    }

    Shape {
        id: sh
        smooth: true

        property int _Y: drdrtext.y + drdrtext.height + 30
        property int _X: drdrtext.x + drdrtext.width/2

        ShapePath {
            fillColor: "transparent"
            strokeWidth: 3
            strokeColor: root._arrowColor
            capStyle: ShapePath.RoundCap

            startX: sh._X  - 10
            startY: sh._Y

            PathLine { x: sh._X + 10; y: sh._Y }
            PathLine { x: sh._X + 10; y: sh._Y + 30 }
            PathLine { x: sh._X + 20; y: sh._Y + 30 }
            PathLine { x: sh._X; y: sh._Y + 50 }
            PathLine { x: sh._X - 20; y: sh._Y + 30 }
            PathLine { x: sh._X - 10; y: sh._Y + 30 }
            PathLine { x: sh._X - 10; y: sh._Y }
        }
    }

    Rectangle {
        id: blur
        anchors.fill: parent
        color: root._blurColor
        opacity: root._blurOpacity
        visible: false
    }

    DropArea {
        id: dropp

        anchors.fill: parent

        onEntered: {
            blur.visible = true;
        }

        onExited: {
            blur.visible = false;
        }

        onDropped: {
            blur.visible = false;
            root.dropped(drop);
        }
    }
}