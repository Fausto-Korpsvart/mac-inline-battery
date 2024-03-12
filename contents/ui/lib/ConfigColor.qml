import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami

import ".."

RowLayout {
	id: configColor
	spacing: 2
	// Layout.fillWidth: true
	Layout.maximumWidth: 300

	property alias label: label.text
	property alias horizontalAlignment: label.horizontalAlignment

	property string configKey: ''
	property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	property string defaultColor: ''
	readonly property color value: configValue || defaultColor
	onConfigValueChanged: {
		if (!textField.activeFocus) {
			textField.text = configColor.configValue
		}
		if (configKey) {
			plasmoid.configuration[configKey] = configValue
		}
	}

	Label {
		id: label
		text: "Label"
		Layout.fillWidth: horizontalAlignment == Text.AlignRight
		horizontalAlignment: Text.AlignLeft
	}

	MouseArea {
		// width: label.font.pixelSize
		// height: label.font.pixelSize
		width: textField.height
		height: textField.height
		hoverEnabled: true

		onClicked: dialog.open()

		Rectangle {
			anchors.fill: parent
			color: configColor.value
			border.width: 2
			border.color: parent.containsMouse ? Kirigami.Theme.highlightColor : "#BB000000"
		}
	}

	TextField {
		id: textField
		placeholderText: "#AARRGGBB"
		Layout.fillWidth: label.horizontalAlignment == Text.AlignLeft
		onTextChanged: {
			// Make sure the text is:
			//   Empty (use default)
			//   or #123 or #112233 or #11223344 before applying the color.
			if (text.length === 0
				|| (text.indexOf('#') === 0 && (text.length == 4 || text.length == 7 || text.length == 9))
			) {
				configColor.configValue = text
			}
		}
	}

	ColorDialog {
		id: dialog
		visible: false
		modality: Qt.WindowModal
		title: configColor.label
		selectedColor: configColor.value

		Connections {

			function onCurrentColorChanged(color) {
				if (visible && color != currentColor) {
					configColor.configValue = currentColor
				}
			}
		}
	}
}
