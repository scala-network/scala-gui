import QtQuick 2.9

import "../components" as ScalaComponents

TextEdit {
    color: ScalaComponents.Style.defaultFontColor
    font.family: ScalaComponents.Style.fontRegular.name
    selectionColor: ScalaComponents.Style.textSelectionColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
