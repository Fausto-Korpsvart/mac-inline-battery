import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import ".."

CheckBox {
	id: configCheckBox

	property string configKey: ''
	checked: configKey ? plasmoid.configuration[configKey] : false
	onClicked: plasmoid.configuration[configKey] = !plasmoid.configuration[configKey]
}
