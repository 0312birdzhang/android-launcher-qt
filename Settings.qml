import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Universal 2.12
import Qt.labs.settings 1.0
import AndroidNative 1.0 as AN

Page {
    id: settingsPage
    anchors.fill: parent
    topPadding: mainView.innerSpacing

    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: settingsColumn.height

        Column {
            id: settingsColumn
            width: parent.width

            Label {
                id: headerLabel
                padding: mainView.innerSpacing
                width: parent.width - 2 * mainView.innerSpacing
                text: qsTr("Settings")
                font.pointSize: mainView.headerFontSize
                font.weight: Font.Black
                bottomPadding: mainView.innerSpacing
            }

            MouseArea {
                id: themeSettingsItem
                width: parent.width
                implicitHeight: themeSettingsItemColumn.height
                preventStealing: true

                property var selectedMenuItem: themeSettingsItemTitle
                property bool menuState: false
                property double labelOpacity: 0.0

                Column {
                    id: themeSettingsItemColumn
                    width: parent.width

                    Label {
                        id: themeSettingsItemTitle

                        property var theme: themeSettings.theme

                        padding: mainView.innerSpacing
                        width: parent.width
                        text: qsTr("Dark Mode")
                        font.pointSize: mainView.largeFontSize
                        font.weight: themeSettingsItem.menuState ? Font.Black : Font.Normal
                        color: themeSettingsItem.menuState ? "white" : Universal.foreground
                        background: Rectangle {
                            anchors.fill: parent
                            color: themeSettingsItem.menuState === true ? Universal.accent : "transparent"
                        }

                        Component.onCompleted: {
                            theme = themeSettings.theme
                            switch (themeSettings.theme) {
                            case mainView.theme.Dark:
                                text = qsTr("Dark Mode")
                                break
                            case mainView.theme.Light:
                                text = qsTr("Light Mode")
                                break
                            case mainView.theme.Translucent:
                                text = qsTr("Translucent Mode")
                                break
                            default:
                                console.log("Settings | Unknown theme selected: " + mainView.theme)
                            }
                        }
                    }
                    Button {
                        id: darkModeOption

                        property var theme: mainView.theme.Dark

                        leftPadding: mainView.innerSpacing
                        rightPadding: mainView.innerSpacing
                        bottomPadding: mainView.innerSpacing
                        width: parent.width
                        visible: themeSettingsItem.menuState
                        text: qsTr("Dark Mode")
                        contentItem: Text {
                            text: darkModeOption.text
                            font.pointSize: mainView.mediumFontSize
                            font.weight: themeSettingsItem.selectedMenuItem === darkModeOption ? Font.Black : Font.Normal
                            color: "white"
                            opacity: themeSettingsItem.labelOpacity
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: themeSettingsItem.menuState ? Universal.accent : "transparent"
                        }
                    }
                    Button {
                        id: lightModeOption

                        property var theme: mainView.theme.Light

                        leftPadding: mainView.innerSpacing
                        rightPadding: mainView.innerSpacing
                        bottomPadding: mainView.innerSpacing
                        width: parent.width
                        visible: themeSettingsItem.menuState
                        text: qsTr("Light Mode")
                        contentItem: Text {
                            text: lightModeOption.text
                            font.pointSize: mainView.mediumFontSize
                            font.weight: themeSettingsItem.selectedMenuItem === lightModeOption ? Font.Black : Font.Normal
                            color: "white"
                            opacity: themeSettingsItem.labelOpacity
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: themeSettingsItem.menuState ? Universal.accent : "transparent"
                        }
                    }
                    Button {
                        id: translucentModeOption

                        property var theme: mainView.theme.Translucent

                        leftPadding: mainView.innerSpacing
                        rightPadding: mainView.innerSpacing
                        bottomPadding: mainView.innerSpacing * 2
                        width: parent.width
                        visible: themeSettingsItem.menuState
                        text: qsTr("Translucent Mode")
                        contentItem: Text {
                            text: translucentModeOption.text
                            font.pointSize: mainView.mediumFontSize
                            font.weight: themeSettingsItem.selectedMenuItem === translucentModeOption ? Font.Black : Font.Normal
                            color: "white"
                            opacity: themeSettingsItem.labelOpacity
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: themeSettingsItem.menuState ? Universal.accent : "transparent"
                        }
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 250.
                        onRunningChanged: {
                            if (!running && themeSettingsItem.menuState) {
                                console.log("Settings | Switch on mode options labels")
                                themeSettingsItem.labelOpacity = 1.0
                            } else if (running && !themeSettingsItem.menuState) {
                                console.log("Settings | Switch off mode option labels")
                                themeSettingsItem.labelOpacity = 0.0
                            }
                        }
                    }
                }

                Behavior on labelOpacity {
                    NumberAnimation {
                        duration: 250
                    }
                }

                onEntered: {
                    console.log("Settings | mouse entered")
                    preventStealing = !preventStealing
                    menuState = true
                }
                onCanceled: {
                    console.log("Settings | mouse cancelled")
                    preventStealing = !preventStealing
                    menuState = false
                    executeSelection()
                }
                onExited: {
                    console.log("Settings | mouse exited")
                    preventStealing = !preventStealing
                    menuState = false
                    executeSelection()
                }
                onMouseYChanged: {
                    var firstPoint = mapFromItem(darkModeOption, 0, 0)
                    var secondPoint = mapFromItem(lightModeOption, 0, 0)
                    var thirdPoint = mapFromItem(translucentModeOption, 0, 0)
                    var selectedItem

                    if (mouseY > firstPoint.y && mouseY < firstPoint.y + darkModeOption.height) {
                        selectedItem = darkModeOption
                    } else if (mouseY > secondPoint.y && mouseY < secondPoint.y + lightModeOption.height) {
                        selectedItem = lightModeOption
                    } else if (mouseY > thirdPoint.y && mouseY < thirdPoint.y + translucentModeOption.height) {
                        selectedItem = translucentModeOption
                    } else {
                        selectedItem = themeSettingsItemTitle
                    }
                    if (selectedMenuItem !== selectedItem) {
                        selectedMenuItem = selectedItem
                        if (selectedMenuItem !== themeSettingsItemTitle && mainView.useVibration) {
                            AN.SystemDispatcher.dispatch("volla.launcher.vibrationAction", {"duration": mainView.vibrationDuration})
                        }
                    }
                }

                function executeSelection() {
                    console.log("Settings | Current mode: " + Universal.theme + ", " + themeSettings.theme)
                    console.log("Settings | Execute mode selection: " + selectedMenuItem.text + ", " + selectedMenuItem.theme)
                    if (themeSettings.theme !== selectedMenuItem.theme && selectedMenuItem !== themeSettingsItemTitle) {
                        themeSettingsItemTitle.text = selectedMenuItem.text

                        themeSettings.theme = selectedMenuItem.theme

                        if (themeSettings.sync) {
                            themeSettings.sync()
                        }

                        switch (themeSettings.theme) {
                            case mainView.theme.Dark:
                                console.log("Setting | Enable dark mode")
                                mainView.switchTheme(mainView.theme.Dark, true)
                                break
                            case mainView.theme.Light:
                                console.log("Setting | Enable light mode")
                                mainView.switchTheme(mainView.theme.Light, true)
                                break
                            case mainView.theme.Translucent:
                                console.log("Setting | Enable translucent mode")
                                mainView.switchTheme(mainView.theme.Translucent, true)
                                break
                            default:
                                console.log("Settings | Unknown theme selected: " + themeSettings.theme)
                        }

                        selectedMenuItem = themeSettingsItemTitle
                    }
                }

                Settings {
                    id: themeSettings
                    property int theme: mainView.theme.Dark
                }
            }

            Item {
                id: newsSettingsItem
                width: parent.width
                implicitHeight: newsSettingsItemColumn.height

                Column {
                    id: newsSettingsItemColumn
                    width: parent.width

                    property bool menuState: false
                    property var newsCheckboxes: new Array

                    Button {
                        id: newsSettingsItemTitle
                        width: parent.width
                        padding: mainView.innerSpacing
                        contentItem: Text {
                            width: parent.width - 2 * newsSettingsItemTitle.padding
                            text: qsTr("News Channels")
                            font.pointSize: mainView.largeFontSize
                            font.weight: newsSettingsItemColumn.menuState ? Font.Black : Font.Normal
                            color: Universal.foreground
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                        }
                        onClicked: {
                            newsSettingsItemColumn.menuState = !newsSettingsItemColumn.menuState
                            if (newsSettingsItemColumn.menuState) {
                                console.log("Settings | Will create new checkboxes")
                                newsSettingsItemColumn.createCheckboxes()
                            } else {
                                console.log("Settings | Will destroy new checkboxes")
                                newsSettingsItemColumn.destroyCheckboxes()
                            }
                        }
                    }

                    function createCheckboxes() {
                        var cannels = mainView.getFeeds()

                        for (var i = 0; i < cannels.length; i++) {
                            var component = Qt.createComponent("/Checkbox.qml", newsSettingsItemColumn)
                            var properties = { "actionId": cannels[i]["id"],
                                "text": cannels[i]["name"], "checked": cannels[i]["activated"],
                                "labelFontSize": mainView.mediumFontSize, "circleSize": mainView.largeFontSize,
                                "leftPadding": mainView.innerSpacing, "rightPadding": mainView.innerSpacing,
                                "bottomPadding": mainView.innerSpacing / 2, "topPadding": mainView.innerSpacing / 2,
                                "hasRemoveButton": true}
                            var object = component.createObject(newsSettingsItemColumn, properties)
                            newsSettingsItemColumn.newsCheckboxes.push(object)
                        }
                        console.log("Settings News checkboxes created")
                    }

                    function destroyCheckboxes() {
                        for (var i = 0; i < newsSettingsItemColumn.newsCheckboxes.length; i++) {
                            var checkbox = newsSettingsItemColumn.newsCheckboxes[i]
                            checkbox.destroy()
                        }
                        newsSettingsItemColumn.newsCheckboxes = new Array
                    }

                    function updateSettings(channelId, active) {
                        console.log("Settings | Update settings for " + channelId + ", " + active)
                        mainView.updateFeed(channelId, active, mainView.settingsAction.UPDATE)
                    }

                    function removeSettings(channelId) {
                        console.log("Settings | Remove settings for " + channelId)
                        mainView.updateFeed(channelId, false, mainView.settingsAction.REMOVE)
                        for (var i = 0; i < newsSettingsItemColumn.newsCheckboxes.length; i++) {
                            var checkbox = newsSettingsItemColumn.newsCheckboxes[i]
                            if (checkbox.actionId === channelId) {
                                newsCheckboxes.splice(i, 1)
                                checkbox.destroy()
                            }
                        }
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 250.0
                    }
                }
            }

            Item {
                id: shortcutSettingsItem
                width: parent.width
                implicitHeight: shortcutSettingsItemColumn.height

                Column {
                    id: shortcutSettingsItemColumn
                    width: parent.width

                    property bool menuState: false
                    property var checkboxes: new Array

                    Button {
                        id: shortcutSettingsItemButton
                        width: parent.width
                        padding: mainView.innerSpacing
                        contentItem: Text {
                            width: parent.width - 2 * shortcutSettingsItemButton.padding
                            text: qsTr("Shortcuts")
                            font.pointSize: mainView.largeFontSize
                            font.weight: shortcutSettingsItemColumn.menuState ? Font.Black : Font.Normal
                            color: Universal.foreground
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                        }
                        onClicked: {
                            shortcutSettingsItemColumn.menuState = !shortcutSettingsItemColumn.menuState
                            if (shortcutSettingsItemColumn.menuState) {
                                console.log("Settings | Will create checkboxes")
                                shortcutSettingsItemColumn.createCheckboxes()
                            } else {
                                console.log("Settings | Will destroy checkboxes")
                                shortcutSettingsItemColumn.destroyCheckboxes()
                            }
                        }
                    }

                    function createCheckboxes() {
                        var shortcuts = mainView.getActions()

                        for (var i = 0; i < shortcuts.length; i++) {
                            var component = Qt.createComponent("/Checkbox.qml", shortcutSettingsItemColumn)
                            var properties = { "actionId": shortcuts[i]["id"],
                                "text": shortcuts[i]["name"], "checked": shortcuts[i]["activated"],
                                "labelFontSize": mainView.mediumFontSize, "circleSize": mainView.largeFontSize,
                                "leftPadding": mainView.innerSpacing, "rightPadding": mainView.innerSpacing,
                                "bottomPadding": mainView.innerSpacing / 2, "topPadding": mainView.innerSpacing / 2,
                                "hasRemoveButton": getFilteredShortcuts(mainView.defaultActions, "id", shortcuts[i]["id"]).length === 0 }
                            var object = component.createObject(shortcutSettingsItemColumn, properties)
                            shortcutSettingsItemColumn.checkboxes.push(object)
                        }
                        console.log("Settings | Checkboxes created")
                    }

                    function getFilteredShortcuts(array, key, value) {
                        return array.filter(function(e) {
                            return e[key] === value;
                        });
                    }

                    function destroyCheckboxes() {
                        for (var i = 0; i < shortcutSettingsItemColumn.checkboxes.length; i++) {
                            var checkbox = shortcutSettingsItemColumn.checkboxes[i]
                            checkbox.destroy()
                        }
                        shortcutSettingsItemColumn.checkboxes = new Array
                    }

                    function updateSettings(actionId, active) {
                        console.log("Settings | Update settings for " + actionId + ", " + active)
                        mainView.updateAction(actionId, active, mainView.settingsAction.UPDATE)
                    }

                    function removeSettings(actionId) {
                        console.log("Settings | Remove settings for " + actionId)
                        mainView.updateAction(actionId, false, mainView.settingsAction.REMOVE)
                        for (var i = 0; i < shortcutSettingsItemColumn.checkboxes.length; i++) {
                            var checkbox = shortcutSettingsItemColumn.checkboxes[i]
                            if (checkbox.actionId === actionId) {
                                checkboxes.splice(i, 1)
                                checkbox.destroy()
                            }
                        }
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 250.0
                    }
                }
            }

            // todo: Add source settings

            Item {
                id: searchSettingsItem
                width: parent.width
                implicitHeight: searchSettingsItemColumn.height
                visible: false

                Column {
                    id: searchSettingsItemColumn
                    width: parent.width

                    property bool menuState: false
                    property var checkboxes: new Array

                    Button {
                        id: searchSettingsItemButton
                        width: parent.width
                        padding: mainView.innerSpacing
                        contentItem: Text {
                            width: parent.width - 2 * shortcutSettingsItemButton.padding
                            text: qsTr("Search engines")
                            font.pointSize: mainView.largeFontSize
                            font.weight: shortcutSettingsItemColumn.menuState ? Font.Black : Font.Normal
                            color: Universal.foreground
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                        }
                        onClicked: {
                            searchSettingsItemColumn.menuState = !searchSettingsItemColumn.menuState
                            if (searchSettingsItemColumn.menuState) {
                                console.log("Settings | Will create checkboxes")
                                searchSettingsItemColumn.createCheckboxes()
                            } else {
                                console.log("Settings | Will destroy checkboxes")
                                searchSettingsItemColumn.destroyCheckboxes()
                            }
                        }
                    }

                    function createCheckboxes() {
                        var component = Qt.createComponent("/Checkbox.qml", designSettingsItemColumn)
                        var properties = { "actionId": "duckduckgo",
                                "text": qsTr("DuckDuckGo"), "checked": searchSettings.duckduckgo,
                                "labelFontSize": mainView.mediumFontSize, "circleSize": mainView.largeFontSize,
                                "leftPadding": mainView.innerSpacing, "rightPadding": mainView.innerSpacing,
                                "bottomPadding": mainView.innerSpacing / 2, "topPadding": mainView.innerSpacing / 2 }
                        var object = component.createObject(searchSettingsItemColumn, properties)
                        searchSettingsItemColumn.checkboxes.push(object)
                        component = Qt.createComponent("/Checkbox.qml", searchSettingsItemColumn)
                        properties["actionId"] = "startpage"
                        properties["text"] = qsTr("StartPage")
                        properties["checked"] = searchSettings.startpage
                        object = component.createObject(searchSettingsItemColumn, properties)
                        searchSettingsItemColumn.checkboxes.push(object)
                        component = Qt.createComponent("/Checkbox.qml", designSettingsItemColumn)
                        properties["actionId"] = "metager"
                        properties["text"] = qsTr("MetaGer")
                        properties["checked"] = searchSettings.metager
                        object = component.createObject(searchSettingsItemColumn, properties)
                        searchSettingsItemColumn.checkboxes.push(object)
                        console.log("Settings | Checkboxes created")
                    }

                    function destroyCheckboxes() {
                        for (var i = 0; i < searchSettingsItemColumn.checkboxes.length; i++) {
                            var checkbox = searchSettingsItemColumn.checkboxes[i]
                            checkbox.destroy()
                        }
                        searchSettingsItemColumn.checkboxes = new Array
                    }

                    function updateSettings(actionId, active) {
                        console.log("Settings | Update settings for " + actionId + ", " + active)

                        for (var i = 0; i < searchSettingsItemColumn.checkboxes.length; i++) {
                            var checkbox = searchSettingsItemColumn.checkboxes[i]

                        }

                        searchSettings.duckduckgo = actionId === "duckduckgo" ? active : !active
                        searchSettings.metager = actionId === "metager" ? active : !active
                        searchSettings.startpage = actionId === "startpage" ? active : !active
                        searchSettings.sync()
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 250.0
                    }
                }

                Settings {
                    id: searchSettings
                    property bool duckduckgo: true
                    property bool startpage: false
                    property bool metager: false
                }
            }

            Item {
                id: designSettingsItem
                width: parent.width
                implicitHeight: designSettingsItemColumn.height

                Column {
                    id: designSettingsItemColumn
                    width: parent.width

                    property bool menuState: false
                    property var checkboxes: new Array

                    Button {
                        id: designSettingsItemButton
                        width: parent.width
                        padding: mainView.innerSpacing
                        contentItem: Text {
                            width: parent.width - 2 * shortcutSettingsItemButton.padding
                            text: qsTr("Experimental")
                            font.pointSize: mainView.largeFontSize
                            font.weight: shortcutSettingsItemColumn.menuState ? Font.Black : Font.Normal
                            color: Universal.foreground
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                        }
                        onClicked: {
                            designSettingsItemColumn.menuState = !designSettingsItemColumn.menuState
                            if (designSettingsItemColumn.menuState) {
                                console.log("Settings | Will create checkboxes")
                                designSettingsItemColumn.createCheckboxes()
                            } else {
                                console.log("Settings | Will destroy checkboxes")
                                designSettingsItemColumn.destroyCheckboxes()
                            }
                        }
                    }

                    function createCheckboxes() {
                        var component = Qt.createComponent("/Checkbox.qml", designSettingsItemColumn)
                        var properties = { "actionId": "fullscreen",
                                "text": qsTr("Fullscreen"), "checked": designSettings.fullscreen,
                                "labelFontSize": mainView.mediumFontSize, "circleSize": mainView.largeFontSize,
                                "leftPadding": mainView.innerSpacing, "rightPadding": mainView.innerSpacing,
                                "bottomPadding": mainView.innerSpacing / 2, "topPadding": mainView.innerSpacing / 2 }
                        var object = component.createObject(designSettingsItemColumn, properties)
                        designSettingsItemColumn.checkboxes.push(object)
                        component = Qt.createComponent("/Checkbox.qml", designSettingsItemColumn)
                        properties["actionId"] = "coloredIcons"
                        properties["text"] = qsTr("Use colored app icons")
                        properties["checked"] = designSettings.useColoredIcons
                        object = component.createObject(designSettingsItemColumn, properties)
                        designSettingsItemColumn.checkboxes.push(object)
                        component = Qt.createComponent("/Checkbox.qml", designSettingsItemColumn)
                        properties["actionId"] = "startupIndex"
                        properties["text"] = qsTr("Show apps at startup")
                        properties["checked"] = designSettings.showAppsAtStartup
                        object = component.createObject(designSettingsItemColumn, properties)
                        designSettingsItemColumn.checkboxes.push(object)
                        component = Qt.createComponent("/Checkbox.qml", designSettingsItemColumn)
                        properties["actionId"] = "hapticMenus"
                        properties["text"] = qsTr("Use haptic menus")
                        properties["checked"] = designSettings.useHapticMenus
                        object = component.createObject(designSettingsItemColumn, properties)
                        designSettingsItemColumn.checkboxes.push(object)
                        console.log("Settings | Checkboxes created")
                    }

                    function destroyCheckboxes() {
                        for (var i = 0; i < designSettingsItemColumn.checkboxes.length; i++) {
                            var checkbox = designSettingsItemColumn.checkboxes[i]
                            checkbox.destroy()
                        }
                        designSettingsItemColumn.checkboxes = new Array
                    }

                    function updateSettings(actionId, active) {
                        console.log("Settings | Update settings for " + actionId + ", " + active)

                        if (actionId === "fullscreen") {
                            designSettings.fullscreen = active
                            designSettings.sync()
                            if (active) {
                                mainView.updateVisibility(5)
                            } else {
                                mainView.updateVisibility(2)
                            }
                        } else if (actionId === "coloredIcons") {
                            designSettings.useColoredIcons = active
                            designSettings.sync()
                            mainView.updateGridView(active)
                        } else if (actionId === "startupIndex") {
                            designSettings.showAppsAtStartup = active
                            designSettings.sync()
                        } else if (actionId === "hapticMenus") {
                            designSettings.useHapticMenus = active
                            designSettings.sync()
                            mainView.useVibration = active
                        }
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 250.0
                    }
                }

                Settings {
                    id: designSettings
                    property bool fullscreen: false
                    property bool useColoredIcons: false
                    property bool showAppsAtStartup: false
                    property bool useHapticMenus: false
                }
            }
        }
    }
}


