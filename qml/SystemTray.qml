import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import Yoyo.Dock 1.0
import FishUI 1.0 as FishUI

RowLayout {
    id:trayBar
    clip: true
    //layoutDirection: Qt.RightToLeft
    property real itemWidth: root.iconSize + FishUI.Units.largeSpacing
    property bool ishide: false
    property real trayViewWidth: (trayBar.itemWidth+FishUI.Units.smallSpacing / 2) * trayView.count

    Layout.topMargin: 0
    Layout.bottomMargin: 0
    Layout.fillHeight: true
    Layout.preferredWidth: trayView.Layout.preferredWidth + (itemWidth+FishUI.Units.smallSpacing / 2)

    NumberAnimation {
        id: hideAnimation;
        target: trayView;
        property: "Layout.preferredWidth";
        to: 0;
        duration: 200;
    }

    NumberAnimation {
        id: showAnimation;
        target: trayView;
        property: "Layout.preferredWidth";
        to: trayViewWidth;
        duration: 200;
    }

    StandardItem {
        id: hideItem

        animationEnabled: true
        Layout.fillHeight: true
        Layout.preferredWidth: hideIcon.implicitWidth + FishUI.Units.smallSpacing
        onClicked: {
            if(ishide)
            {
                showAnimation.running = true;
            }else{
                hideAnimation.running = true;
            }
            ishide = !ishide
        }

        Label{
            id: hideIcon
            font.family: "FluentSystemIcons-Regular"
            anchors.centerIn: parent
            height: width

            color: FishUI.Theme.textColor
            font.pixelSize: root.iconSize
            antialiasing: false
            smooth: false
            text: ishide ? "\uf266" : "\uf26a"
        }
    }

    ListView {
    id: trayView

    orientation: Qt.Horizontal
    layoutDirection: Qt.RightToLeft
    interactive: false
    clip: true
    spacing: FishUI.Units.smallSpacing / 2

    Layout.fillHeight: true

    Layout.preferredWidth: trayViewWidth

    model: SystemTrayModel {
        id: trayModel
    }

    moveDisplaced: Transition {
        NumberAnimation {
            properties: "x, y"
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    delegate: StandardItem {
        id: _trayItem

        property bool darkMode: root.darkMode
        property int dragItemIndex: index
        property bool dragStarted: false

        width: trayBar.itemWidth
        height: ListView.view.height
        animationEnabled: true

        onDarkModeChanged: updateTimer.restart()

        Drag.active: _trayItem.mouseArea.drag.active
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.MoveAction
        Drag.hotSpot.x: iconItem.width / 2
        Drag.hotSpot.y: iconItem.height / 2

        Drag.onDragStarted:  {
            dragStarted = true
        }

        Drag.onDragFinished: {
            dragStarted = false
        }

        onPositionChanged: {
            if (_trayItem.mouseArea.pressed) {
                _trayItem.mouseArea.drag.target = iconItem
                iconItem.grabToImage(function(result) {
                    _trayItem.Drag.imageSource = result.url
                })
            } else {
                _trayItem.mouseArea.drag.target = null
            }
        }

        onReleased: {
            _trayItem.mouseArea.drag.target = null
        }

        DropArea {
            anchors.fill: parent
            enabled: true

            onEntered: {
                if (drag.source)
                    trayModel.move(drag.source.dragItemIndex,
                                   _trayItem.dragItemIndex)
            }
        }

        Timer {
            id: updateTimer
            interval: 10
            onTriggered: iconItem.updateIcon()
        }

//        ColorOverlay {
//            id: iconOverlay
//            anchors.centerIn: parent
//            width: root.iconSize
//            height: width
//            source: iconItem
//            color: root.textColor
//            opacity: root.darkMode ? 1 : 0.7
//            visible: false
//        }

        FishUI.IconItem {
            id: iconItem
            anchors.centerIn: parent
            width: root.iconSize
            height: width
            source: model.iconName ? model.iconName : model.icon
            antialiasing: true
            smooth: true
            //visible: !dragStarted && !iconOverlay.visible
        }

        onClicked: {
            var pos = trayModel.popupPosition(_trayItem, mouse.x, mouse.y)

            if (mouse.button === Qt.LeftButton) {
                trayModel.leftButtonClick(model.id, pos.x, pos.y)
            } else if (mouse.button === Qt.RightButton) {
                trayModel.rightButtonClick(model.id, _trayItem, pos.x, pos.y)
            } else if (mouse.button === Qt.MiddleButton) {
                trayModel.middleButtonClick(model.id, pos.x, pos.y)
            }
        }

        popupText: model.toolTip ? model.toolTip : model.title
    }
}
}
