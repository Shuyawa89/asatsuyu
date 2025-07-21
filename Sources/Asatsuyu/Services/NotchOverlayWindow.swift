import AppKit
import SwiftUI

class NotchOverlayWindow: NSWindow {
    private var notchProgress: CGFloat = 0.0
    private var notchColor: NSColor = .controlAccentColor
    private var isNotchPresent: Bool = false
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.borderless], backing: backingStoreType, defer: flag)
        
        setupWindow()
        detectNotch()
    }
    
    private func setupWindow() {
        // ウィンドウの基本設定
        level = .screenSaver  // メニューバーより上に表示
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // ウィンドウをすべてのスペースで最前面に表示
        setAccessibilityRole(.unknown)
    }
    
    private func detectNotch() {
        guard let screen = NSScreen.main else { 
            print("NotchOverlay: No main screen found")
            return 
        }
        
        let screenSize = screen.frame.size
        print("NotchOverlay: Screen size: \(screenSize)")
        
        // ノッチ検出ロジック
        // macOS 14以降のノッチ搭載Macでは、safeAreaInsetsでノッチエリアを検出可能
        if #available(macOS 14.0, *) {
            let safeAreaInsets = screen.safeAreaInsets
            isNotchPresent = safeAreaInsets.top > 0
            print("NotchOverlay: Safe area top: \(safeAreaInsets.top)")
        } else {
            // フォールバック: 解像度ベースでの推定
            isNotchPresent = (screenSize.width == 3024 && screenSize.height == 1964) || // MacBook Pro 14"
                            (screenSize.width == 3456 && screenSize.height == 2234) || // MacBook Pro 16"
                            (screenSize.width == 2560 && screenSize.height == 1664)    // MacBook Air 13"
        }
        
        print("NotchOverlay: Notch present: \(isNotchPresent)")
        
        if isNotchPresent {
            setupNotchOverlay()
        } else {
            // ノッチがない場合もテスト用にオーバーレイを表示
            print("NotchOverlay: No notch detected, but showing overlay for testing")
            setupNotchOverlay()
        }
    }
    
    private func setupNotchOverlay() {
        guard let screen = NSScreen.main else { 
            print("NotchOverlay: No main screen for setup")
            return 
        }
        
        // ノッチエリアの推定座標
        let screenFrame = screen.frame
        let notchWidth: CGFloat = 200  // ノッチの推定幅
        let notchHeight: CGFloat = 32  // ノッチの推定高さ
        
        // ノッチ中央に配置
        let notchRect = NSRect(
            x: screenFrame.midX - (notchWidth / 2),
            y: screenFrame.maxY - notchHeight,
            width: notchWidth,
            height: notchHeight
        )
        
        print("NotchOverlay: Setting frame to: \(notchRect)")
        setFrame(notchRect, display: true)
        
        // カスタムビューを設定
        let overlayView = NotchProgressView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView = overlayView
        print("NotchOverlay: Overlay view setup complete")
    }
    
    // フレーム制約を無効化してノッチエリアへのアクセスを許可
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return frameRect
    }
    
    // MARK: - Public Methods
    
    func updateProgress(_ progress: CGFloat, color: NSColor) {
        self.notchProgress = progress
        self.notchColor = color
        
        if let overlayView = contentView as? NotchProgressView {
            overlayView.updateProgress(progress, color: color)
        }
    }
    
    func hide() {
        orderOut(nil)
    }
    
    func show() {
        print("NotchOverlay: show() called")
        // テスト目的で常に表示（ノッチの有無に関係なく）
        orderFrontRegardless()
        print("NotchOverlay: Window ordered front")
    }
}

// MARK: - Custom Progress View

class NotchProgressView: NSView {
    private var progress: CGFloat = 0.0
    private var progressColor: NSColor = .controlAccentColor
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // ノッチ形状の描画
        drawNotchProgress(in: context, rect: bounds)
    }
    
    private func drawNotchProgress(in context: CGContext, rect: NSRect) {
        // ノッチの外径に沿った進捗バーを描画
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius: CGFloat = min(rect.width, rect.height) * 0.4
        let lineWidth: CGFloat = 3.0
        
        // 背景の円弧
        context.setStrokeColor(NSColor.gray.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        
        let backgroundPath = CGMutablePath()
        backgroundPath.addArc(
            center: center,
            radius: radius,
            startAngle: -.pi / 2,  // 上から開始
            endAngle: 3 * .pi / 2, // 270度
            clockwise: false
        )
        context.addPath(backgroundPath)
        context.strokePath()
        
        // プログレス円弧
        if progress > 0 {
            context.setStrokeColor(progressColor.cgColor)
            
            let progressPath = CGMutablePath()
            let endAngle = -.pi / 2 + (2 * .pi * progress * 0.75) // 270度まで
            
            progressPath.addArc(
                center: center,
                radius: radius,
                startAngle: -.pi / 2,
                endAngle: endAngle,
                clockwise: false
            )
            context.addPath(progressPath)
            context.strokePath()
        }
    }
    
    func updateProgress(_ progress: CGFloat, color: NSColor) {
        self.progress = max(0, min(1, progress))
        self.progressColor = color
        
        DispatchQueue.main.async {
            self.needsDisplay = true
        }
    }
}