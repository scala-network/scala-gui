import QtQuick 2.9

import "." as ScalaComponents
import "effects/" as ScalaEffects

Text {
    // When using this component, please note that if you use a color different
    // than `defaultFontColor`, you are required to also define `themeTransitionXColor`.
    // If you do not set these the component will receive the wrong color after a transition.
    // If you do not want to set these, use `themeTransition: false`.
    id: root
    property bool themeTransition: true
    property string themeTransitionBlackColor: ""
    property string themeTransitionWhiteColor: ""
    property alias tooltip: tooltip.text
    property alias tooltipLeft: tooltip.tooltipLeft
    property alias tooltipIconVisible: tooltip.tooltipIconVisible
    property alias tooltipPopup: tooltip.tooltipPopup
    font.family: ScalaComponents.Style.fontMedium.name
    font.bold: false
    font.pixelSize: 14
    textFormat: Text.PlainText

    Rectangle {
        width: root.contentWidth
        height: root.height
        anchors.left: parent.left
        anchors.top: parent.top
        color: root.focus ? ScalaComponents.Style.titleBarButtonHoverColor : "transparent"
    }

    ScalaEffects.ColorTransition {
        enabled: root.themeTransition
        themeTransition: root.themeTransition
        targetObj: root
        duration: 750
        blackColor: root.themeTransitionBlackColor !== "" ? root.themeTransitionBlackColor : ScalaComponents.Style._b_defaultFontColor
        whiteColor: root.themeTransitionWhiteColor !== "" ? root.themeTransitionWhiteColor : ScalaComponents.Style._w_defaultFontColor
    }

    ScalaComponents.Tooltip {
        id: tooltip
        anchors.top: parent.top
        anchors.left: tooltipIconVisible ? parent.right : parent.left
    }
}
