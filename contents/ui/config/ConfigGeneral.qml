import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kcmutils as KCM


import ".."
import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	AppletConfig { id: config }

	ConfigSection {
		label: i18n("Mac Inline Battery")

		ConfigCheckBox {
			text: i18n("Enabled")
			configKey: 'showBatteryIcon'
		}

		RowLayout {
			ConfigSpinBox {
				before: i18n("Dimensions")
				suffix: 'px'
				configKey: 'iconWidth'
				value: config.iconWidth
				minimumValue: 0
				maximumValue: 100
			}
			Label {
				text: "x"
			}
			ConfigSpinBox {
				suffix: 'px'
				configKey: 'iconHeight'
				value: config.iconHeight
				minimumValue: 0
				maximumValue: 100
			}
		}

		ConfigColor {
			label: i18n("Normal")
			configKey: 'normalColor'
			defaultColor: config.defaultNormalColor
		}

		ConfigColor {
			label: i18n("Charging")
			configKey: 'chargingColor'
			defaultColor: config.defaultChargingColor
		}
		RowLayout {
			ConfigSpinBox {
				before: i18n("Low Battery")
				suffix: '%'
				configKey: 'lowBatteryPercent'
				minimumValue: 0
				maximumValue: 100
			}
			ConfigColor {
				label: ''
				configKey: 'lowBatteryColor'
				defaultColor: config.defaultLowBatteryColor
			}
		}
	}
	ConfigSection {
		label: i18n("Percentage")

		ConfigCheckBox {
			id: percentageCheckbox
			text: i18n("Enabled")
			configKey: 'showPercentage'
		}

		Label {
			text: i18n("Position relative to battery icon")
		}

		RowLayout {
			RadioButton {
				text: i18n("Left")
				autoExclusive: true
				checked: plasmoid.configuration.alignLeft
				enabled: plasmoid.configuration.showPercentage
				onClicked: plasmoid.configuration.alignLeft = true
			}
			RadioButton {
				text: i18n("Right")
				autoExclusive: true
				checked: !plasmoid.configuration.alignLeft
				enabled: plasmoid.configuration.showPercentage
				onClicked: plasmoid.configuration.alignLeft = false
			}
		}
		ConfigSpinBox {
			before: i18n("Padding")
			suffix: 'px'
			enabled: plasmoid.configuration.showPercentage
			configKey: 'padding'
			value: config.padding
			minimumValue: 0
			maximumValue: 100
		}
	}

	ConfigSection {
		label: i18n("Font")

		ConfigSpinBox {
			before: i18n("Font Size")
			suffix: 'px'
			configKey: 'fontSize'
			value: config.fontSize
			minimumValue: 0
			maximumValue: 100
		}
	}
}
