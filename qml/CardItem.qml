import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import FishUI 1.0 as FishUI

Item {
    id: control

    property bool checked: false
    property alias icon: _image.source
    property alias label: _titleLabel.text

    signal clicked
    signal pressAndHold

    property var backgroundColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1)
                                                        : Qt.rgba(0, 0, 0, 0.05)
    property var hoverColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.15)
                                                   : Qt.rgba(0, 0, 0, 0.1)
    property var pressedColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.2)
                                                     : Qt.rgba(0, 0, 0, 0.15)

    property var highlightHoverColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.highlightColor, 1.1)
                                                            : Qt.darker(FishUI.Theme.highlightColor, 1.1)
    property var highlightPressedColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.highlightColor, 1.1)
                                                              : Qt.darker(FishUI.Theme.highlightColor, 1.2)

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: control.clicked()

        onPressedChanged: {
            imageItem.scale = pressed ? 0.95 : 1.0
        }

        onPressAndHold: {
            control.pressAndHold()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: FishUI.Theme.smallRadius
        anchors.rightMargin: FishUI.Theme.smallRadius
        spacing: FishUI.Units.largeSpacing

        Item {
            Layout.fillHeight: true
        }

        Item {
            id: imageItem
            Layout.preferredWidth: 28 + FishUI.Units.largeSpacing * 2
            Layout.preferredHeight: 28 + FishUI.Units.largeSpacing * 2

            Layout.alignment: Qt.AlignHCenter

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutSine
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: height / 2
//                color: "#E5E5E5"

                color: {
                    if (control.checked) {
                        if (_mouseArea.pressed)
                            return highlightPressedColor
                        else if (_mouseArea.containsMouse)
                            return highlightHoverColor
                        else
                            return FishUI.Theme.highlightColor
                    } else {
                        if (_mouseArea.pressed)
                            return pressedColor
                        else if (_mouseArea.containsMouse)
                            return hoverColor
                        else
                            return backgroundColor
                    }
                }
            }

            Image {
                id: _image
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                anchors.centerIn: parent
                sourceSize: Qt.size(28, 28)
                asynchronous: true
                antialiasing: true
                smooth: true
            }
        }

        Label {
            id: _titleLabel
//            color: control.checked ? FishUI.Theme.highlightedTextColor : FishUI.Theme.textColor
            Layout.preferredHeight: control.height * 0.15
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Qt.AlignHCenter
            Layout.fillWidth: true
            elide: Text.ElideMiddle
            visible: text
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
