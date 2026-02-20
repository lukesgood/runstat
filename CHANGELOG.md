# Changelog

## [1.2] - 2026-02-20

### Added
- Launch at Login toggle in right-click menu
- Orange color indicator for moderate CPU usage (60-79%)
- Better error handling for system API calls

### Fixed
- Dynamic CPU core detection (was hard-coded to 4 cores)
- System-wide memory usage calculation (was only tracking app memory)
- Version number consistency across all files

### Changed
- Color thresholds: Black (0-59%), Orange (60-79%), Red (80%+)
- Improved guard statements for safer system calls

## [1.1] - Previous
- Added runcat-style animation with CPU-responsive speed

## [1.0] - Initial
- Initial release with CPU, memory, and disk monitoring
