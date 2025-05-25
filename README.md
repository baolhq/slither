# Slither

Yet another Snake clone with Love2D, nothing fancy here..

## Player Manual

1. Move your snake with <code>arrow keys</code>
2. Move faster while holding <code>arrow key</code>
3. Pause and resume with <code>Space</code>
4. Restart the game with <code>Enter</code>

## Building

### Dependencies

Before you begin, make sure you have the following installed:

- Lua 5.1 or higher
- Love2D
- Python 3

After you have Python installed on your system, add these following packages for building cross-platforms:

```sh
pip3 install setuptools
pip3 install makelove
```

Then run this command to build

```sh
makelove --config build_config.toml
```

### Installation

Clone the repository:

```sh
git clone https://github.com/baolhq/slither.git
cd slither && code .
```

## Executing

To build and run the project:

- Press `Ctrl+Shift+B` to build using the provided `build_config.toml`, this will generate executables at `/bin` directory
- Or skip to run the project simply with `F5`

## Project Structure

```sh
/<slither>
├── main.lua                # Entry point
├── conf.lua                # Startup configurations
├── build_config.toml       # Configurations for cross-platform building
├── /lib                    # Common libraries
├── /src                    # Game source code
│   ├── entities/           # Game entities
│   ├── global/             # Global variables
│   └── util/               # Helper functions
├── /res                    # Static resources
│   ├── audio/              # Sound effects
│   └── font/               # Recommended fonts
└── /bin                    # Build output
```

## Screenshot

![Slither screenshot](https://images2.imgbox.com/5f/b0/CtpYQgDw_o.png)

## Version History

- 1.0.0
  - Initial release with basic snake
  - Smooth queue-based input system
  - Added pause, resume and restart mechanic
  - Added font, music and some SFX
  - Added some juicy particles, screenshake

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.
