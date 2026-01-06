# runstat

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-10.13+-blue.svg)](https://www.apple.com/macos/)

macOS menubar system monitor - CPU usage percentage display

## Features
- Real-time CPU, memory, and disk usage monitoring
- CPU usage percentage display in menubar
- **Click to toggle detailed view** showing CPU, memory, and disk usage
- Detailed tooltip on hover (CPU, memory, disk)
- Supports macOS 10.13 and later

## Display Format
- **Default view**: CPU usage percentage (e.g., CPU 25%)
- **Detailed view** (click to toggle): CPU 25% | MEM 60% | DISK 45%
- Color coding:
  - ⚫ Black: 0-79% (normal)
  - 🔴 Red: 80%+ (high usage)
- Tooltip: Detailed CPU, memory, and disk usage information

## Installation

### Option 1: Homebrew (Builds from Source)
```bash
# Add the tap
brew tap lukesgood/runstat https://github.com/lukesgood/runstat.git

# Install runstat
brew install runstat

# Copy to Applications (follow the instructions shown after install)
cp -r "$(brew --prefix)/runstat.app" /Applications/
```

### Option 2: Direct Download
1. Download `runstat.app.zip` from [latest release](https://github.com/lukesgood/runstat/releases/latest)
2. Unzip and drag `runstat.app` to Applications folder
3. Launch runstat from Applications

### Option 3: Build from Source
```bash
git clone https://github.com/lukesgood/runstat.git
cd runstat
make build
./install.sh
```

## Uninstallation
Delete runstat.app from Applications folder

## Contributing
Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Version History
- 1.2 - Direct CPU usage percentage display
- 1.1 - Added runcat-style animation with CPU-responsive speed
- 1.0 - Initial release
