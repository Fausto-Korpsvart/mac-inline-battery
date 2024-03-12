import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.components 3.0 as PlasmaComponent
import org.kde.coreaddons as KCoreAddons
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.config

import org.kde.kquickcontrolsaddons
import "logic.js" as Logic

PlasmoidItem {
    id: batterywidget

    AppletConfig { id: config }

    // https://github.com/KDE/plasma-workspace/blob/master/dataengines/powermanagement/powermanagementengine.h
    // https://github.com/KDE/plasma-workspace/blob/master/dataengines/powermanagement/powermanagementengine.cpp

    Plasmoid.status: {
        if (powermanagementDisabled) {
            return PlasmaCore.Types.ActiveStatus
        }

        if (pmSource.data.Battery["Has Cumulative"]) {
            if (pmSource.data.Battery.State !== "Charging" && pmSource.data.Battery.Percent <= 5) {
                return PlasmaCore.Types.NeedsAttentionStatus
            } else if (pmSource.data["Battery"]["State"] !== "FullyCharged") {
                return PlasmaCore.Types.ActiveStatus
            }
        }

        return PlasmaCore.Types.PassiveStatus
    }

     toolTipMainText: {
        if (batteries.count === 0) {
            return i18n("No Batteries Available");
        } else if (!pmSource.data["Battery"]["Has Cumulative"]) {
            // Bug 362924: Distinguish between no batteries and no power supply batteries
            // just show the generic applet title in the latter case
            return i18n("Battery and Brightness")
        } else if (pmSource.data["Battery"]["State"] === "FullyCharged") {
            return i18n("Fully Charged");
        } else if (pmSource.data["AC Adapter"] && pmSource.data["AC Adapter"]["Plugged in"]) {
            var percent = pmSource.data.Battery.Percent
            var state = pmSource.data.Battery.State
            if (state === "Charging") {
                return i18n("%1%. Charging", percent)
            } else if (state === "NoCharge") {
                return i18n("%1%. Plugged in, not Charging", percent)
            } else {
                return i18n("%1%. Plugged in", percent)
            }
        } else {
            if (remainingTime > 0) {
                return i18nc("%1 is remaining time, %2 is percentage", "%1 Remaining (%2%)",
                             KCoreAddons.Format.formatDuration(remainingTime, KCoreAddons.FormatTypes.HideSeconds),
                             pmSource.data["Battery"]["Percent"])
            } else {
                return i18n("%1% Battery Remaining", pmSource.data["Battery"]["Percent"]);
            }
        }
    }

    toolTipSubText: powermanagementDisabled ? i18n("Power management is disabled") : ""

    property bool disableBrightnessUpdate: true
    property int screenBrightness
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0

    property int keyboardBrightness
    readonly property int maximumKeyboardBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Keyboard Brightness"] || 0 : 0

    readonly property int remainingTime: Number(pmSource.data["Battery"]["Remaining msec"])

    property bool powermanagementDisabled: false

    property var inhibitions: []

    readonly property var kcms: ["powerdevilprofilesconfig",
                                 "powerdevilactivitiesconfig",
                                 "powerdevilglobalconfig"]

    readonly property bool kcmsAuthorized: KAuthorized.authorizeControlModule(batterywidget.kcms).length > 0

    onScreenBrightnessChanged: {
        if (disableBrightnessUpdate) {
            return;
        }
        var service = pmSource.serviceForSource("PowerDevil");
        var operation = service.operationDescription("setBrightness");
        operation.brightness = screenBrightness;
        // show OSD only when the plasmoid isn't expanded since the moving slider is feedback enough
        operation.silent = plasmoid.expanded
        service.startOperationCall(operation);
    }

    onKeyboardBrightnessChanged: {
        if (disableBrightnessUpdate) {
            return;
        }
        var service = pmSource.serviceForSource("PowerDevil");
        var operation = service.operationDescription("setKeyboardBrightness");
        operation.brightness = keyboardBrightness;
        operation.silent = plasmoid.expanded
        service.startOperationCall(operation);
    }

    function action_powerdevilkcm() {
        KCMShell.open(batterywidget.kcms);
    }

    Component.onCompleted: {
        Logic.updateBrightness(batterywidget, pmSource);
        Logic.updateInhibitions(batterywidget, pmSource)

        if (batterywidget.kcmsAuthorized) {
            plasmoid.setAction("powerdevilkcm", i18n("&Configure Power Saving..."), "preferences-system-power-management");
        }
    }

    property QtObject batteries: KItemModels.KSortFilterProxyModel {
        id: batteries
        filterRoleName: "Is Power Supply"
        sortOrder: Qt.DescendingOrder
        sourceModel: KItemModels.KSortFilterProxyModel {
            sortRoleName: "Pretty Name"
            sortOrder: Qt.AscendingOrder
            sortCaseSensitivity: Qt.CaseInsensitive
            sourceModel: Plasma5Support.DataModel {
                dataSource: pmSource
                sourceFilter: "Battery[0-9]+"
            }
        }
    }

      // PlasmaCore.DataSource {
    property QtObject pmSource: Plasma5Support.DataSource {
            id: pmSource
            engine: "powermanagement"
            connectedSources: sources
            onSourceAdded: source => {
                  // console.log('onSourceAdded', source)
                  disconnectSource(source)
                  connectSource(source)
            }
            onSourceRemoved: {
                  disconnectSource(source)
            }

        onDataChanged: {
            Logic.updateBrightness(batterywidget, pmSource)
            Logic.updateInhibitions(batterywidget, pmSource)
        }

      }


    function getData(sourceName, key, def) {
        var source = pmSource.data[sourceName]
        if (typeof source === 'undefined') {
            return def;
        } else {
            var value = source[key]
            if (typeof value === 'undefined') {
                return def;
            } else {
                return value;
            }
        }
    }

      property string currentBatteryName: 'Battery'
      property string currentBatteryState: getData(currentBatteryName, 'State', false)
      property int currentBatteryPercent: getData(currentBatteryName, 'Percent', 100)
      property bool currentBatteryLowPower: currentBatteryPercent <= config.lowBatteryPercent
      property color currentTextColor: {
            if (currentBatteryLowPower) {
                  return config.lowBatteryColor
            } else {
                  return config.normalColor
            }
      }


      compactRepresentation: Item {
            id: panelItem

            anchors.fill: parent

            MouseArea {
                id: desktopMouseArea

                anchors.fill: parent

                onClicked:
                {
                    batterywidget.expanded = !batterywidget.expanded
                }
            }

                GridLayout {
                  id: gridLayout
                  // The rect around the Text items in the vertical layout should provide 2 pixels above
                  // and below. Adding extra space will make the space between the percentage and time left
                  // labels look bigger than the space between the icon and the percentage.
                  // So for vertical layouts, we'll add the spacing to just the icon.
                  property int spacing: 4
                  columnSpacing: spacing
                  rowSpacing: 0
                  anchors.fill: parent
                implicitWidth: parent.width
                implicitHeight: parent.height

                Component.onCompleted: () => console.log(gridLayout.implicitHeight, batteryIcon.implicitHeight)

                  PlasmaComponent.Label {
                        id: percentTextLeft
                        visible: plasmoid.configuration.showPercentage && !!plasmoid.configuration.alignLeft
                        
                        Layout.alignment: Qt.AlignLeft
                        Layout.rightMargin: config.padding
                        text: {
                              if (currentBatteryPercent >= 0) {
                                    return '' + currentBatteryPercent + '%'
                              } else {
                                    return '100%';
                              }
                        }
                        font.pixelSize: config.fontSize
                        fontSizeMode: Text.Fit
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: currentTextColor
                  }
                


                MacBatteryIcon {
                        id: batteryIcon
                        visible: plasmoid.configuration.showBatteryIcon
                        width: config.iconWidth
                        height: config.iconHeight
                        implicitWidth: config.iconWidth
                        implicitHeight: config.iconHeight
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        charging: currentBatteryState == "Charging"
                        charge: currentBatteryPercent
                        normalColor: config.normalColor
                        chargingColor: config.chargingColor
                        lowBatteryColor: config.lowBatteryColor
                        lowBatteryPercent: plasmoid.configuration.lowBatteryPercent

                }

                  PlasmaComponent.Label {
                        id: percentTextRight
                        visible: plasmoid.configuration.showPercentage && !plasmoid.configuration.alignLeft
                        Layout.alignment: Qt.AlignRight
                        Layout.leftMargin: config.padding
                        text: {
                              if (currentBatteryPercent >= 0) {
                                    return '' + currentBatteryPercent + '%'
                              } else {
                                    return '100%';
                              }
                        }
                        font.pixelSize: config.fontSize
                        fontSizeMode: Text.Fit
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: currentTextColor
                  }

                }

            Layout.minimumWidth: gridLayout.implicitWidth
            Layout.preferredWidth: gridLayout.implicitWidth

            Layout.minimumHeight: gridLayout.implicitHeight
            Layout.preferredHeight: gridLayout.implicitHeight
            
            // property int textHeight: Math.max(6, Math.min(panelItem.height, 16 * Kirigami.Units.gridUnit))
            property int textHeight: 12 * Kirigami.Units.gridUnit
            // onTextHeightChanged: console.log('textHeight', textHeight)


      }

    fullRepresentation: PopupDialog {
        id: dialogItem
        Layout.minimumWidth: Kirigami.Units.iconSizes.medium * 9
        Layout.minimumHeight: Kirigami.Units.gridUnit * 15
        // TODO Probably needs a sensible preferredHeight too

        model: plasmoid.expanded ? batteries : null
        anchors.fill: parent
        focus: true

        isBrightnessAvailable: pmSource.data["PowerDevil"] && pmSource.data["PowerDevil"]["Screen Brightness Available"] ? true : false
        isKeyboardBrightnessAvailable: pmSource.data["PowerDevil"] && pmSource.data["PowerDevil"]["Keyboard Brightness Available"] ? true : false

        pluggedIn: pmSource.data["AC Adapter"] != undefined && pmSource.data["AC Adapter"]["Plugged in"]

        property int cookie1: -1
        property int cookie2: -1
        onPowermanagementChanged: {
            var service = pmSource.serviceForSource("PowerDevil");
            if (checked) {
                var op1 = service.operationDescription("stopSuppressingSleep");
                op1.cookie = cookie1;
                var op2 = service.operationDescription("stopSuppressingScreenPowerManagement");
                op2.cookie = cookie2;

                var job1 = service.startOperationCall(op1);
                job1.finished.connect(function(job) {
                    cookie1 = -1;
                });

                var job2 = service.startOperationCall(op2);
                job2.finished.connect(function(job) {
                    cookie2 = -1;
                });
            } else {
                var reason = i18n("The battery applet has enabled system-wide inhibition");
                var op1 = service.operationDescription("beginSuppressingSleep");
                op1.reason = reason;
                var op2 = service.operationDescription("beginSuppressingScreenPowerManagement");
                op2.reason = reason;

                var job1 = service.startOperationCall(op1);
                job1.finished.connect(function(job) {
                    cookie1 = job.result;
                });

                var job2 = service.startOperationCall(op2);
                job2.finished.connect(function(job) {
                    cookie2 = job.result;
                });
            }

            batterywidget.powermanagementDisabled = !checked
        }
    }
}
