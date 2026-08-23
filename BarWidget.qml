import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "sidra.controls"

  readonly property string sidraBusName: "org.mpris.MediaPlayer2.sidra"
  readonly property var players: Mpris.players ? Mpris.players.values : []
  readonly property var player: findSidraPlayer()
  readonly property string title: player ? (player.trackTitle || "Nothing playing") : "Sidra is not running"
  readonly property string artist: player ? (player.trackArtist || "") : ""
  readonly property string album: player ? (player.trackAlbum || "") : ""
  readonly property string artwork: player ? (player.trackArtUrl || "") : ""
  readonly property string trackUrl: player && player.metadata
    ? String(player.metadata["xesam:url"] || "") : ""
  readonly property color popupForeground: Color.popups.text
  readonly property string iconMode: String(setting("iconMode", "auto"))
  readonly property bool useArtworkIcon: artwork !== ""
    && ((iconMode === "auto" && player && player.isPlaying) || iconMode === "artwork")
  property bool popupOpen: false
  property string actionMessage: ""

  function findSidraPlayer() {
    for (var i = 0; i < players.length; i++) {
      var candidate = players[i]
      if (candidate && String(candidate.dbusName || "") === sidraBusName) return candidate
    }
    return null
  }

  function close() { popupOpen = false }
  function launch() { if (bar) bar.run("sidra") }
  function focusSidra() {
    if (!player) launch()
    else if (player.canRaise) player.raise()
    else launch()
  }

  function playPause() {
    if (!player) launch()
    else if (player.isPlaying && player.canPause) player.pause()
    else if (!player.isPlaying && player.canPlay) player.play()
    else if (player.canTogglePlaying) player.togglePlaying()
  }

  function next() {
    if (player && player.canGoNext) { player.next(); notifyAction("Loading next track…") }
  }
  function previous() {
    if (player && player.canGoPrevious) { player.previous(); notifyAction("Loading previous track…") }
  }
  function stop() { if (player) player.stop() }
  function seekBy(offset) { if (player && player.canSeek) player.seek(offset) }
  function seek(position) {
    if (player && player.canSeek && player.positionSupported)
      player.position = Math.max(0, Math.min(player.length, position))
  }

  function formatTime(seconds) {
    var value = Math.max(0, Math.floor(Number(seconds) || 0))
    var minutes = Math.floor(value / 60)
    var remainder = value % 60
    return minutes + ":" + (remainder < 10 ? "0" : "") + remainder
  }

  function setVolume(value) {
    if (player && player.volumeSupported) player.volume = Math.max(0, Math.min(1, value))
  }

  function toggleMute() {
    if (!player || !player.volumeSupported) return
    if (player.volume > 0.001) {
      previousVolume = player.volume
      setVolume(0)
    } else {
      setVolume(previousVolume > 0.001 ? previousVolume : 0.5)
    }
  }

  function cycleRepeat() {
    if (player && player.loopSupported) player.loopState = (Number(player.loopState) + 1) % 3
  }

  function toggleShuffle() {
    if (player && player.shuffleSupported) player.shuffle = !player.shuffle
  }

  function repeatLabel() {
    if (!player) return "Repeat"
    if (Number(player.loopState) === 1) return "Repeat track"
    if (Number(player.loopState) === 2) return "Repeat playlist"
    return "Repeat off"
  }

  function repeatIcon() { return player && Number(player.loopState) === 1 ? "󰑘" : "󰑖" }

  function notifyAction(message) {
    actionMessage = message
    actionMessageTimer.restart()
  }

  function copyTrackLink() {
    if (!trackUrl) return
    Quickshell.execDetached(["wl-copy", trackUrl])
    notifyAction("Track link copied")
  }

  function openTrackLink() {
    if (trackUrl) Quickshell.execDetached(["xdg-open", trackUrl])
  }

  property real previousVolume: 0.5

  Timer {
    id: actionMessageTimer
    interval: 1800
    onTriggered: root.actionMessage = ""
  }

  FrameAnimation {
    running: root.popupOpen && root.player && root.player.isPlaying
      && root.player.positionSupported
    onTriggered: root.player.positionChanged()
  }

  implicitWidth: iconButton.implicitWidth
  implicitHeight: iconButton.implicitHeight

  WidgetButton {
    id: iconButton
    anchors.fill: parent
    bar: root.bar
    text: root.useArtworkIcon ? ""
      : root.iconMode === "playback" ? (root.player && root.player.isPlaying ? "󰏤" : "󰐊")
      : "󰎆"
    labelVisible: !root.useArtworkIcon
    hasVisualContent: true
    active: root.player && root.player.isPlaying
    dimmed: !root.player
    tooltipText: root.player
      ? root.title + (root.artist ? " — " + root.artist : "")
      : "Sidra"
    onPressed: root.popupOpen = !root.popupOpen

    Image {
      id: barArtwork
      anchors.centerIn: parent
      width: Math.min(parent.width - Style.space(8), Style.bar.iconSlot)
      height: width
      source: root.artwork
      asynchronous: true
      fillMode: Image.PreserveAspectCrop
      visible: root.useArtworkIcon && status === Image.Ready
    }

    Text {
      anchors.centerIn: parent
      text: "󰎆"
      color: root.bar ? root.bar.barForeground : Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.icon
      visible: root.useArtworkIcon && barArtwork.status !== Image.Ready
    }
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: fittedContentWidth(Style.space(340))
    contentHeight: fittedContentHeight(content.implicitHeight)

    Column {
      id: content
      anchors.fill: parent
      spacing: Style.space(14)
      focus: root.popupOpen

      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) root.close()
        else if (event.key === Qt.Key_Space) root.playPause()
        else if (event.key === Qt.Key_Left) root.seekBy(-5)
        else if (event.key === Qt.Key_Right) root.seekBy(5)
        else if (event.key === Qt.Key_Up) root.setVolume((root.player ? root.player.volume : 0) + 0.05)
        else if (event.key === Qt.Key_Down) root.setVolume((root.player ? root.player.volume : 0) - 0.05)
        else if (event.key === Qt.Key_N) root.next()
        else if (event.key === Qt.Key_P) root.previous()
        else return
        event.accepted = true
      }

      Row {
        width: parent.width
        spacing: Style.space(12)

        BorderSurface {
          width: Style.space(96)
          height: Style.space(96)
          radius: Style.cornerRadius
          color: Style.normalFillFor(root.popupForeground, Color.accent)
          borderSpec: Border.controlSpec("normal", root.popupForeground, Color.accent)

          Image {
            id: popupArtwork
            anchors.fill: parent
            anchors.margins: Style.space(2)
            source: root.artwork
            asynchronous: true
            cache: true
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
          }

          Text {
            anchors.centerIn: parent
            text: "󰎆"
            color: root.popupForeground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.displayLarge
            visible: popupArtwork.status !== Image.Ready
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.focusSidra()
          }
        }

        Column {
          width: parent.width - Style.space(108)
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(4)

          Text {
            width: parent.width
            text: root.title
            color: root.popupForeground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.subtitle
            font.bold: true
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.Wrap
          }

          Text {
            width: parent.width
            text: root.artist
            color: root.popupForeground
            opacity: 0.76
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            elide: Text.ElideRight
            visible: text !== ""
          }

          Text {
            width: parent.width
            text: root.album
            color: root.popupForeground
            opacity: 0.56
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
            visible: text !== ""
          }
        }
      }

      Column {
        width: parent.width
        spacing: Style.space(3)
        visible: root.player && root.player.canSeek
          && root.player.positionSupported && root.player.lengthSupported
          && root.player.length > 0

        PanelSlider {
          id: seekSlider
          width: parent.width
          bar: root.bar
          minimum: 0
          maximum: root.player && root.player.lengthSupported ? root.player.length : 1
          value: root.player && root.player.positionSupported ? root.player.position : 0
          step: 5
          onReleased: function(value) { root.seek(value) }

          Controls.ToolTip {
            visible: seekSlider.dragging
            text: root.formatTime(seekSlider.liveValue)
            x: Math.max(0, Math.min(seekSlider.width - implicitWidth,
              seekSlider.width * (seekSlider.liveValue / Math.max(1, seekSlider.maximum)) - implicitWidth / 2))
            y: -implicitHeight - Style.space(3)
          }
        }

        Row {
          width: parent.width

          Text {
            id: elapsedLabel
            text: root.formatTime(seekSlider.dragging ? seekSlider.liveValue : seekSlider.value)
            color: root.popupForeground
            opacity: 0.65
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.caption
          }

          Item { width: parent.width - elapsedLabel.implicitWidth - remainingText.implicitWidth }

          Text {
            id: remainingText
            text: "−" + root.formatTime(Math.max(0, seekSlider.maximum
              - (seekSlider.dragging ? seekSlider.liveValue : seekSlider.value)))
            color: root.popupForeground
            opacity: 0.65
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.caption
          }
        }
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.space(8)

        Button {
          iconText: "󰒝"
          foreground: root.popupForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          enabled: root.player && root.player.shuffleSupported
          selected: root.player && root.player.shuffle
          opacity: enabled ? 1 : 0.35
          tooltipText: root.player && root.player.shuffle ? "Shuffle on" : "Shuffle off"
          onClicked: root.toggleShuffle()
        }

        Button {
          iconText: "󰒮"
          foreground: root.popupForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          enabled: root.player && root.player.canGoPrevious
          opacity: enabled ? 1 : 0.35
          tooltipText: "Previous"
          onClicked: root.previous()
        }

        Button {
          iconText: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
          foreground: root.popupForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          iconSize: Style.font.iconLarge
          horizontalPadding: Style.spacing.panelGap
          enabled: !root.player || root.player.canTogglePlaying || root.player.canPlay || root.player.canPause
          tooltipText: root.player ? (root.player.isPlaying ? "Pause" : "Play") : "Launch Sidra"
          onClicked: root.playPause()
        }

        Button {
          iconText: "󰒭"
          foreground: root.popupForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          enabled: root.player && root.player.canGoNext
          opacity: enabled ? 1 : 0.35
          tooltipText: "Next"
          onClicked: root.next()
        }

        Button {
          iconText: root.repeatIcon()
          foreground: root.popupForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          enabled: root.player && root.player.loopSupported
          selected: root.player && Number(root.player.loopState) !== 0
          opacity: enabled ? 1 : 0.35
          tooltipText: root.repeatLabel()
          onClicked: root.cycleRepeat()
        }
      }

      PanelSeparator { foreground: root.popupForeground }

      Row {
        width: parent.width
        height: volumeSlider.implicitHeight
        spacing: Style.space(10)
        visible: root.player && root.player.volumeSupported

        Text {
          width: Style.space(22)
          anchors.verticalCenter: parent.verticalCenter
          text: volumeSlider.liveValue <= 0.01 ? "󰖁" : "󰕾"
          color: root.popupForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.heading
          horizontalAlignment: Text.AlignHCenter

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleMute()
          }
        }

        PanelSlider {
          id: volumeSlider
          width: parent.width - Style.space(78)
          anchors.verticalCenter: parent.verticalCenter
          bar: root.bar
          value: root.player && root.player.volumeSupported ? root.player.volume : 0
          step: 0.05
          onMoved: function(value) { root.setVolume(value) }
        }

        Text {
          width: Style.space(36)
          anchors.verticalCenter: parent.verticalCenter
          text: Math.round(volumeSlider.liveValue * 100) + "%"
          color: root.popupForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.bodySmall
          horizontalAlignment: Text.AlignRight
        }
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.space(6)

        Button {
          iconText: "󰍹"
          text: "Open Sidra"
          foreground: root.popupForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          onClicked: root.focusSidra()
        }

        Button {
          iconText: "󰌷"
          foreground: root.popupForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          enabled: root.trackUrl !== ""
          opacity: enabled ? 1 : 0.35
          tooltipText: "Open track in Apple Music"
          onClicked: root.openTrackLink()
        }

        Button {
          iconText: "󰆏"
          foreground: root.popupForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          enabled: root.trackUrl !== ""
          opacity: enabled ? 1 : 0.35
          tooltipText: "Copy track link"
          onClicked: root.copyTrackLink()
        }

        Button {
          iconText: "󰓛"
          foreground: root.popupForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          enabled: root.player !== null
          opacity: enabled ? 1 : 0.35
          tooltipText: "Stop playback"
          onClicked: root.stop()
        }
      }

      Text {
        width: parent.width
        text: root.actionMessage !== "" ? root.actionMessage
          : !root.player ? "Sidra is not running — press Space to launch"
          : root.player.trackTitle === "" ? "Waiting for track information…"
          : "Space play/pause · ←/→ seek · ↑/↓ volume · N/P tracks"
        color: root.popupForeground
        opacity: root.actionMessage !== "" ? 0.9 : 0.5
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.caption
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
      }
    }
  }
}
