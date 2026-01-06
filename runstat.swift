import Cocoa
import Foundation

class StatusBarController {
    private var statusItem: NSStatusItem
    private var timer: Timer?
    private var menu: NSMenu
    private var isShowingDetails = false
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()
        setupMenu()
        
        // Remove menu initially to allow click action
        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.target = self
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        // Initial state
        updateDisplay()
        startMonitoring()
    }
    
    private func setupMenu() {
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    @objc private func statusItemClicked() {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            // Right click - show menu
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            // Left click - toggle view
            isShowingDetails.toggle()
            updateDisplay()
        }
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
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
        
        let attributedString = NSMutableAttributedString(string: displayText)
        
        // Color based on CPU usage
        let textColor: NSColor = cpuUsage >= 80 ? NSColor.red : NSColor.black
        attributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: attributedString.length))
        
        statusItem.button?.attributedTitle = attributedString
        
        // Tooltip with detailed info
        statusItem.button?.toolTip = """
        CPU: \(String(format: "%.1f", cpuUsage))%
        Memory: \(formatBytes(memUsed)) / \(formatBytes(memTotal)) (\(String(format: "%.1f", memUsage))%)
        Disk: \(formatBytes(diskUsed)) / \(formatBytes(diskTotal)) (\(String(format: "%.1f", diskUsage))%)
        
        Click to toggle detailed view
        """
    }
    
    private func getSystemStats() -> (cpu: Double, mem: Double, disk: Double) {
        let cpu = getCPUUsage()
        let mem = getMemoryUsage()
        let disk = getDiskUsage()
        return (cpu, mem, disk)
    }
    
    private func getCPUUsage() -> Double {
        var loadAvg = [Double](repeating: 0, count: 3)
        let result = getloadavg(&loadAvg, 3)
        if result > 0 {
            return min(loadAvg[0] * 25, 100) // Normalize for 4 cores
        }
        return 0
    }
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let totalMem = ProcessInfo.processInfo.physicalMemory
            let usedMem = UInt64(info.resident_size)
            return Double(usedMem) / Double(totalMem) * 100
        }
        return 0
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
        do {
            let url = URL(fileURLWithPath: "/")
            let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
            
            if let available = values.volumeAvailableCapacity,
               let total = values.volumeTotalCapacity {
                let used = total - available
                return Double(used) / Double(total) * 100
            }
        } catch {}
        return 0
    }
    
    private func getDiskCapacity() -> (used: UInt64, total: UInt64) {
        do {
            let url = URL(fileURLWithPath: "/")
            let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
            
            if let available = values.volumeAvailableCapacity,
               let total = values.volumeTotalCapacity {
                let used = UInt64(total - available)
                return (used, UInt64(total))
            }
        } catch {}
        return (0, 0)
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
        statusBarController = StatusBarController()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
