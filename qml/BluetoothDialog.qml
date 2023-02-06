import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import Yoyo.Accounts 1.0 as Accounts
import Yoyo.Bluez 1.0 as Bluez
import Yoyo.Dock 1.0
import FishUI 1.0 as FishUI

ControlCenterDialog {
    id: control

    width: _mainLayout.implicitWidth + FishUI.Units.largeSpacing * 3
    height: _mainLayout.implicitHeight + FishUI.Units.largeSpacing * 3

    onWidthChanged: adjustCorrectLocation()
    onHeightChanged: adjustCorrectLocation()
    onPositionChanged: adjustCorrectLocation()

    property point position: Qt.point(0, 0)
    property var margin: 4 * Screen.devicePixelRatio
    property var borderColor: windowHelper.compositing ? FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.3)
                                                                  : Qt.rgba(0, 0, 0, 0.2) : FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.15)
                                                                                                                  : Qt.rgba(0, 0, 0, 0.15)
    function setBluetoothEnabled(enabled) {
        Bluez.Manager.bluetoothBlocked = !enabled

        for (var i = 0; i < Bluez.Manager.adapters.length; ++i) {
            var adapter = Bluez.Manager.adapters[i]
            adapter.powered = enabled
        }
    }
    Bluez.DevicesProxyModel {
        id: devicesProxyModel
        sourceModel: devicesModel
    }

    Bluez.DevicesModel {
        id: devicesModel
    }

    Bluez.BluetoothManager {
        id: bluetoothMgr

        onShowPairDialog: {
            _pairDialog.title = name
            _pairDialog.pin = pin
            _pairDialog.visible = true
        }

        onPairFailed: {
            rootWindow.showPassiveNotification(qsTr("Pairing unsuccessful"), 3000)
        }

        onConnectFailed: {
            rootWindow.showPassiveNotification(qsTr("Connecting Unsuccessful"), 3000)
        }
    }
    FishUI.WindowBlur {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        windowRadius: _background.radius
        enabled: true
    }

    FishUI.WindowShadow {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        radius: _background.radius
    }

    Rectangle {
        id: _background
        anchors.fill: parent
        radius: windowHelper.compositing ? FishUI.Theme.bigRadius * 1.5 : 0
        color: FishUI.Theme.darkMode ? "#4D4D4D" : "#FFFFFF"
        opacity: windowHelper.compositing ? FishUI.Theme.darkMode ? 0.5 : 0.7 : 1.0
        antialiasing: true
        border.width: 1 / Screen.devicePixelRatio
        border.pixelAligned: Screen.devicePixelRatio > 1 ? false : true
        border.color: control.borderColor

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.margins: FishUI.Units.largeSpacing
        spacing: FishUI.Units.largeSpacing
        Item {
            id: topItem
            Layout.fillWidth: true
            width: 300
            height: 32

            RowLayout {
                id: topItemLayout
                anchors.fill: parent
                anchors.rightMargin: FishUI.Units.largeSpacing
                spacing: FishUI.Units.largeSpacing

                Label {
                    leftPadding: FishUI.Units.largeSpacing
                    text: qsTr("Bluetooth")
                    font.bold: true
                    font.pointSize: 14
                    Layout.fillWidth: true
                }

                Switch {
                    id: bluetoothSwitch
                    Layout.fillHeight: true
                    rightPadding: 0
                    checked: !Bluez.Manager.bluetoothBlocked
                    onCheckedChanged: setBluetoothEnabled(checked)
                }
            }
        }
        Item {
            id: cardItems
            Layout.fillWidth: true
            Layout.preferredHeight: _listView.Layout.preferredHeight
//            property var cellWidth: _listView.width / 4

            Rectangle {
                anchors.fill: parent
                color: "white"
                radius: FishUI.Theme.bigRadius
                opacity: FishUI.Theme.darkMode ? 0.2 : 0.7
            }
            ListView {
                id: _listView
                visible: count > 0
                interactive: false
                spacing: 0

                Layout.fillWidth: true

                Layout.preferredHeight: {
                    var totalHeight = 0
                    for (var i = 0; i < _listView.visibleChildren.length; ++i) {
                        totalHeight += _listView.visibleChildren[i].height
                    }
                    return totalHeight
                }

                model: Bluez.Manager.bluetoothOperational ? devicesProxyModel : []

                section.property: "Section"
                section.criteria: ViewSection.FullString
                section.delegate: Label {
                    color: FishUI.Theme.disabledTextColor
                    topPadding: FishUI.Units.largeSpacing
                    bottomPadding: FishUI.Units.smallSpacing
                    leftPadding: FishUI.Units.largeSpacing
                    text: section == "My devices" ? qsTr("My devices")
                                                 : qsTr("Other devices")
                }

                delegate: Item {
                    width: _listView.width
                    height: _itemLayout.implicitHeight + FishUI.Units.largeSpacing

                    property bool paired: model.Connected && model.Paired

                    ColumnLayout {
                        id: _itemLayout
                        anchors.fill: parent
                        anchors.leftMargin: FishUI.Units.smallSpacing
                        anchors.rightMargin: FishUI.Units.smallSpacing
                        anchors.topMargin: FishUI.Units.smallSpacing
                        anchors.bottomMargin: FishUI.Units.smallSpacing
                        spacing: 0

                        Item {
                            Layout.fillWidth: true
                            height: _contentLayout.implicitHeight + FishUI.Units.largeSpacing

                            Rectangle {
                                anchors.fill: parent
                                radius: FishUI.Theme.smallRadius
                                color: FishUI.Theme.textColor
                                opacity: mouseArea.pressed ? 0.15 :  mouseArea.containsMouse ? 0.1 : 0.0
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton

                                onClicked: {
                                    if (model.Connected || model.Paired){
                                        additionalSettings.toggle()
                                        return
                                    }

                                    if (model.Paired) {
                                        bluetoothMgr.connectToDevice(model.Address)
                                    } else {
                                        bluetoothMgr.requestParingConnection(model.Address)
                                    }
                                }
                            }

                            RowLayout {
                                id: _contentLayout
                                Layout.fillWidth: true

                                Label{
                                    font.family: "FluentSystemIcons-Regular"
                                    color: FishUI.Theme.textColor
                                    font.pixelSize: 20
                                    antialiasing: false
                                    smooth: false
                                    text: "\uf1df"
                                }

                                Label {
                                    text: model.DeviceFullName
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Label {
                                    visible: model.Paired
                                    text: model.Connected ? qsTr("Connected") : qsTr("Not Connected")
                                }
                            }
                        }

                        Hideable {
                            id: additionalSettings
                            spacing: 0

                            ColumnLayout {
                                Item {
                                    height: FishUI.Units.largeSpacing
                                }

                                RowLayout {
                                    spacing: FishUI.Units.largeSpacing
                                    Layout.leftMargin: FishUI.Units.smallSpacing

                                    Button {
                                        text: qsTr("Connect")
                                        visible: !model.Connected
                                        onClicked: {
                                            if (model.Paired) {
                                                bluetoothMgr.connectToDevice(model.Address)
                                            } else {
                                                bluetoothMgr.requestParingConnection(model.Address)
                                            }
                                        }
                                    }

                                    Button {
                                        text: qsTr("Disconnect")
                                        visible: model.Connected
                                        onClicked: {
                                            bluetoothMgr.deviceDisconnect(model.Address)
                                            additionalSettings.hide()
                                        }
                                    }

                                    Button {
                                        text: qsTr("Forget This Device")
                                        flat: true
                                        onClicked: {
                                            bluetoothMgr.deviceRemoved(model.Address)
                                            additionalSettings.hide()
                                        }
                                    }
                                }
                            }

                            HorizontalDivider {}
                        }
                    }
                }
            }
        }
    }

    PowerActions {
        id: actions
    }

    function adjustCorrectLocation() {
        mainWindow.updateScreenRect()
        var posX = control.position.x
        var posY = control.position.y

        if (posX + control.width >= mainWindow.screenRect.x + mainWindow.screenRect.width)
            posX = mainWindow.screenRect.x + mainWindow.screenRect.width - control.width - control.margin

        posY = mainWindow.screenRect.height - root.height - control.margin - control.height

        if(Settings.style === 0)
        {
            posX = control.position.x - control.width / 2
            posY = mainWindow.screenRect.height - root.height - (control.margin * 2) - control.height
        }

        control.x = posX
        control.y = posY
    }
}
