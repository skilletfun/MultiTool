import QtQuick 2.12

//=====================================================================
// Rectange that can be Drag and Drop. Can be used without some settings
//=====================================================================

Rectangle {
    id: rect

    property int _index: index
    property int _spacing: 10

//=====================================================================
// Orientation of List where DroppableRect is used. By default: vertical
//=====================================================================

    property bool orientation: true

    readonly property bool horizontal: false
    readonly property bool vertical: true

    property color _hoverBorderColor: "#b8eef5"
    property int _hoverBorderWidth: 6

//=====================================================================

    property color _borderColor: "transparent"
    property int _borderWidth: 0

    property int oldX: -1

    signal doubleClicked(var index)
    signal released(var index)
    signal dropped(var srcIndex, var destIndex)
    signal pressAndHold(var index)

    border.color: _borderColor
    border.width: _borderWidth

    on_IndexChanged: {
        oldX = -1;
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true

        onDoubleClicked: {
            rect.doubleClicked(index);
        }

        onReleased: {
            rect.released(index);
        }

        onPressAndHold: {
            rect.pressAndHold(index);
        }

        drag.target: rect

        drag.onActiveChanged: {
            dropA.enabled = !dropA.enabled;
            rect.Drag.drop();

            // If you drop item
            if (dropA.enabled)
            {
                rect.z = 1;
                rect.width += 20;
                rect.height += 10

                // If orientation is vertical
                if (rect.orientation)
                {
                    rect.x = 0;
                    rect.y = index * (rect.height + rect._spacing);
                }
                else
                // If orientation is horizontal
                {
                    rect.y = 0;
                    if (rect.oldX >= 0) rect.x = rect.oldX;
                }
            }
            // If you drag item
            else
            {
                rect.z = 2;
                rect.oldX = rect.x;
                rect.width -= 20;
                rect.height -= 10
            }
        }
    }

    DropArea {
        id: dropA
        anchors.fill: parent

        onEntered: {
            rect.border.color = rect._hoverBorderColor;
            rect.border.width = rect._hoverBorderWidth;
        }

        onExited: {
            rect.border.color = rect._borderColor;
            rect.border.width = rect._borderWidth;
        }

        onDropped: {
            rect.border.color = rect._borderColor;
            rect.border.width = rect._borderWidth;
            rect.dropped(drop.source._index, index);
        }
    }

    Drag.active: area.drag.active
    Drag.hotSpot.x: rect.width / 2
    Drag.hotSpot.y: rect.height / 2
}
