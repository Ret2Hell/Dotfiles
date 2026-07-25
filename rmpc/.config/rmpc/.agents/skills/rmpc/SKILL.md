---
name: rmpc-configuration
description: >
  Configure and theme RMPC v0.11.0. Use for requests involving RMPC, MPD connection
  settings, ~/.config/rmpc/config.ron, ~/.config/rmpc/theme.ron, RMPC layouts, tabs,
  panes, components, properties, colors, keybindings, album art, lyrics, Cava,
  search, song tables, hooks, or troubleshooting RMPC configuration.
---

# RMPC v0.11.0 Configuration

Configure the installed RMPC v0.11.0 client accurately and conservatively. Both configuration files use [RON](https://github.com/ron-rs/ron). This skill is version-locked to the [RMPC v0.11.0 documentation](https://rmpc.mierak.dev/0.11.0/); do not silently apply options from newer documentation.

## Scope and Files

The normal local files are:

```text
~/.config/rmpc/
├── config.ron       # MPD connection, behavior, keybindings, search, tabs, integrations
├── theme.ron        # Colors, styles, formats, base layout, reusable components
└── themes/          # Optional named themes
    └── mytheme.ron
```

RMPC resolves the main config from `$XDG_CONFIG_HOME/rmpc/config.ron`, then `$HOME/.config/rmpc/config.ron`, unless `--config`/`-c` supplies another path.

When `theme: "mytheme"` is configured, theme lookup checks the config directory in this order:

1. `themes/mytheme.ron`
2. `themes/mytheme`
3. `mytheme.ron`
4. `mytheme`
5. The path/name as supplied

An explicit `--theme`/`-t` path overrides theme resolution.

## Mandatory Working Rules

1. Confirm the installed version with `rmpc version`; this skill targets `0.11.0`.
2. Read the complete current files before editing. Preserve user customizations and make the smallest correct change.
3. Keep `tabs` in `config.ron`. Keep `layout`, `components`, palette, symbols, and display formats in the theme.
4. Preserve these generated RON directives when present:

   ```ron
   #![enable(implicit_some)]
   #![enable(unwrap_newtypes)]
   #![enable(unwrap_variant_newtypes)]
   ```

5. Preserve exact enum capitalization, commas, parentheses, and string quoting. RON is not JSON.
6. Prefer the output of the installed `rmpc config` and `rmpc theme` over gallery snippets or prose when sources disagree.
7. Never overwrite an existing file with generated defaults. Generate to a temporary path or inspect stdout first.
8. Do not expose MPD passwords in responses, logs, examples based on the user's file, or commits.
9. Do not add compatibility options for newer or older RMPC releases unless explicitly requested.
10. Validate by loading the edited files because v0.11.0 has no dedicated config validator.

## Standard Workflow

### Inspect

```bash
rmpc version
rmpc --help
rmpc debuginfo
```

Read `config.ron` and the active theme. Determine whether the theme is a local filename, a named file under `themes/`, or an explicit CLI path. Inspect MPD and terminal capabilities only when relevant.

### Bootstrap safely

The installed binary can emit complete defaults:

```bash
rmpc config
rmpc theme
```

For a new installation, typical redirection is:

```bash
rmpc config > ~/.config/rmpc/config.ron
rmpc theme > ~/.config/rmpc/themes/mytheme.ron
```

Only use those redirections when the destination does not already exist or the user explicitly requests replacement.

### Edit

Change one conceptual area at a time. For a visual redesign, work in this order:

1. Palette and styles.
2. Symbols, progress bar, scrollbar, and border symbols.
3. Browser and song-table formatting.
4. Reusable components.
5. Base theme layout.
6. Config tabs.
7. Optional AlbumArt, Lyrics, or Cava integrations.

### Validate and apply

Use explicit paths to avoid resolution ambiguity:

```bash
rmpc --config ~/.config/rmpc/config.ron --theme ~/.config/rmpc/theme.ron
```

Most edits hot reload when `enable_config_hot_reload: true`. Restart RMPC after MPD connection changes or an album-art method change. A running instance can switch theme with:

```bash
rmpc remote --pid "$PID" set theme ~/.config/rmpc/theme.ron
```

For related diagnostics:

```bash
rmpc debuginfo
rmpc lyricsindex
rmpc <subcommand> --help
```

## Main Config Reference

### Connection and precedence

`address` accepts TCP (`"127.0.0.1:6600"`), Unix socket (`"/path/to/socket"`), or Linux abstract socket (`"@name"`). `password` is `None` or a string.

Connection precedence is:

1. `--address` and `--password`
2. `$MPD_HOST` and `$MPD_PORT`
3. `address` and `password` in `config.ron`
4. `127.0.0.1:6600`

Address and password cannot be mixed from different precedence levels. `$MPD_HOST` can contain `password@host`; an abstract socket with password is `password@@socket`. If `$MPD_PORT` is omitted, an IP uses port 6600 while a host beginning with `/` or `~` is a Unix socket.

Timeouts, when present:

- `mpd_read_timeout_ms`: normal response timeout, default 10,000 ms.
- `mpd_write_timeout_ms`: write timeout, default 5,000 ms.
- `mpd_idle_read_timeout_ms`: optional idle timeout. Leave `None` unless diagnosing hangs after disconnects.

### General behavior

Important top-level options include:

| Option | Purpose / values |
|---|---|
| `theme` | `None` or theme name/path |
| `cache_dir` | Download/cache directory; required for YouTube playback |
| `lyrics_dir` | Client-side LRC root |
| `volume_step` | Volume percentage step; default `5` |
| `max_fps` | Render batching cap; default `30` |
| `scrolloff` | Rows retained around cursor; default `0` |
| `wrap_navigation` | Wrap top/bottom navigation; default `false` |
| `enable_mouse` | Mouse controls; default `true` |
| `scroll_amount` | Wheel lines per step; default `1` |
| `enable_config_hot_reload` | Watch config directory; default `true` |
| `status_update_interval_ms` | Progress/bitrate refresh; default `1000` |
| `rewind_to_start_sec` | PreviousTrack restart threshold or `None` |
| `keep_state_on_song_change` | Preserve paused/playing state; default `true` |
| `select_current_song_on_change` | Select new current Queue song; default `false` |
| `center_current_song_on_change` | Center it; requires selection option |
| `reflect_changes_to_playlist` | Mirror Queue into last loaded playlist; MPD 0.24+ |
| `normal_timeout_ms` | Ambiguous normal key sequence timeout; default `1000` |
| `insert_timeout_ms` | Ambiguous insert sequence timeout; default `1000` |
| `auto_open_downloads` | Open download modal automatically; default `true` |

Treat `reflect_changes_to_playlist` as destructive: MPD remembers the loaded playlist until the Queue is completely cleared, so Queue edits can overwrite an unexpected playlist.

`duration_format` supports `%d`, `%D`, `%h`, `%H`, `%m`, `%M`, `%s`, `%S`, `%t`, and `%%`. Invalid tokens or a trailing `%` are parse errors.

### Hooks

`on_song_change` and `on_resize` are executable arrays, not shell strings:

```ron
on_song_change: ["/path/to/script", "arg"],
on_resize: ["/path/to/script"],
```

The first value is the executable. Song hooks receive metadata variables such as `$ARTIST`, `$TITLE`, `$FILE`, `$DURATION`, plus `$VERSION`, `$PID`, `$LRC_FILE`, `$HAS_LRC`, `$PREV_SONG`, and `$PREV_ELAPSED`. `exec_on_song_change_at_start` controls startup execution. Resize hooks also receive `$COLS` and `$ROWS`.

### Browser, artists, and search

Browser controls include:

- `ignore_leading_the`: ignore leading “The” while sorting.
- `browser_song_sort`: ordered song properties, commonly `[Disc, Track, Artist, Title]`.
- `directories_sort`: `Format(...)`, `SortFormat(...)`, or `ModifiedTime(...)`, each with `group_by_type` and `reverse`.
- `show_playlists_in_browser`: `All`, `None`, or `NonRoot`.

Artist configuration:

```ron
artists: (
    album_display_mode: SplitByDate, // or NameOnly
    album_sort_by: Date,             // or Name
    album_date_tags: [Date],         // Date and/or OriginalDate
),
```

Search configuration:

```ron
search: (
    case_sensitive: false,
    ignore_diacritics: false,
    search_button: false,
    custom_query: false,
    mode: Contains,
    tags: [(value: "any", label: "Any Tag")],
),
```

Modes are `Exact`, `NotExact`, `StartsWith`, `Contains`, `Regex`, and `NotRegex`. `case_sensitive` and `ignore_diacritics` cannot both be true. Diacritic ignoring requires MPD 0.25+. `custom_query` exposes raw MPD filter syntax and malformed filters produce MPD errors.

## Tabs and Pane Trees

Tabs belong to `config.ron`:

```ron
tabs: [
    (name: "Queue", pane: Pane(Queue)),
    (
        name: "Library",
        pane: Split(
            direction: Horizontal,
            panes: [
                (size: "40%", pane: Pane(Artists)),
                (size: "60%", pane: Pane(Albums)),
            ],
        ),
    ),
],
```

A node is `Pane(...)`, `Split(...)`, or `Component("name")`. Splits use `Horizontal` or `Vertical`. Child size syntax is:

- `"5"`: exact cells.
- `"40%"`: percentage of parent in the split direction.
- `"0.4r"`: ratio to the parent's opposite dimension, useful for square art.

Exact sizes include borders. A two-row pane with top and bottom borders needs four cells.

Available panes include `AlbumArt`, `Cava`, `Queue`, `QueueHeader()`, `Directories`, `Browser(root_tag: "...", separator: "...")`, `Artists`, `AlbumArtists`, `Albums`, `Playlists`, `Search`, `Lyrics`, `ProgressBar`, `Tabs`, `Property(...)`, `Volume(...)`, and `Empty()`.

`Artists` is effectively `Browser(root_tag: "artist")`; `AlbumArtists` uses `albumartist`. A custom browser can use another MPD tag, such as `Pane(Browser(root_tag: "genre", separator: ";"))`.

Split children can also set `background_color`, `borders`, `border_style`, `border_active_style`, `border_title`, `border_title_position`, `border_title_alignment`, and `border_symbols`.

Borders combine `NONE`, `ALL`, `LEFT`, `RIGHT`, `TOP`, and `BOTTOM`, for example `"LEFT | RIGHT"`. Titles align `Left`, `Center`, or `Right` and sit at `Top` or `Bottom`.

Border symbols support `Plain`, `Rounded`, `Double`, `Thick`, `Empty`, `Full`, `ProportionalWide`, `ProportionalTall`, `OneEighthWide`, `OneEighthTall`, `Custom(...)`, `Inherited(...)`, and `Library("name")`.

## Theme Reference

### Base layout invariant

The theme's `layout` wraps the active tab. It must contain exactly one `Pane(TabContent)`, unless the entire layout is simply `Pane(TabContent)`.

Only non-focusable panes belong directly in the base layout: `AlbumArt`, `Lyrics`, `ProgressBar`, `Header`, `Tabs`, and `Cava`. A pane instance cannot be used both in the base layout and tabs. Components may be referenced from either place:

```ron
layout: Split(
    direction: Vertical,
    panes: [
        (size: "3", pane: Component("header")),
        (size: "2", pane: Pane(Tabs)),
        (size: "100%", pane: Pane(TabContent)),
        (size: "1", pane: Pane(ProgressBar)),
    ],
),
components: {
    "header": Pane(Property(
        content: [(kind: Property(Song(Title)), default: (kind: Text("No Song")))],
        align: Center,
    )),
},
```

### Colors and styles

A style has optional foreground, background, and modifiers:

```ron
(fg: "#89b4fa", bg: "#1e1e2e", modifiers: "Bold")
```

Named colors are `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `gray`, `dark_gray`, `light_red`, `light_green`, `light_yellow`, `light_blue`, `light_magenta`, `light_cyan`, and `white`. Also use hex (`"#ff0000"`), RGB (`"rgb(255, 0, 0)"`), or indexed colors (`"17"`). True color depends on terminal support.

Modifiers are `Bold`, `Dim`, `Italic`, `Underlined`, `Reversed`, and `CrossedOut`.

Core theme style fields:

- `background_color`, `header_background_color`, `modal_background_color`, `modal_backdrop`, `text_color`
- `preview_label_style`, `preview_metadata_group_style`
- `highlighted_item_style`, `current_item_style`
- `borders_style`, `highlight_border_style`
- `tab_bar: (active_style: ..., inactive_style: ...)`
- `level_styles: (info: ..., warn: ..., error: ..., debug: ..., trace: ...)`

Do not use deprecated `tab_bar.enabled`; add or remove `Pane(Tabs)` in the layout.

### Symbols, progress, and scrollbar

```ron
symbols: (
    song: "S", dir: "D", playlist: "P", marker: "M", ellipsis: "...",
    song_style: None, dir_style: None, playlist_style: None,
),
progress_bar: (
    symbols: ["█", "█", "█", " ", "█"],
    track_style: None,
    elapsed_style: (fg: "blue"),
    thumb_style: (fg: "blue"),
    use_track_when_empty: true,
),
scrollbar: (
    symbols: ["│", "█", "▲", "▼"],
    track_style: (), ends_style: (), thumb_style: (fg: "blue"),
),
```

Progress symbols are start, elapsed, thumb, track, end. Scrollbar symbols are track, thumb, top, bottom. Set `scrollbar: None` to hide it.

### Property language

Properties drive Property panes, border titles, browser formatting, and song-table columns:

```ron
(
    kind: Property(Song(Title)),
    style: (modifiers: "Bold"),
    default: (kind: Property(Song(Filename))),
)
```

Generic kinds are `Text("...")`, `Sticker("name")`, `Group([...])`, `Transform(...)`, and `Property(...)`. A `Group` disappears when any member is empty, which prevents orphan punctuation. `default` recursively supplies fallback content.

Song properties include `File`, `Filename`, `FileExtension`, `Title`, `Artist`, `Album`, `Duration`, `Track`, `Disc`, `Position`, `SampleRate()`, `Bits()`, `Channels()`, `Added()`, `LastModified()`, and `Other("tag")`.

In a general Property pane, wrap song values as `Property(Song(Title))`. In `song_table_format` and `browser_song_format`, omit the category wrapper: `Property(Title)`.

Status properties include `Volume`, `StateV2(...)`, `RepeatV2(...)`, `RandomV2(...)`, `SingleV2(...)`, `ConsumeV2(...)`, `Partition`, `Elapsed`, `Duration`, `Crossfade`, `Bitrate`, `QueueLength(...)`, `QueueTimeTotal(...)`, `QueueTimeRemaining(...)`, `ActiveTab`, `InputBuffer()`, `InputMode()`, `SampleRate()`, `Bits()`, and `Channels()`.

Transforms are:

```ron
Transform(Truncate(content: <property>, length: 20, from_start: false))
Transform(Replace(content: <property>, replacements: [
    (match: "Normal", replace: (kind: Text(" NORMAL "))),
]))
```

### Property and volume panes

```ron
Pane(Property(
    content: [(kind: Property(Song(Title)))],
    align: Center,
    scroll_speed: 1,
))
```

`align` is `Left`, `Center`, or `Right`. `scroll_speed` is columns per second; omit it or use zero to disable scrolling.

Volume currently supports `Slider`:

```ron
Pane(Volume(kind: Slider(
    symbols: (start: "♪", filled: "─", thumb: "●", track: "─", end: "♫"),
    track_style: (fg: "gray"),
    filled_style: (fg: "green"),
    thumb_style: (fg: "white"),
)))
```

### Browser and queue formats

`browser_column_widths` contains percentages for the three browser columns. `format_tag_separator` joins multiple tag values. `multiple_tag_resolution_strategy` is `All`, `First`, `Last`, or `Nth(n)`.

`browser_song_format` is a property list; styles are ignored. Use grouped optional prefixes and a filename fallback.

`song_table_format` is a column list:

```ron
song_table_format: [
    (
        prop: (kind: Property(Artist), default: (kind: Text("Unknown"))),
        label_prop: (kind: Text("Artist")),
        width: "40%",
        alignment: Left,
    ),
    (
        prop: (kind: Property(Duration)),
        label: "Time",
        width: "20%",
        alignment: Right,
    ),
],
```

Widths are exact cells or percentages; percentage columns should total 100%. Alignment is `Left`, `Center`, or `Right`. `label` is shorthand for a text `label_prop`; headers are displayed by `QueueHeader()`. `song_table_album_separator` is `None` or `Underline`.

## Keybindings

```ron
keybinds: (
    clear: false,
    global: { "q": Quit, "p": TogglePause },
    navigation: { "j": Down, "k": Up, "<CR>": Confirm },
    queue: { "d": Delete, "<CR>": Play },
),
```

With `clear: false`, defaults remain and entries override or extend them. With `clear: true`, all defaults are removed.

Syntax includes lowercase (`"a"`), uppercase (`"A"`), control (`"<C-a>"`), alt (`"<A-x>"`), special keys (`"<Tab>"`), and sequences (`"gg"`, `"<C-a>r"`). Ambiguous prefixes wait for `normal_timeout_ms` or `insert_timeout_ms`. Kitty keyboard-protocol combinations require a compatible terminal and do not work through tmux.

Main maps:

- `global`: app, playback, volume, seeking, tabs, MPD maintenance, outputs, downloads, partitions, and external commands.
- `navigation`: movement, pane focus, selection, search, add/delete/rename, info, context menus, save, and ratings.
- `queue`: delete, clear, play, current-song jump, shuffle, and sort.

An `ExternalCommand` is an executable array plus help description. It receives `$CURRENT_SONG`, `$STATE`, song metadata, and newline-separated `$SELECTED_SONGS`. Do not wrap shell syntax in one string; explicitly invoke a shell only when shell interpretation is genuinely required.

All configured bindings can also be invoked with `rmpc remote keybind "<keys>"`. Use the default `?` binding to inspect effective bindings.

## Album Art

```ron
album_art: (
    method: Auto,
    order: EmbeddedFirst,
    max_size_px: (width: 1200, height: 1200),
    disabled_protocols: ["http://", "https://"],
    vertical_align: Center,
    horizontal_align: Center,
),
```

Methods are `Kitty`, `Iterm2`, `Sixel`, `UeberzugWayland`, `UeberzugX11`, `Block`, `None`, and `Auto`. Orders are `EmbeddedFirst`, `FileFirst`, `EmbeddedOnly`, and `FileOnly`.

RMPC looks for embedded art and `cover.png`, `cover.jpg`, or `cover.webp` beside the song. The theme can define `default_album_art_path`.

Backend guidance:

- Kitty and Ghostty: `Kitty`.
- WezTerm and VS Code terminal: `Iterm2`.
- Foot: `Sixel`.
- Alacritty: Ueberzug with `ueberzugpp` installed.
- Konsole or universal fallback: `Block`.

Ueberzug ignores RMPC alignment and hides overlays during modals. Sixel and Iterm2 can have tmux limitations. Restart after changing the method.

## Lyrics

Config options are `lyrics_dir`, `lyrics_offset_ms`, `enable_lyrics_index`, and `enable_lyrics_hot_reload`. Theme option `lyrics.timestamp` controls timestamp display.

Resolution order:

1. Same relative path under `lyrics_dir`, with extension changed to `.lrc`.
2. Indexed metadata match.

Indexed matching requires exact case-insensitive artist and title. Album must match when present on both sides. LRC length must be within five seconds when supplied. Negative `lyrics_offset_ms` displays lyrics later; positive displays them sooner.

`enable_lyrics_index` defaults true. Turning it off also disables lyric hot reload. Use `rmpc lyricsindex` for diagnostics.

## Cava

Cava needs the `cava` executable and usually an MPD FIFO output. Runtime/audio settings belong in `config.ron`; visuals belong in the theme; `Pane(Cava)` must appear in tabs or layout.

Config shape:

```ron
cava: (
    framerate: 60,
    autosens: true,
    sensitivity: 100,
    lower_cutoff_freq: 50,
    higher_cutoff_freq: 10000,
    input: (
        method: Fifo,
        source: "/tmp/mpd.fifo",
        sample_rate: 44100,
        channels: 2,
        sample_bits: 16,
    ),
    smoothing: (noise_reduction: 77, monstercat: false, waves: false),
    eq: [],
),
```

Theme shape:

```ron
cava: (
    bar_symbols: ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'],
    inverted_bar_symbols: ['▔', '🮂', '🮃', '▀', '🮄', '🮅', '🮆', '█'],
    bg_color: "black",
    bar_width: 1,
    bar_spacing: 1,
    orientation: Bottom,
    bar_color: Single("red"),
),
```

Orientations are `Top`, `Bottom`, and `Horizontal`. Color modes are `Single(color)`, `Rows([colors])`, and `Gradient({0: "#...", 100: "#..."})`. Gradients support only hex/RGB colors and need true color. Configure only one `bar_color` variant.

## Optional Integrations

- YouTube/SoundCloud/NicoVideo require `yt-dlp`, `ffmpeg`, `ffprobe`, Python 3, and `mutagen`.
- YouTube requires `cache_dir` and an MPD local socket, not TCP, to enqueue files outside the music directory.
- Stickers require `sticker_file` in `mpd.conf`. Common names are `rating`, `like`, and custom values such as `playCount`.
- `Rate(...)` bindings support modal/value/like/neutral/dislike modes and require sticker support.

## Common Failure Checks

When RMPC fails to load or the UI is malformed, check these in order:

1. Installed version is exactly 0.11.0 and options came from versioned docs or generated output.
2. RON delimiters, trailing commas, quotes, and enum capitalization are correct.
3. `duration_format` has no invalid or trailing `%` token.
4. Theme resolution points to the intended file.
5. Base layout contains exactly one `TabContent`.
6. A base-layout pane is not duplicated in a tab.
7. Exact pane sizes include border cells and percentage widths are coherent.
8. Component names and `Library(...)` border symbol sets exist.
9. General Property panes use `Song(...)`/`Status(...)`, while browser/song-table formats use unwrapped song properties.
10. `case_sensitive` and `ignore_diacritics` are not both enabled.
11. Album-art backend matches the terminal and multiplexer.
12. Cava has an accessible FIFO whose sample format matches MPD output.
13. Lyrics are on the client machine and metadata/path matching is valid.
14. MPD feature version is sufficient: 0.23.5 minimum, 0.24 for playlist reflection, 0.25 for diacritic-insensitive search.

## Known v0.11.0 Documentation Traps

Use generated v0.11.0 defaults as the authority. Avoid copying gallery themes wholesale because some contain stale fields such as `draw_borders`, `show_song_table_header`, and old `header.rows` structures.

Other prose/reference inconsistencies:

- Album-art prose says “three methods” but the explicit enum has eight variants.
- The documented `disabled_protocols` default has a missing quote; use `["http://", "https://"]`.
- `DeleteFromPlaylist` uses `confirmation`; `confirmartion` is a typo.
- `header_background_color` and `modal_background_color` signatures are mislabeled in prose.
- The scrollbar symbols signature is mislabeled; generated `symbols` is correct.
- `RepeatV2`/`RandomV2` prose examples have copy/paste errors; generated fields such as `off_style` are authoritative.
- `playlist` and `playlist_style` exist in generated theme symbols even though some prose omits them.

## Versioned Sources

- [Documentation home](https://rmpc.mierak.dev/0.11.0/)
- [General configuration](https://rmpc.mierak.dev/0.11.0/configuration/)
- [Theme](https://rmpc.mierak.dev/0.11.0/configuration/theme/)
- [Layout](https://rmpc.mierak.dev/0.11.0/configuration/layout/)
- [Tabs](https://rmpc.mierak.dev/0.11.0/configuration/tabs/)
- [Panes](https://rmpc.mierak.dev/0.11.0/configuration/panes/)
- [Properties](https://rmpc.mierak.dev/0.11.0/configuration/properties/)
- [Style and color](https://rmpc.mierak.dev/0.11.0/configuration/style-color/)
- [Song table](https://rmpc.mierak.dev/0.11.0/configuration/song-table/)
- [Keybindings](https://rmpc.mierak.dev/0.11.0/configuration/keybinds/)
- [Album art](https://rmpc.mierak.dev/0.11.0/configuration/album-art/)
- [Lyrics](https://rmpc.mierak.dev/0.11.0/configuration/lyrics/)
- [Cava](https://rmpc.mierak.dev/0.11.0/configuration/cava/)
- [Default config](https://rmpc.mierak.dev/0.11.0/reference/config/)
- [Default theme](https://rmpc.mierak.dev/0.11.0/reference/theme/)
- [CLI and command mode](https://rmpc.mierak.dev/0.11.0/reference/cli-command-mode/)
