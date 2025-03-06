import SwiftUI
import AppKit

struct AppIcon {
    static func setAppIcon() {
        // Create the Dify logo based on the image shared by the user
        let image = createDifyLogo()
        
        // Set the app icon
        NSApplication.shared.applicationIconImage = image
        
        // Save the image to the application support directory
        if let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let iconURL = appSupportURL.appendingPathComponent("AppIcon.png")
            
            if let tiffData = image.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                
                try? pngData.write(to: iconURL)
            }
        }
    }
    
    private static func createDifyLogo() -> NSImage {
        let size = NSSize(width: 1024, height: 1024)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Draw white rounded rectangle background
        NSColor.white.setFill()
        let backgroundPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: size.width * 0.2, yRadius: size.width * 0.2)
        backgroundPath.fill()
        
        // Draw the "D" shape
        let dPath = NSBezierPath()
        let centerX = size.width / 2
        let centerY = size.height / 2
        let width = size.width * 0.6
        let height = size.height * 0.6
        
        // Left vertical part of the D
        dPath.move(to: NSPoint(x: centerX - width/3, y: centerY - height/2))
        dPath.line(to: NSPoint(x: centerX - width/3, y: centerY + height/2))
        
        // Top horizontal part of the D
        dPath.line(to: NSPoint(x: centerX, y: centerY + height/2))
        
        // Right curved part of the D
        dPath.appendArc(withCenter: NSPoint(x: centerX, y: centerY), 
                       radius: height/2, 
                       startAngle: 90, 
                       endAngle: -90, 
                       clockwise: true)
        
        dPath.close()
        
        // Create gradient for the D
        let gradient = NSGradient(starting: NSColor(calibratedRed: 0.3, green: 0.5, blue: 1.0, alpha: 1.0), 
                                 ending: NSColor(calibratedRed: 0.7, green: 0.8, blue: 1.0, alpha: 1.0))
        
        gradient?.draw(in: dPath, angle: 45)
        
        image.unlockFocus()
        
        return image
    }
} 