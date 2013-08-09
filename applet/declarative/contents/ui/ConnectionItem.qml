/*
    Copyright 2013 Jan Grulich <jgrulich@redhat.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.1
import org.kde.qtextracomponents 0.1
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasmanm 0.1 as PlasmaNM

PlasmaComponents.ListItem {
    id: connectionItem;

    property bool isWireless: (itemType == 14) ? true : false;
    property bool expanded: false;
    property bool detailsView: false;

    signal itemExpanded(string connectionPath, bool itemExpanded);

    enabled: true
    height: theme.defaultFont.mSize.height * 2.8 + ((!connectionItemSettings.connectionSettings || !expanded) ? 0 : connectionItemSettings.connectionSettings.childrenRect.height + padding.margins.top);

    onClicked: {
        if (itemUuid) {
            itemExpanded(itemConnectionPath, !expanded);
        } else {
            itemExpanded(itemName, !expanded);
        }
    }

    Item {
        id: connectionItemBasic;

        height: theme.defaultFont.mSize.height * 1.8;
        anchors { left: parent.left; right: parent.right; top: parent.top }

        QIconItem {
            id: connectionTypeIcon;

            height: connectionItemBasic.height; width: height;
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: padding.margins.left }
            icon: QIcon(itemConnectionIcon);

            QIconItem {
                id: connectionSecurityIcon;
                width: connectionTypeIcon.width/2; height: width;
                anchors { bottom: parent.bottom; right: parent.right }
                icon: QIcon("object-locked");
                visible: itemSecure;
            }
        }

        PlasmaComponents.Label {
            id: connectionNameLabel;

            anchors {
                left: connectionTypeIcon.right;
                right: parent.right;
                verticalCenter: parent.verticalCenter;
                leftMargin: padding.margins.left;
                rightMargin: padding.margins.right;
            }
            text: itemName;
            elide: Text.ElideRight;
            font.weight: itemConnected ? Font.DemiBold : Font.Normal;
            font.italic: itemConnecting ? true : false;
        }

        MouseEventListener {
            id: leftActionArea;

            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            width: theme.smallMediumIconSize * 2;
            hoverEnabled: expanded;

            onClicked: {
                if (!expanded) {
                    if (itemUuid) {
                        itemExpanded(itemConnectionPath, !expanded);
                    } else {
                        itemExpanded(itemName, !expanded);
                    }
                } else {
                    if (configureButton.active) {
                        detailsView = !detailsView
                    }
                }
            }

            PlasmaComponents.BusyIndicator {
                id: connectingIndicator;

                width: theme.smallMediumIconSize; height: width;
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: padding.margins.right }
                running: itemConnecting;
                visible: running;
            }

            PlasmaCore.IconItem {
                id: configureButton;

                width: theme.smallMediumIconSize; height: width;
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: padding.margins.right }
                source: "configure";
                visible: expanded && !connectingIndicator.running;
                active: leftActionArea.containsMouse;
            }
        }
    }

    Item {
        id: connectionItemSettings;
        property Item connectionSettings;
    }

    Component {
        id: connectionComponent;

        Item {
            height: childrenRect.height;
            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: theme.defaultFont.mSize.height * 3 }

            Item {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                visible: !detailsView;
                height: childrenRect.height;

                // I had to move PlasmaNM.TrafficMonitor into a separated item, because it's not possible to adjust the height to 0 and the traffic monitor
                // still occupied the space.
                Item {
                    id: trafficMonitor;

                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    visible: (itemDevicePath && itemConnected && itemType != 11)
                    height: visible ? 150 : 0;

                    PlasmaNM.TrafficMonitor {
                        anchors.fill: parent;
                        device: itemDevicePath;
                    }
                }

                PlasmaComponents.TextField {
                    id: passwordInput;

                    anchors { horizontalCenter: parent.horizontalCenter; top: trafficMonitor.bottom }
                    width: 200;
                    echoMode: showPasswordCheckbox.checked ? TextInput.Normal : TextInput.Password
                    visible: predictableWirelessPassword();
                    height: visible ? implicitHeight : 0;
                    placeholderText: i18n("Password...");
                }

                PlasmaComponents.CheckBox {
                    id: showPasswordCheckbox;

                    anchors { left: passwordInput.left; right: parent.right; top: passwordInput.bottom }
                    visible: predictableWirelessPassword();
                    height: visible ? defaultCheckboxHeight() : 0;
                    checked: false;
                    text: i18n("Show password");
                }

                PlasmaComponents.CheckBox {
                    id: automaticallyConnectCheckbox;

                    anchors { left: passwordInput.left; right: parent.right; top: showPasswordCheckbox.bottom }
                    visible: predictableWirelessPassword();
                    height: visible ? defaultCheckboxHeight() : 0;
                    checked: true;
                    text: i18n("Automatically connect");
                }

                PlasmaComponents.Button {
                    id: connectDisconnectButton;

                    anchors { horizontalCenter: parent.horizontalCenter; top: automaticallyConnectCheckbox.bottom }
                    text: (itemConnected || itemConnecting)? i18n("Disconnect") : i18n("Connect");

                    onClicked: {
                        if (itemUuid) {
                            itemExpanded(itemConnectionPath, false);
                        } else {
                            itemExpanded(itemName, false);
                        }

                        if (!itemConnected && !itemConnecting) {
                            if (itemUuid) {
                                handler.activateConnection(itemConnectionPath, itemDevicePath, itemSpecificPath);
                            } else {
                                handler.addAndActivateConnection(itemDevicePath, itemSpecificPath, passwordInput.text, automaticallyConnectCheckbox.checked);
                            }
                        } else {
                            handler.deactivateConnection(itemConnectionPath);
                        }
                    }
                }
            }

            Item {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                visible: detailsView;
                height: visible ? childrenRect.height : 0;

                TextEdit {
                    id: detailsText;

                    width: detailsView.width;
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    color: theme.textColor;
                    readOnly: true;
                    selectByMouse: true;
                    wrapMode: TextEdit.WordWrap;
                    textFormat: Text.RichText;
                    text: itemDetails;
                }

                PlasmaComponents.Button {
                    id: editButton;

                    anchors { horizontalCenter: parent.horizontalCenter; top: detailsText.bottom; topMargin: padding.margins.top }
                    text: i18n("Edit connection");

                    onClicked: {
                        itemExpanded(itemConnectionPath, false);
                        handler.editConnection(itemUuid);
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "Collapsed";
            when: !expanded && !sectionHidden();
                StateChangeScript { script: if (connectionItemSettings.connectionSettings) {connectionItemSettings.connectionSettings.destroy()} }
        },

        State {
            name: "CollapsedHidden";
            when: sectionHidden();
            StateChangeScript { script: if (connectionItemSettings.connectionSettings) {connectionItemSettings.connectionSettings.destroy()} }
            PropertyChanges { target: connectionItem; height: 0; }
            PropertyChanges { target: connectionItem; visible: false; }
        },

        State {
            name: "ConnectionExpanded";
            when: expanded && !sectionHidden();
            StateChangeScript { script: connectionItemSettings.connectionSettings = connectionComponent.createObject(connectionItem); }
        }
    ]

    transitions: Transition {
        NumberAnimation { duration: 300; properties: "height" }
    }

    Behavior on height {
        NumberAnimation { duration: 300 }
    }

    function sectionHidden() {
        return ((!connectionView.activeExpanded && itemSection == i18n("Active connections")) ||
                (!connectionView.previousExpanded && itemSection == i18n("Previous connections")) ||
                (!connectionView.unknownExpanded && itemSection == i18n("Unknown connections")))
    }

    function predictableWirelessPassword() {
        // Item is unknown && itemType == Wireless && itemSecurityType != DynamicWep && itemSecurityType != LEAP && itemSecurityType != WpaEap && itemSecurityType != Wpa2Eap
        return !itemUuid && itemType == 14 && itemSecure && itemSecurityType != 2 && itemSecurityType != 3 && itemSecurityType != 5 && itemSecurityType != 7;
    }

    function defaultCheckboxHeight() {
        return theme.defaultFont.mSize.height * 1.6 + buttonPadding.margins.top;
    }

    PlasmaCore.FrameSvgItem {
        id: buttonPadding;

        anchors.fill: parent;
        imagePath: "widgets/button";
        prefix: "normal";
        opacity: 0;
    }

    onExpandedChanged: {
        if (!expanded) {
            detailsView = false;
        }
    }
}
