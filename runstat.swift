import Cocoa
import Foundation

class StatusBarController {
    private var statusItem: NSStatusItem
    private var timer: Timer?
    private var menu: NSMenu
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()
        setupMenu()
        statusItem.menu = menu
        
        // 초기 상태 설정
        let (cpuUsage, memUsage, diskUsage) = getSystemStats()
        let cpuText = "🖥️ \(String(format: "%.0f", cpuUsage))%"
        let attributedString = NSMutableAttributedString(string: cpuText)
        
        // 초기 색상 설정
        let textColor: NSColor
        let backgroundColor: NSColor
        if cpuUsage >= 80 {
            textColor = NSColor.white
            backgroundColor = NSColor.red
        } else if cpuUsage >= 60 {
            textColor = NSColor.white
            backgroundColor = NSColor.orange
        } else if cpuUsage >= 40 {
            textColor = NSColor.black
            backgroundColor = NSColor.yellow
        } else {
            textColor = NSColor.white
            backgroundColor = NSColor.green
        }
        
        // 전체 텍스트에 색상과 배경색 적용
        attributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.backgroundColor, value: backgroundColor, range: NSRange(location: 0, length: attributedString.length))
        statusItem.button?.attributedTitle = attributedString
        
        statusItem.button?.toolTip = """
        CPU: \(String(format: "%.1f", cpuUsage))%
        메모리: \(String(format: "%.1f", memUsage))%
        디스크: \(String(format: "%.1f", diskUsage))%
        """
        
        startMonitoring()
    }
    
    private func setupMenu() {
        let quitItem = NSMenuItem(title: "종료", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let (cpuUsage, memUsage, diskUsage) = self.getSystemStats()
            
            // CPU 사용률에 따른 색상 적용
            let cpuText = "🖥️ \(String(format: "%.0f", cpuUsage))%"
            let attributedString = NSMutableAttributedString(string: cpuText)
            
            // CPU 사용률에 따른 색상 결정
            let textColor: NSColor
            let backgroundColor: NSColor
            if cpuUsage >= 80 {
                textColor = NSColor.white
                backgroundColor = NSColor.red        // 빨간 배경 - 위험
            } else if cpuUsage >= 60 {
                textColor = NSColor.white
                backgroundColor = NSColor.orange     // 주황 배경 - 경고
            } else if cpuUsage >= 40 {
                textColor = NSColor.black
                backgroundColor = NSColor.yellow     // 노란 배경 - 주의
            } else {
                textColor = NSColor.white
                backgroundColor = NSColor.green      // 초록 배경 - 정상
            }
            
            // 전체 텍스트에 색상과 배경색 적용
            attributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(.backgroundColor, value: backgroundColor, range: NSRange(location: 0, length: attributedString.length))
            self.statusItem.button?.attributedTitle = attributedString
            
            let tooltip = """
            CPU: \(String(format: "%.1f", cpuUsage))%
            메모리: \(String(format: "%.1f", memUsage))%
            디스크: \(String(format: "%.1f", diskUsage))%
            """
            self.statusItem.button?.toolTip = tooltip
        }
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
            return min(loadAvg[0] * 25, 100) // 4코어 기준 정규화
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
