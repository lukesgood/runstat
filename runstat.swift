import Cocoa
import Foundation

class StatusBarController {
    private var statusItem: NSStatusItem
    private var timer: Timer?
    private var menu: NSMenu
    private var isShowingDetails = false
    private var cachedStats: (cpu: Double, mem: Double, disk: Double)?
    private var lastUpdateTime: Date = Date()
    private var cachedDiskCapacity: (used: UInt64, total: UInt64)?
    private var lastDiskCheckTime: Date = Date()
    private var lastDisplayText: String = ""
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()
        setupMenu()
        
        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.target = self
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        updateDisplay()
        startMonitoring()
    }
    
    private func setupMenu() {
        menu.removeAllItems()
        
        let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchItem.target = self
        launchItem.state = isLaunchAtLoginEnabled() ? .on : .off
        menu.addItem(launchItem)
        
        let activityMonitorItem = NSMenuItem(title: "Open Activity Monitor", action: #selector(openActivityMonitor), keyEquivalent: "")
        activityMonitorItem.target = self
        menu.addItem(activityMonitorItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    @objc private func toggleLaunchAtLogin() {
        let enabled = isLaunchAtLoginEnabled()
        setLaunchAtLogin(!enabled)
        setupMenu()
    }
    
    @objc private func openActivityMonitor() {
        NSWorkspace.shared.launchApplication("Activity Monitor")
    }
    
    private func isLaunchAtLoginEnabled() -> Bool {
        let launchAgentPath = NSString(string: "~/Library/LaunchAgents/com.runstat.app.plist").expandingTildeInPath
        return FileManager.default.fileExists(atPath: launchAgentPath)
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        let launchAgentPath = NSString(string: "~/Library/LaunchAgents/com.runstat.app.plist").expandingTildeInPath
        
        if enabled {
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>com.runstat.app</string>
                <key>ProgramArguments</key>
                <array>
                    <string>/Applications/runstat.app/Contents/MacOS/runstat</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>ProcessType</key>
                <string>Interactive</string>
            </dict>
            </plist>
            """
            try? plistContent.write(toFile: launchAgentPath, atomically: true, encoding: .utf8)
            _ = shell("launchctl load '\(launchAgentPath)'")
        } else {
            _ = shell("launchctl unload '\(launchAgentPath)'")
            try? FileManager.default.removeItem(atPath: launchAgentPath)
        }
    }
    
    private func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    @objc private func statusItemClicked() {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            setupMenu()
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            isShowingDetails.toggle()
            updateDisplay()
        }
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateDisplay()
        }
    }
    
    private func updateDisplay() {
        let (cpuUsage, memUsage, diskUsage) = getSystemStats()
        let (memUsed, memTotal) = getMemoryCapacity()
        let (diskUsed, diskTotal) = getDiskCapacity()
        
        let displayText: String
        if isShowingDetails {
            displayText = "CPU \(String(format: "%.0f", cpuUsage))% | MEM \(formatBytes(memUsed))/\(formatBytes(memTotal)) | DISK \(formatBytes(diskUsed))/\(formatBytes(diskTotal))"
        } else {
            displayText = "CPU \(String(format: "%.0f", cpuUsage))%"
        }
        
        if displayText == lastDisplayText {
            return
        }
        lastDisplayText = displayText
        
        let attributedString = NSMutableAttributedString(string: displayText)
        
        let textColor: NSColor
        if cpuUsage >= 80 {
            textColor = NSColor.red
        } else if cpuUsage >= 60 {
            textColor = NSColor.orange
        } else {
            textColor = NSColor.black
        }
        attributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: attributedString.length))
        
        statusItem.button?.attributedTitle = attributedString
        
        statusItem.button?.toolTip = """
        CPU: \(String(format: "%.1f", cpuUsage))%
        Memory: \(formatBytes(memUsed)) / \(formatBytes(memTotal)) (\(String(format: "%.1f", memUsage))%)
        Disk: \(formatBytes(diskUsed)) / \(formatBytes(diskTotal)) (\(String(format: "%.1f", diskUsage))%)
        
        Click to toggle detailed view
        """
    }
    
    private func getSystemStats() -> (cpu: Double, mem: Double, disk: Double) {
        let now = Date()
        if let cached = cachedStats, now.timeIntervalSince(lastUpdateTime) < 0.5 {
            return cached
        }
        
        let stats = (getCPUUsage(), getMemoryUsage(), getDiskUsage())
        cachedStats = stats
        lastUpdateTime = now
        return stats
    }
    
    private func getCPUUsage() -> Double {
        var loadAvg = [Double](repeating: 0, count: 3)
        guard getloadavg(&loadAvg, 3) > 0 else { return 0 }
        let coreCount = Double(ProcessInfo.processInfo.processorCount)
        return min(loadAvg[0] / coreCount * 100, 100)
    }
    
    private func getMemoryUsage() -> Double {
        let (used, total) = getMemoryCapacity()
        return total > 0 ? Double(used) / Double(total) * 100 : 0
    }
    
    private func getMemoryCapacity() -> (used: UInt64, total: UInt64) {
        var info = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)
            let totalMem = ProcessInfo.processInfo.physicalMemory
            let freeMem = UInt64(info.free_count) * pageSize
            let usedMem = totalMem - freeMem
            return (usedMem, totalMem)
        }
        
        return (0, ProcessInfo.processInfo.physicalMemory)
    }
    
    private func getDiskUsage() -> Double {
        guard let url = URL(string: "file:///"),
              let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey]),
              let available = values.volumeAvailableCapacity,
              let total = values.volumeTotalCapacity else {
            return 0
        }
        let used = total - available
        return Double(used) / Double(total) * 100
    }
    
    private func getDiskCapacity() -> (used: UInt64, total: UInt64) {
        let now = Date()
        if let cached = cachedDiskCapacity, now.timeIntervalSince(lastDiskCheckTime) < 5 {
            return cached
        }
        
        guard let url = URL(string: "file:///"),
              let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey]),
              let available = values.volumeAvailableCapacity,
              let total = values.volumeTotalCapacity else {
            return (0, 0)
        }
        
        let result = (UInt64(total - available), UInt64(total))
        cachedDiskCapacity = result
        lastDiskCheckTime = now
        return result
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Prevent multiple instances
        if NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!).count > 1 {
            NSApp.terminate(nil)
            return
        }
        statusBarController = StatusBarController()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
