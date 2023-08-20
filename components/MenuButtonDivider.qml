import QtQuick 2.9

import "." as ScalaComponents
import "effects/" as ScalaEffects

Rectangle {
    color: ScalaComponents.Style.appWindowBorderColor
    height: 1

    ScalaEffects.ColorTransition {
        targetObj: parent
        blackColor: ScalaComponents.Style._b_appWindowBorderColor
        whiteColor: ScalaComponents.Style._w_appWindowBorderColor
    }
}
