# Omarchy Sidra

A Sidra-specific Quickshell bar widget for Omarchy 4.0. It talks to
Sidra's bidirectional MPRIS service, `org.mpris.MediaPlayer2.sidra`, so it does
not take control of unrelated browsers or media players.

## Current scope

- Show a compact Sidra icon in the Omarchy bar.
- Click the icon to open a native Omarchy popover.
- Show album artwork, track, artist, and album information.
- Control play/pause, previous track, next track, and Sidra's software volume.
- Seek within the current track with elapsed and remaining time.
- Toggle shuffle and cycle repeat-off, repeat-track, and repeat-playlist modes.
- Click the artwork to focus or launch Sidra.
- Mute, open or copy the Apple Music track link, and stop playback.
- Use keyboard shortcuts while the popover is focused.
- Use Omaramp-style bar gestures: middle-click to play/pause, right-click to
  skip, and scroll to adjust volume.
- Cycle supported playback speeds from 0.5× to 2×.
- Search Apple Music by song, artist, or album and open a selection in Sidra.
- Choose a music, playback-state, animated equalizer, or album-art bar icon.
- Launch Sidra from the popover when it is not running.
- Support horizontal and vertical Omarchy bars.
- Follow the active Omarchy popup palette, typography, spacing, borders, and scale.

## Bar icon

Set `iconMode` on the widget's entry in `~/.config/omarchy/shell.json`:

```json
{
  "id": "sidra.controls",
    "iconMode": "auto"
}
```

Supported values are `auto` (default: artwork while playing, music icon
otherwise), `music`, `playback`, `equalizer`, and `artwork`.

## Keyboard controls

With the popover focused, use Space for play/pause, left/right to seek five
seconds, up/down to change volume, N/P for next/previous, M to mute, S to cycle
playback speed, and Escape to close.

On the bar icon, middle-click toggles playback, right-click skips to the next
track, and the mouse wheel changes Sidra's volume.

## Music picker

Choose **Pick music** in the popover and search for a song, artist, or album.
Selecting a result sends its Apple Music URL to Sidra through MPRIS. Search
uses Apple's public iTunes Search API and defaults to the Australian storefront.
Set `storefront` beside `iconMode` in `shell.json` to use another two-letter
country code.

## Install for development

From this repository:

```bash
./scripts/install-dev
```

This creates a symlink at
`~/.config/omarchy/plugins/sidra.controls`, rescans plugins, and enables the
widget. Omarchy shell plugins run unsandboxed as your user; inspect plugin code
before enabling it.

To remove the development link:

```bash
./scripts/uninstall-dev
```

For a future published Git repository, users will install with:

```bash
omarchy plugin add https://github.com/Neqael1/omarchy-sidra.git --enable
```

## Requirements

- Omarchy 4.0 or newer
- Quickshell 0.3 or newer
- [Sidra](https://github.com/wimpysworld/sidra)

## Roadmap

- Automated QML interaction tests and release packaging

## License

MIT
