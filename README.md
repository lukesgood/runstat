# runstat

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-10.13+-blue.svg)](https://www.apple.com/macos/)

macOS menubar system monitor - CPU usage percentage display

## Features
- Real-time CPU, memory, and disk usage monitoring
- CPU usage percentage display in menubar
- Detailed tooltip on hover (CPU, memory, disk)
- Supports macOS 10.13 and later

## Display Format
- Menubar: CPU usage percentage (e.g., CPU 25%)
- Color coding:
  - ⚫ Black: 0-79% (normal)
  - 🔴 Red: 80%+ (high usage)
- Tooltip: Detailed CPU, memory, and disk usage information

## Installation

### Automatic Installation and Login Item Registration
```bash
./install.sh
```

### Manual Installation
1. Copy runstat.app to Applications folder
2. Launch runstat from Applications

### Building from Source
```bash
make build
```

Or using Swift directly:
```bash
swiftc -o runstat runstat.swift
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
