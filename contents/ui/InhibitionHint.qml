/*
 *   Copyright 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as Components
import org.kde.kirigami as Kirigami

RowLayout {
    property alias iconSource: iconItem.source
    property alias text: label.text

    spacing: Kirigami.Units.smallSpacing

    Kirigami.Icon {
        id: iconItem
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
        visible: valid
    }

    Components.Label {
        id: label
        Layout.fillWidth: true
        height: implicitHeight
        font.pointSize: Kirigami.Theme.smallFont.pointSize
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
        maximumLineCount: 3
    }
}