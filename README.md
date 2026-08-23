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
- Choose a music, playback-state, or album-art bar icon.
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
otherwise), `music`, `playback`, and `artwork`.

## Keyboard controls

With the popover focused, use Space for play/pause, left/right to seek five
seconds, up/down to change volume, N/P for next/previous, and Escape to close.

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
omarchy plugin add https://github.com/OWNER/omarchy-sidra.git --enable
```

## Requirements

- Omarchy 4.0 or newer
- Quickshell 0.3 or newer
- [Sidra](https://github.com/wimpysworld/sidra)

## Roadmap

- Automated QML interaction tests and release packaging

## License

MIT
