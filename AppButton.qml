import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Universal 2.12
import QtGraphicalEffects 1.12
import AndroidNative 1.0 as AN

Button {
    id: appButton

    property var app
    property string iconSource
    property bool hasColoredIcon

    flat:true

    background: Rectangle {
        color: "transparent"
        border.color: "transparent"
    }

    contentItem: Rectangle {
        anchors.fill: parent
        color: Universal.foreground
        opacity: Universal.theme === Universal.Light ? 0.1 : 0.2
        radius: width * 0.5

        Image {
            id: appIcon
            anchors.centerIn: parent
            source: iconSource
            width: appButton.width * 0.8
            height: appButton.width * 0.8

            ColorOverlay {
                anchors.fill: buttonIcon
                source: appIcon
                color: gridCell.overlayColor
                visible: hasColoredIcon
            }
        }
    }

    onClicked: {
        AN.SystemDispatcher.dispatch("volla.launcher.runAppAction", {"appId": app.package})
    }
}
