// Copyright (c) 2014-2018, The Scala Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import FontAwesome 1.0

import "../components" as ScalaComponents
import "../components/effects/" as ScalaEffects

import scalaComponents.Clipboard 1.0
import scalaComponents.Wallet 1.0
import scalaComponents.WalletManager 1.0
import scalaComponents.TransactionHistory 1.0
import scalaComponents.TransactionHistoryModel 1.0
import scalaComponents.Subaddress 1.0
import scalaComponents.SubaddressModel 1.0
import "../js/TxUtils.js" as TxUtils

Rectangle {
    id: pageReceive
    color: "transparent"
    property var model
    property alias receiveHeight: mainLayout.height
    property var state: "Address"

    function renameSubaddressLabel(_index){
        inputDialog.labelText = qsTr("Set the label of the selected address:") + translationManager.emptyString;
        inputDialog.onAcceptedCallback = function() {
            appWindow.currentWallet.subaddress.setLabel(appWindow.currentWallet.currentSubaddressAccount, _index, inputDialog.inputText);
        }
        inputDialog.onRejectedCallback = null;
        inputDialog.open(appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, _index))
    }

    function generateQRCodeString() {
        if (pageReceive.state == "PaymentRequest") {
            return walletManager.make_uri(appWindow.current_address,
                walletManager.amountFromString(amountToReceiveXLA.text),
                txDescriptionInput.text, receiverNameInput.text);
        } else {
            return walletManager.make_uri(appWindow.current_address);
        }
    }

    Clipboard { id: clipboard }

    /* main layout */
    ColumnLayout {
        id: mainLayout
        anchors.margins: 20
        anchors.topMargin: 40

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 15

        ColumnLayout {
            id: selectedAddressDetailsColumn
            Layout.alignment: Qt.AlignHCenter
            spacing: 0
            property int qrSize: 220

            ScalaComponents.Navbar {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10

                ScalaComponents.NavbarItem {
                    active: state == "Address"
                    text: qsTr("Address") + translationManager.emptyString
                    onSelected: state = "Address"
                }

                ScalaComponents.NavbarItem {
                    active: state == "PaymentRequest"
                    text: qsTr("Payment request") + translationManager.emptyString
                    onSelected: {
                        state = "PaymentRequest";
                        qrCodeTextMouseArea.hoverEnabled = true;
                    }
                }
            }

            Rectangle {
                id: qrContainer
                color: ScalaComponents.Style.blackTheme ? "white" : "transparent"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.qrSize
                Layout.preferredHeight: width
                radius: 4

                Image {
                    id: qrCode
                    anchors.fill: parent
                    anchors.margins: 1
                    smooth: false
                    fillMode: Image.PreserveAspectFit
                    source: "image://qrcode/" + generateQRCodeString();

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onEntered: qrCodeTooltip.tooltipPopup.open()
                        onExited: qrCodeTooltip.tooltipPopup.close()
                        onClicked: {
                            if (mouse.button == Qt.LeftButton){
                                walletManager.saveQrCodeToClipboard(generateQRCodeString());
                                appWindow.showStatusMessage(qsTr("QR code copied to clipboard") + translationManager.emptyString, 3);
                            } else if (mouse.button == Qt.RightButton){
                                qrMenu.x = this.mouseX;
                                qrMenu.y = this.mouseY;
                                qrMenu.open()
                            }
                        }
                    }
                }

                Menu {
                    id: qrMenu
                    title: "QrCode"
                    currentIndex: menuItem1.hovered ? 0 : menuItem2.hovered ? 1 : -1

                    MenuItem {
                        id: menuItem1
                        text: qsTr("Copy to clipboard") + translationManager.emptyString;
                        onTriggered: walletManager.saveQrCodeToClipboard(generateQRCodeString())
                    }

                    MenuItem {
                        id: menuItem2
                        text: qsTr("Save as Image") + translationManager.emptyString;
                        onTriggered: qrFileDialog.open()
                    }
                }

                ScalaComponents.Tooltip {
                    id: qrCodeTooltip
                    text: qsTr("Left click: copy QR code to clipboard") + "<br>" +  qsTr("Right click: save QR code as image file") + translationManager.emptyString
                }
            }

            ScalaComponents.TextPlain {
                id: qrCodeText
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 6
                Layout.maximumWidth: 285
                Layout.minimumHeight: 75
                verticalAlignment: Text.AlignVCenter
                visible: paymentRequestGridLayout.visible
                font.pixelSize: 12
                color: qrCodeTextMouseArea.containsMouse ? ScalaComponents.Style.orange : ScalaComponents.Style.defaultFontColor
                text: generateQRCodeString();
                wrapMode: Text.WrapAnywhere
                tooltip: qsTr("Copy payment request to clipboard") + translationManager.emptyString
                themeTransition: false

                MouseArea {
                    id: qrCodeTextMouseArea
                    hoverEnabled: false //true when Payment request navbar button is clicked (fix bug displaying tooltip when navbar button is clicked)
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.tooltipPopup.open()
                    onExited: parent.tooltipPopup.close()
                    onClicked: {
                        clipboard.setText(qrCodeText.text);
                        appWindow.showStatusMessage(qsTr("Payment request copied to clipboard") + translationManager.emptyString, 3);
                    }
                }
            }

            GridLayout {
                id: paymentRequestGridLayout
                columns: 3
                rows: 4
                visible: pageReceive.state == "PaymentRequest"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 6
                Layout.preferredWidth: 285
                Layout.maximumWidth: 285

                ScalaComponents.Label {
                    id: amountTitleFiat
                    Layout.bottomMargin: 3
                    Layout.preferredWidth: 90
                    visible: persistentSettings.fiatPriceEnabled
                    fontSize: 14
                    text: qsTr("Amount") + translationManager.emptyString
                }

                ScalaComponents.Input {
                    id: amountToReceiveFiat
                    Layout.preferredWidth: 165
                    Layout.maximumWidth: 165
                    visible: persistentSettings.fiatPriceEnabled
                    topPadding: 5
                    leftPadding: 5
                    font.family: ScalaComponents.Style.fontMonoRegular.name
                    font.pixelSize: 14
                    font.bold: false
                    horizontalAlignment: TextInput.AlignLeft
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    color: ScalaComponents.Style.defaultFontColor
                    placeholderText: "0.00"

                    background: Rectangle {
                        color: ScalaComponents.Style.blackTheme ? "transparent" : "white"
                        radius: 3
                        border.color: parent.activeFocus ? ScalaComponents.Style.inputBorderColorActive : ScalaComponents.Style.inputBorderColorInActive
                        border.width: 1
                    }
                    onTextEdited: {
                        text = text.trim().replace(",", ".");
                        const match = text.match(/^0+(\d.*)/);
                        if (match) {
                            const cursorPosition = cursorPosition;
                            text = match[1];
                            cursorPosition = Math.max(cursorPosition, 1) - 1;
                        } else if(text.indexOf('.') === 0){
                            text = '0' + text;
                            if (text.length > 2) {
                                cursorPosition = 1;
                            }
                        }
                        if (amountToReceiveFiat.text == "") {
                            amountToReceiveXLA.text = "";
                        } else {
                            amountToReceiveXLA.text = fiatApiConvertToXLA(amountToReceiveFiat.text);
                        }
                    }
                    validator: RegExpValidator {
                        regExp: /^\s*(\d{1,8})?([\.,]\d{1,2})?\s*$/
                    }
                }

                ScalaComponents.Label {
                    Layout.bottomMargin: 3
                    visible: persistentSettings.fiatPriceEnabled
                    fontSize: 14
                    text: appWindow.fiatApiCurrencySymbol();
                }

                ScalaComponents.Label {
                    id: amountTitleXLA
                    Layout.bottomMargin: 3
                    Layout.preferredWidth: 90
                    fontSize: 14
                    text: persistentSettings.fiatPriceEnabled ? "" : qsTr("Amount") + translationManager.emptyString
                }

                ScalaComponents.Input {
                    id: amountToReceiveXLA
                    Layout.preferredWidth: 165
                    Layout.maximumWidth: 165
                    topPadding: 5
                    leftPadding: 5
                    font.family: ScalaComponents.Style.fontMonoRegular.name
                    font.pixelSize: 14
                    font.bold: false
                    horizontalAlignment: TextInput.AlignLeft
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    color: ScalaComponents.Style.defaultFontColor
                    placeholderText: "0.000000000000"

                    background: Rectangle {
                        color: ScalaComponents.Style.blackTheme ? "transparent" : "white"
                        radius: 3
                        border.color: parent.activeFocus ? ScalaComponents.Style.inputBorderColorActive : ScalaComponents.Style.inputBorderColorInActive
                        border.width: 1
                    }
                    onTextEdited: {
                        text = text.trim().replace(",", ".");
                        const match = text.match(/^0+(\d.*)/);
                        if (match) {
                            const cursorPosition = cursorPosition;
                            text = match[1];
                            cursorPosition = Math.max(cursorPosition, 1) - 1;
                        } else if(text.indexOf('.') === 0){
                            text = '0' + text;
                            if (text.length > 2) {
                                cursorPosition = 1;
                            }
                        }
                        if (amountToReceiveXLA.text == "") {
                            amountToReceiveFiat.text = "";
                        } else {
                            amountToReceiveFiat.text = fiatApiConvertToFiat(amountToReceiveXLA.text);
                        }
                    }
                    validator: RegExpValidator {
                        regExp: /^\s*(\d{1,8})?([\.,]\d{1,12})?\s*$/
                    }
                }

                ScalaComponents.Label {
                    Layout.bottomMargin: 3
                    fontSize: 14
                    text: "XLA"
                }

                ScalaComponents.Label {
                    id: txDescription
                    Layout.bottomMargin: 3
                    Layout.preferredWidth: 90
                    fontSize: 14
                    text: qsTr("Description") + translationManager.emptyString
                    tooltip: qsTr("What is being payed for (a product, service, donation) (optional)") + translationManager.emptyString
                    tooltipIconVisible: true
                }

                ScalaComponents.Input {
                    id: txDescriptionInput
                    Layout.preferredWidth: 165
                    Layout.maximumWidth: 165
                    maximumLength: 800
                    topPadding: 7
                    leftPadding: 7
                    font.pixelSize: 14
                    font.bold: false
                    horizontalAlignment: TextInput.AlignLeft
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    color: ScalaComponents.Style.defaultFontColor
                    placeholderText: qsTr("Visible to the sender") + translationManager.emptyString

                    background: Rectangle {
                        color: ScalaComponents.Style.blackTheme ? "transparent" : "white"
                        radius: 3
                        border.color: parent.activeFocus ? ScalaComponents.Style.inputBorderColorActive : ScalaComponents.Style.inputBorderColorInActive
                        border.width: 1
                    }
                }

                ScalaComponents.Label {
                    Layout.bottomMargin: 3
                    fontSize: 14
                    text: ""
                }

                ScalaComponents.Label {
                    id: receiverNameLabel
                    Layout.bottomMargin: 3
                    Layout.preferredWidth: 90
                    fontSize: 14
                    text: qsTr("Your name") + translationManager.emptyString
                    tooltip: qsTr("Your name, company or website (optional)") + translationManager.emptyString
                    tooltipIconVisible: true
                }

                ScalaComponents.Input {
                    id: receiverNameInput
                    Layout.preferredWidth: 165
                    Layout.maximumWidth: 165
                    topPadding: 7
                    leftPadding: 7
                    font.pixelSize: 14
                    font.bold: false
                    horizontalAlignment: TextInput.AlignLeft
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    color: ScalaComponents.Style.defaultFontColor
                    placeholderText: qsTr("Visible to the sender") + translationManager.emptyString
                    maximumLength: 100

                    background: Rectangle {
                        color: ScalaComponents.Style.blackTheme ? "transparent" : "white"
                        radius: 3
                        border.color: parent.activeFocus ? ScalaComponents.Style.inputBorderColorActive : ScalaComponents.Style.inputBorderColorInActive
                        border.width: 1
                    }
                }

                ScalaComponents.Label {
                    Layout.bottomMargin: 3
                    fontSize: 14
                    text: ""
                }
            }

            ScalaComponents.TextPlain {
                id: selectedaddressIndex
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 220
                Layout.maximumWidth: 220
                Layout.topMargin: 15
                visible: pageReceive.state == "Address"
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Address #") + subaddressListView.currentIndex + translationManager.emptyString
                wrapMode: Text.WordWrap
                font.family: ScalaComponents.Style.fontRegular.name
                font.pixelSize: 17
                textFormat: Text.RichText
                color: ScalaComponents.Style.defaultFontColor
                themeTransition: false
            }

            ScalaComponents.TextPlain {
                id: selectedAddressDrescription
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 220
                Layout.maximumWidth: 220
                Layout.topMargin: 10
                visible: pageReceive.state == "Address"
                horizontalAlignment: Text.AlignHCenter
                text: "(" + qsTr("no label") + ")" + translationManager.emptyString
                wrapMode: Text.WordWrap
                font.family: ScalaComponents.Style.fontRegular.name
                font.pixelSize: 17
                textFormat: Text.RichText
                color: selectedAddressDrescriptionMouseArea.containsMouse ? ScalaComponents.Style.orange : ScalaComponents.Style.dimmedFontColor
                themeTransition: false
                tooltip: subaddressListView.currentIndex > 0 ? qsTr("Edit address label") : "" + translationManager.emptyString
                MouseArea {
                    id: selectedAddressDrescriptionMouseArea
                    visible: subaddressListView.currentIndex > 0
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.tooltip ? parent.tooltipPopup.open() : ""
                    onExited: parent.tooltip ? parent.tooltipPopup.close() : ""
                    onClicked: {
                        renameSubaddressLabel(appWindow.current_subaddress_table_index);
                    }
                }
            }

            ScalaComponents.TextPlain {
                id: selectedAddress
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 300
                Layout.topMargin: 11
                visible: pageReceive.state == "Address"
                text: appWindow.current_address ? appWindow.current_address : ""
                horizontalAlignment: TextInput.AlignHCenter
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                color: selectedAddressMouseArea.containsMouse ? ScalaComponents.Style.orange : ScalaComponents.Style.defaultFontColor
                font.pixelSize: 15
                font.family: ScalaComponents.Style.fontRegular.name
                themeTransition: false
                tooltip: qsTr("Copy address to clipboard") + translationManager.emptyString
                MouseArea {
                    id: selectedAddressMouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.tooltip ? parent.tooltipPopup.open() : ""
                    onExited: parent.tooltip ? parent.tooltipPopup.close() : ""
                    onClicked: {
                        clipboard.setText(appWindow.current_address);
                        appWindow.showStatusMessage(qsTr("Address copied to clipboard") + translationManager.emptyString, 3);
                    }
                }
            }

            ScalaComponents.StandardButton {
                Layout.preferredWidth: 220
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 18
                small: true
                text: qsTr("Show on device") + translationManager.emptyString
                fontSize: 14
                visible: appWindow.currentWallet ? appWindow.currentWallet.isHwBacked() : false
                onClicked: {
                    appWindow.currentWallet.deviceShowAddressAsync(
                        appWindow.currentWallet.currentSubaddressAccount,
                        appWindow.current_subaddress_table_index,
                        '');
                }
            }
        }

        ColumnLayout {
            id: addressRow
            spacing: 0

            RowLayout {
                spacing: 0

                ScalaComponents.LabelSubheader {
                    Layout.fillWidth: true
                    fontSize: 24
                    textFormat: Text.RichText
                    text: qsTr("Addresses") + translationManager.emptyString
                }

                ScalaComponents.StandardButton {
                    id: createAddressButton
                    small: true
                    text: qsTr("Create new address") + translationManager.emptyString
                    fontSize: 13
                    onClicked: {
                        inputDialog.labelText = qsTr("Set the label of the new address:") + translationManager.emptyString
                        inputDialog.onAcceptedCallback = function() {
                            appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, inputDialog.inputText)
                            current_subaddress_table_index = appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1
                            subaddressListView.currentIndex = current_subaddress_table_index
                        }
                        inputDialog.onRejectedCallback = null;
                        inputDialog.open()
                    }

                    Rectangle {
                        anchors.top: createAddressButton.bottom
                        anchors.topMargin: 8
                        anchors.left: createAddressButton.left
                        anchors.right: createAddressButton.right
                        height: 2
                        color: ScalaComponents.Style.appWindowBorderColor

                        ScalaEffects.ColorTransition {
                            targetObj: parent
                            blackColor: ScalaComponents.Style._b_appWindowBorderColor
                            whiteColor: ScalaComponents.Style._w_appWindowBorderColor
                        }
                    }
                }
            }

            ColumnLayout {
                id: subaddressListRow
                property int subaddressListItemHeight: 50
                Layout.topMargin: 6
                Layout.fillWidth: true
                Layout.minimumWidth: 240
                Layout.preferredHeight: subaddressListItemHeight * subaddressListView.count
                visible: subaddressListView.count >= 1

                ListView {
                    id: subaddressListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
                    interactive: false

                    delegate: Rectangle {
                        id: tableItem2
                        height: subaddressListRow.subaddressListItemHeight
                        width: parent ? parent.width : undefined
                        Layout.fillWidth: true
                        color: itemMouseArea.containsMouse || index === appWindow.current_subaddress_table_index ? ScalaComponents.Style.titleBarButtonHoverColor : "transparent"

                        Rectangle {
                            visible: index === appWindow.current_subaddress_table_index
                            Layout.fillHeight: true
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            property int currentAccountIndex: currentWallet ? currentWallet.currentSubaddressAccount : 0
                            color: ScalaComponents.Style.accountColors[currentAccountIndex % ScalaComponents.Style.accountColors.length]
                            width: 2
                        }

                        Rectangle{
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 1
                            color: ScalaComponents.Style.appWindowBorderColor
                            visible: index !== 0

                            ScalaEffects.ColorTransition {
                                targetObj: parent
                                blackColor: ScalaComponents.Style._b_appWindowBorderColor
                                whiteColor: ScalaComponents.Style._w_appWindowBorderColor
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 5
                            anchors.rightMargin: 90
                            color: "transparent"

                            ScalaComponents.Label {
                                id: idLabel
                                color: index === appWindow.current_subaddress_table_index ? ScalaComponents.Style.defaultFontColor : "#757575"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                fontSize: 16
                                text: "#" + index
                                themeTransition: false
                            }

                            ScalaComponents.Label {
                                id: nameLabel
                                color: index === appWindow.current_subaddress_table_index ? ScalaComponents.Style.defaultFontColor : ScalaComponents.Style.dimmedFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: idLabel.right
                                anchors.leftMargin: 6
                                fontSize: 16
                                text: label
                                elide: Text.ElideRight
                                textWidth: addressLabel.x - nameLabel.x - 1
                                themeTransition: false
                            }

                            ScalaComponents.Label {
                                id: addressLabel
                                color: ScalaComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.right
                                anchors.leftMargin: -addressLabel.width - 5
                                fontSize: 16
                                fontFamily: ScalaComponents.Style.fontMonoRegular.name;
                                text: TxUtils.addressTruncatePretty(address, mainLayout.width < 520 ? 1 : (mainLayout.width < 650 ? 2 : 3))
                                themeTransition: false
                            }

                            MouseArea {
                                id: itemMouseArea
                                cursorShape: Qt.PointingHandCursor
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: subaddressListView.currentIndex = index;
                            }
                        }

                        RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            height: 21
                            spacing: 10

                            ScalaComponents.IconButton {
                                fontAwesomeFallbackIcon: FontAwesome.searchPlus
                                fontAwesomeFallbackSize: 22
                                color: ScalaComponents.Style.defaultFontColor
                                fontAwesomeFallbackOpacity: 0.5
                                Layout.preferredWidth: 23
                                Layout.preferredHeight: 21
                                tooltip: qsTr("See transactions") + translationManager.emptyString

                                onClicked: doSearchInHistory(address)
                            }

                            ScalaComponents.IconButton {
                                id: renameButton
                                image: "qrc:///images/edit.svg"
                                fontAwesomeFallbackIcon: FontAwesome.edit
                                fontAwesomeFallbackSize: 22
                                color: ScalaComponents.Style.defaultFontColor
                                opacity: isOpenGL ? 0.5 : 1
                                fontAwesomeFallbackOpacity: 0.5
                                Layout.preferredWidth: 23
                                Layout.preferredHeight: 21
                                visible: index !== 0
                                tooltip: qsTr("Edit address label") + translationManager.emptyString

                                onClicked: {
                                    renameSubaddressLabel(index);
                                }
                            }

                            ScalaComponents.IconButton {
                                id: copyButton
                                image: "qrc:///images/copy.svg"
                                fontAwesomeFallbackIcon: FontAwesome.clipboard
                                fontAwesomeFallbackSize: 22
                                color: ScalaComponents.Style.defaultFontColor
                                opacity: isOpenGL ? 0.5 : 1
                                fontAwesomeFallbackOpacity: 0.5
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 21
                                tooltip: qsTr("Copy address to clipboard") + translationManager.emptyString

                                onClicked: {
                                    console.log("Address copied to clipboard");
                                    clipboard.setText(address);
                                    appWindow.showStatusMessage(qsTr("Address copied to clipboard"),3);
                                }
                            }
                        }
                    }
                    onCurrentItemChanged: {
                        // reset global vars
                        appWindow.current_subaddress_table_index = subaddressListView.currentIndex;
                        appWindow.current_address = appWindow.currentWallet.address(
                            appWindow.currentWallet.currentSubaddressAccount,
                            subaddressListView.currentIndex
                        );
                        if (subaddressListView.currentIndex == 0) {
                            selectedAddressDrescription.text = qsTr("Primary address") + translationManager.emptyString;
                        } else {
                            var selectedAddressLabel = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, appWindow.current_subaddress_table_index);
                            if (selectedAddressLabel == "") {
                                selectedAddressDrescription.text = "(" + qsTr("no label") + ")" + translationManager.emptyString
                            } else {
                                selectedAddressDrescription.text = selectedAddressLabel
                            }
                        }
                    }
                }
            }

            Rectangle {
                color: ScalaComponents.Style.appWindowBorderColor
                Layout.fillWidth: true
                height: 1

                ScalaEffects.ColorTransition {
                    targetObj: parent
                    blackColor: ScalaComponents.Style._b_appWindowBorderColor
                    whiteColor: ScalaComponents.Style._w_appWindowBorderColor
                }
            }
        }

        MessageDialog {
            id: receivePageDialog
            standardButtons: StandardButton.Ok
        }

        FileDialog {
            id: qrFileDialog
            title: qsTr("Please choose a name") + translationManager.emptyString
            folder: shortcuts.pictures
            selectExisting: false
            nameFilters: ["Image (*.png)"]
            onAccepted: {
                if(!walletManager.saveQrCode(generateQRCodeString(), walletManager.urlToLocalPath(fileUrl))) {
                    console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                    receivePageDialog.title = qsTr("Save QrCode") + translationManager.emptyString;
                    receivePageDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                    receivePageDialog.icon = StandardIcon.Error
                    receivePageDialog.open()
                } else {
                    appWindow.showStatusMessage(qsTr("QR code saved to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString, 3);
                }
            }
        }
    }

    function onPageCompleted() {
        console.log("Receive page loaded");
        pageReceive.clearFields();
        subaddressListView.model = appWindow.currentWallet.subaddressModel;

        if (appWindow.currentWallet) {
            appWindow.current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, 0)
            appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
            if (subaddressListView.currentIndex == -1) {
                subaddressListView.currentIndex = 0;
            }
        }
    }

    function clearFields() {
        amountToReceiveFiat.text = "";
        amountToReceiveXLA.text = "";
        txDescriptionInput.text = "";
        receiverNameInput.text = "";
    }

    function onPageClosed() {
    }
}
