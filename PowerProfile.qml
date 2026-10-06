import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "npittas.power-profile"
  ipcTarget: "npittas.power-profile"

  readonly property var profiles: PowerProfiles.hasPerformanceProfile
    ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
    : [PowerProfile.PowerSaver, PowerProfile.Balanced]
  readonly property int current: PowerProfiles.profile
  property int cursor: -1

  function icon(p) { return p === PowerProfile.Performance ? "󰓅" : p === PowerProfile.PowerSaver ? "󰾆" : "󰾅" }
  function label(p) { return p === PowerProfile.Performance ? "Performance" : p === PowerProfile.PowerSaver ? "Power Saver" : "Balanced" }

  function cycle(step) {
    var i = profiles.indexOf(current)
    PowerProfiles.profile = profiles[(i + step + profiles.length) % profiles.length]
  }

  function choose(p) {
    PowerProfiles.profile = p
    close()
  }

  onOpenedChanged: cursor = opened ? profiles.indexOf(current) : -1

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon(root.current)
    active: root.current === PowerProfile.Performance
    tooltipText: root.opened ? "" : "Power profile: " + root.label(root.current)
    onPressed: function(b) { if (b === Qt.RightButton) root.cycle(1); else root.toggle() }
    onWheelMoved: function(delta) { root.cycle(delta > 0 ? 1 : -1) }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(220))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        var d = dx !== 0 ? dx : dy
        root.cursor = Math.max(0, Math.min(root.profiles.length - 1, root.cursor + d))
      }
      onActivateRequested: if (root.cursor >= 0) root.choose(root.profiles[root.cursor])
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(6)

        PanelSectionHeader {
          text: "POWER PROFILE"
          foreground: root.bar.foreground
          fontFamily: root.bar.fontFamily
        }

        Repeater {
          model: root.profiles
          Button {
            required property var modelData
            required property int index
            width: column.width
            leftAlign: true
            iconText: root.icon(modelData)
            iconSize: Style.font.title
            text: root.label(modelData) + (root.current === modelData ? "  󰄬" : "")
            fontSize: Style.font.bodySmall
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
            verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
            bordered: true
            active: root.current === modelData
            hasCursor: root.cursor === index
            onClicked: root.choose(modelData)
            onHovered: function(h) { if (h) root.cursor = index }
          }
        }
      }
    }
  }
}
