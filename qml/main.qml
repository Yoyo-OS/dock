/*
 * Copyright (C) 2021 YoyoOS Team.
 *
 * Author:     rekols <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import Yoyo.System 1.0 as System
import Yoyo.NetworkManagement 1.0 as NM
import Yoyo.Dock 1.0
import FishUI 1.0 as FishUI

Item {
    id: root
    visible: true
    property int iconSize: height /3

    property bool isHorizontal: Settings.direction === DockSettings.Bottom
    property bool darkMode: FishUI.Theme.darkMode
    property color textColor: FishUI.Theme.darkMode ? "#FFFFFF" : "#000000";
    property var fontSize: isHorizontal ? root.height / 5 : root.width / 5
    property var timeFormat: mainWindow.twentyFourTime ? "HH:mm" : "h:mm ap"
    property int rightWidth: 0
    property int rightHeight: 0
    property real windowRadius: isHorizontal ? root.height * 0.3 : root.width * 0.3
    property bool compositing: windowHelper.compositing

    onTimeFormatChanged: {
        timeTimer.restart()
    }

    onCompositingChanged: {
        mainWindow.updateSize()
    }

    DropArea {
        anchors.fill: parent
        enabled: true
    }

    // Background
    Rectangle {
        id: _background

        property var borderColor: root.compositing ? FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.3)
                                                                           : Qt.rgba(0, 0, 0, 0.2) : FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.15)
                                                                                                                           : Qt.rgba(0, 0, 0, 0.15)

        anchors.fill: parent
        radius: root.compositing && Settings.style === 0 ? windowRadius : 0
        color: FishUI.Theme.darkMode ? "#666666" : "#E6E6E6"
        opacity: root.compositing ? FishUI.Theme.darkMode ? 0.5 : 0.5 : 0.9
        border.width: 1 / FishUI.Units.devicePixelRatio
        border.pixelAligned: FishUI.Units.devicePixelRatio > 1 ? false : true
        border.color: borderColor

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    FishUI.WindowHelper {
        id: windowHelper
    }

    FishUI.WindowShadow {
        view: mainWindow
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        strength: 1
        radius: _background.radius
    }

    FishUI.WindowBlur {
        view: mainWindow
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: _background.radius
        enabled: true
    }

    FishUI.PopupTips {
        id: popupTips
        backgroundColor: _background.color
        blurEnabled: false
    }

    GridLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.topMargin: Settings.style === 1
                           && (Settings.direction === 0 || Settings.direction === 2)
                           ? 28 : 0
        flow: isHorizontal ? Grid.LeftToRight : Grid.TopToBottom
        columnSpacing: 0
        rowSpacing: 0
        ListView {
            id: appItemView
            orientation: isHorizontal ? Qt.Horizontal : Qt.Vertical
            snapMode: ListView.SnapToItem
            interactive: false
            model: appModel
            clip: true

            Layout.fillHeight: true
            Layout.fillWidth: true

            delegate: AppItem {
                id: appItemDelegate
                implicitWidth: isHorizontal ? appItemView.height : appItemView.width
                implicitHeight: isHorizontal ? appItemView.height : appItemView.width
            }

            moveDisplaced: Transition {
                NumberAnimation {
                    properties: "x, y"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

//        DockItem {
//            id: trashItem
//            implicitWidth: isHorizontal ? root.height : root.width
//            implicitHeight: isHorizontal ? root.height : root.width
//            popupText: qsTr("Trash")
//            enableActivateDot: false
//            iconName: trash.count === 0 ? "user-trash-empty" : "user-trash-full"
//            onClicked: trash.openTrash()
//            onRightClicked: trashMenu.popup()

//            dropArea.enabled: true

//            onDropped: {
//                if (drop.hasUrls) {
//                    trash.moveToTrash(drop.urls)
//                }
//            }

//            Rectangle {
//                anchors.fill: parent
//                anchors.margins: FishUI.Units.smallSpacing / 2
//                color: "transparent"
//                border.color: FishUI.Theme.textColor
//                radius: height * 0.3
//                border.width: 1 / FishUI.Units.devicePixelRatio
//                border.pixelAligned: FishUI.Units.devicePixelRatio > 1 ? false : true
//                opacity: trashItem.dropArea.containsDrag ? 0.5 : 0

//                Behavior on opacity {
//                    NumberAnimation {
//                        duration: 200
//                    }
//                }
//            }

//            FishUI.DesktopMenu {
//                id: trashMenu

//                MenuItem {
//                    text: qsTr("Open")
//                    onTriggered: trash.openTrash()
//                }

//                MenuItem {
//                    text: qsTr("Empty Trash")
//                    onTriggered: trash.emptyTrash()
//                    visible: trash.count !== 0
//                }
//            }
//        }

        // System tray(Right)

        GridLayout {
            id:rightLayout
            flow: isHorizontal ? Grid.LeftToRight : Grid.TopToBottom
            columnSpacing: 0
            rowSpacing: 0
            Layout.topMargin: 0
            Layout.bottomMargin: 0
            Layout.rightMargin: FishUI.Units.smallSpacing
            Layout.leftMargin: FishUI.Units.smallSpacing
            onWidthChanged: {
                rightWidth = rightLayout.width
                mainWindow.updateSize()
            }

        SystemTray {
        }

        StandardItem {
                    id: controler

                    checked: controlCenter.item.visible
                    animationEnabled: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: _controlerLayout.implicitWidth + FishUI.Units.largeSpacing

                    onClicked: {
                        toggleDialog()
                    }

                    function toggleDialog() {
                        if (controlCenter.item.visible)
                            controlCenter.item.close()
                        else {
                            // 先初始化，用户可能会通过Alt鼠标左键移动位置
                            controlCenter.item.position = Qt.point(0, 0)
                            controlCenter.item.position = mapToGlobal(0, 0)
                            controlCenter.item.open()
                        }
                    }

                    RowLayout {
                        id: _controlerLayout
                        anchors.fill: parent
                        anchors.leftMargin: FishUI.Units.smallSpacing
                        anchors.rightMargin: FishUI.Units.smallSpacing

                        spacing: FishUI.Units.largeSpacing

                        Label{
                            font.family: "FluentSystemIcons-Regular"
                            color: FishUI.Theme.textColor
                            font.pixelSize: root.iconSize
                            antialiasing: false
                            smooth: false
                            text: controlCenter.item.volumeIconName
                        }

                        Image {
                            id: wirelessIcon
                            width: root.iconSize
                            height: width
                            sourceSize: Qt.size(width, height)
                            source: activeConnection.wirelessIcon ? "qrc:/images/" + (root.darkMode ? "dark/" : "light/") + activeConnection.wirelessIcon + ".svg" : ""
                            asynchronous: true
                            Layout.alignment: Qt.AlignCenter
                            visible: enabledConnections.wirelessHwEnabled &&
                                     enabledConnections.wirelessEnabled &&
                                     activeConnection.wirelessName &&
                                     wirelessIcon.status === Image.Ready
                            antialiasing: true
                            smooth: false
                        }

                        // Battery Item
                        RowLayout {
                            visible: battery.available

                            Image {
                                id: batteryIcon
                                height: root.iconSize
                                width: height + 6
                                sourceSize: Qt.size(width, height)
                                source: "qrc:/images/" + (root.darkMode ? "dark/" : "light/") + battery.iconSource
                                Layout.alignment: Qt.AlignCenter
                                antialiasing: true
                                smooth: false
                            }

                            Label {
                                text: battery.chargePercent + "%"
                                font.pointSize: root.fontSize
                                color: root.textColor
                                visible: battery.showPercentage
                            }
                        }
                    }
                }

                StandardItem {
                    id: shutdownItem

                    animationEnabled: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: shutdownIcon.implicitWidth + FishUI.Units.smallSpacing
                    checked: shutdownDialog.item.visible

                    onClicked: {
                        shutdownDialog.item.position = Qt.point(0, 0)
                        shutdownDialog.item.position = mapToGlobal(0, 0)
                        shutdownDialog.item.open()
                    }

                    Label{
                        id: shutdownIcon
                        font.family: "FluentSystemIcons-Regular"
                        anchors.centerIn: parent
                        height: width
                        color: FishUI.Theme.textColor
                        font.pixelSize: root.iconSize
                        antialiasing: false
                        smooth: false
                        text: "\uf610"
                    }
                }

        // Pop-up notification center and calendar
        StandardItem {
            id: datetimeItem
            animationEnabled: true
            Layout.fillHeight: true
            Layout.rightMargin: FishUI.Units.smallSpacing
            Layout.preferredWidth: _dateTimeLayout.implicitWidth + FishUI.Units.smallSpacing

            onClicked: {
                process.startDetached("yoyo-notificationd", ["-s"])
            }

            RowLayout {
                id: _dateTimeLayout
                anchors.fill: parent

//                Image {
//                    width: root.iconSize
//                    height: width
//                    sourceSize: Qt.size(width, height)
//                    source: "qrc:/images/" + (root.darkMode ? "dark/" : "light/") + "notification-symbolic.svg"
//                    asynchronous: true
//                    Layout.alignment: Qt.AlignCenter
//                    antialiasing: true
//                    smooth: false
//                }

                Label {
                    id: timeLabel
                    Layout.alignment: Qt.AlignCenter
                    font.pointSize: root.fontSize
                    color: root.textColor

                    Timer {
                        id: timeTimer
                        interval: 1000
                        repeat: true
                        running: true
                        triggeredOnStart: true
                        onTriggered: {
                            timeLabel.text = new Date().toLocaleTimeString(Qt.locale(), mainWindow.twentyFourTime ? root.timeFormat
                                                                                                                 : Locale.ShortFormat)
                        }
                    }
                }
            }
        }
        }
    }

    Connections {
        target: Settings

        function onDirectionChanged() {
            popupTips.hide()
        }
    }

    Connections {
        target: mainWindow

        function onVisibleChanged() {
            popupTips.hide()
        }
    }

    MouseArea {
            id: _sliding
            anchors.fill: parent
            z: -1

            property int startY: -1
            property bool activated: false

            onPressed: {
                startY = mouse.y
            }

            onReleased: {
                startY = -1
            }
        }

        // Components
        Loader {
            id: controlCenter
            sourceComponent: ControlCenter {}
            asynchronous: true
        }

        Loader {
            id: shutdownDialog
            sourceComponent: ShutdownDialog {}
            asynchronous: true
        }

        NM.ActiveConnection {
            id: activeConnection
        }

        NM.EnabledConnections {
            id: enabledConnections
        }

        NM.Handler {
            id: nmHandler
        }
}
