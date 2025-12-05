import Cocoa
import ReSwift

enum AppDelegateAction: Action {
    case didFinishLaunching
}

class AppDelegate: NSObject, NSApplicationDelegate {
    // 保持 window 引用，防止被释放
    var window: NSWindow!
    // 新增菜单栏图标引用
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_: Notification) {
        // --- 1. 设置菜单栏图标 (让你能退出它) ---
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            // 设置一个显示器图标
            button.image = NSImage(systemSymbolName: "display", accessibilityDescription: "DeskPad")
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Quit DeskPad", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu

        // --- 2. 创建“幽灵窗口” (核心修复) ---
        let viewController = ScreenViewController()

        // 初始化窗口，使用 viewController
        window = NSWindow(contentViewController: viewController)

        // 关键设置：把窗口变“透明”和“不存在”
        window.styleMask = [.borderless] // 去掉标题栏和边框
        window.alphaValue = 0.0 // 透明度设为 0 (完全隐形)
        window.isOpaque = false // 允许透明
        window.backgroundColor = .clear // 背景色透明
        window.ignoresMouseEvents = true // 让鼠标能穿透它 (不阻挡你点后面的东西)

        // 这是一个小技巧：虽然它是透明的，但我们必须让它“显示”出来，触发 VC 的生命周期
        window.makeKeyAndOrderFront(nil)

        // 把它层级放低一点，虽然看不见
        window.level = .floating

        // --- 3. 启动业务逻辑 ---
        store.dispatch(AppDelegateAction.didFinishLaunching)
    }

    // 确保没有窗口也不退出 (虽然我们有个透明窗口，但这句加上更保险)
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return false
    }
}
