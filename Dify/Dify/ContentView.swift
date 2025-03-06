//
//  ContentView.swift
//  Dify
//
//  Created by elise123 on 2025-03-06.
//

import SwiftUI
@preconcurrency import WebKit
import Network

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel()
    @State private var urlString = "http://127.0.0.1/chat/RT9FucvdQG40M4RA"
    @State private var showSettings = false
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var isHovering = false
    
    @State private var commonUrls = [
        (name: "Chat Interface", url: "http://127.0.0.1/chat/RT9FucvdQG40M4RA"),
        (name: "Apps Dashboard", url: "http://127.0.0.1/apps")
    ]
    
    var body: some View {
        ZStack {
            // Main web content
            WebView(urlString: $urlString, webViewModel: webViewModel)
                .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            
            // Floating settings button in top-right corner
            VStack {
                Spacer().frame(height: 40)
                
                HStack(spacing: 8) {
                    Spacer()
                    
                    // Settings button only
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(6)
                            .background(
                                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                                    .cornerRadius(6)
                                    .opacity(0.7)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Settings")
                }
                .padding(.top, 4)
                .padding(.trailing, 8)
                .opacity(isHovering ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
                .frame(height: 30)
                .contentShape(Rectangle())
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovering = hovering
                    }
                }
                
                Spacer()
            }
            .padding(.top, 0)
            
            // Loading indicator
            if webViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                    .padding()
                    .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
                    .cornerRadius(10)
            }
            
            // Error view
            if webViewModel.error != nil {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Error loading page")
                        .font(.headline)
                    
                    Text(webViewModel.error?.localizedDescription ?? "Unknown error")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let urlError = webViewModel.error as? URLError {
                        Text("Error code: \(urlError.code.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 10) {
                        Button(action: {
                            webViewModel.reload()
                        }) {
                            Text("Reload")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            let newUrl = urlString.replacingOccurrences(of: "127.0.0.1", with: "localhost")
                            urlString = newUrl
                            webViewModel.loadURL(urlString: newUrl)
                        }) {
                            Text("Try Localhost")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            var newUrl = urlString
                            if newUrl.contains(":5001") {
                                newUrl = newUrl.replacingOccurrences(of: ":5001", with: ":3000")
                            } else if !newUrl.contains(":3000") {
                                // Check if we need to add a port
                                if let protocolRange = newUrl.range(of: "://") {
                                    let afterProtocol = newUrl.index(protocolRange.upperBound, offsetBy: 0)
                                    if let pathSlash = newUrl.range(of: "/", options: [.literal], range: afterProtocol..<newUrl.endIndex) {
                                        // Insert port before the path
                                        newUrl.insert(contentsOf: ":3000", at: pathSlash.lowerBound)
                                    } else {
                                        // No path, add port at the end
                                        newUrl += ":3000"
                                    }
                                }
                            }
                            urlString = newUrl
                            webViewModel.loadURL(urlString: newUrl)
                        }) {
                            Text("Try Port 3000")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(24)
                .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(urlString: $urlString, webViewModel: webViewModel, networkMonitor: networkMonitor, commonUrls: commonUrls)
        }
        .preferredColorScheme(nil) // Use system color scheme
        .environment(\.locale, .current) // Add explicit locale setting
        .onAppear {
            // Set the app's language explicitly
            UserDefaults.standard.set(["en-US"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            
            // Listen for updates to commonUrls
            NotificationCenter.default.addObserver(
                forName: Notification.Name("UpdateCommonUrls"),
                object: nil,
                queue: .main
            ) { notification in
                if let updatedUrls = notification.userInfo?["urls"] as? [(name: String, url: String)] {
                    self.commonUrls = updatedUrls
                }
            }
        }
    }
}

// Visual effect view for macOS
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// Custom button style for toolbar buttons
struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .contentShape(Rectangle())
            .cornerRadius(6)
    }
}

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

struct SettingsView: View {
    @Binding var urlString: String
    @ObservedObject var webViewModel: WebViewModel
    @ObservedObject var networkMonitor: NetworkMonitor
    @State private var tempUrlString: String = ""
    @State private var tempUrlName: String = ""
    @Environment(\.dismiss) var dismiss
    let commonUrls: [(name: String, url: String)]
    @State private var localCommonUrls: [(name: String, url: String)] = []

    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // URL input section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current URL")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("URL", text: $tempUrlString)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 4)
                        
                        HStack {
                            Button(action: {
                                // Add current URL to common URLs if not already there
                                if !tempUrlString.isEmpty && !localCommonUrls.contains(where: { $0.url == tempUrlString }) {
                                    // Use a default name based on the URL domain or path
                                    let urlComponents = URLComponents(string: tempUrlString)
                                    let defaultName = urlComponents?.host ?? "URL \(localCommonUrls.count + 1)"
                                    var updatedUrls = localCommonUrls
                                    updatedUrls.append((name: defaultName, url: tempUrlString))
                                    localCommonUrls = updatedUrls
                                    
                                    // Update the parent's commonUrls array
                                    NotificationCenter.default.post(
                                        name: Notification.Name("UpdateCommonUrls"),
                                        object: nil,
                                        userInfo: ["urls": updatedUrls]
                                    )
                                }
                            }) {
                                Text("Add to Common URLs")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(tempUrlString.isEmpty || localCommonUrls.contains(where: { $0.url == tempUrlString }))
                            
                            Spacer()
                            
                            Button(action: {
                                urlString = tempUrlString
                                webViewModel.loadURL(urlString: tempUrlString)
                                dismiss()
                            }) {
                                Text("Apply")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color(.textBackgroundColor).opacity(0.3))
                    .cornerRadius(10)
                    
                    // Common URLs section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Common URLs")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(localCommonUrls.indices, id: \.self) { index in
                                let item = localCommonUrls[index]
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        // Fix the editable nickname field
                                        TextField("Nickname", text: Binding(
                                            get: { 
                                                return localCommonUrls[index].name 
                                            },
                                            set: { newValue in
                                                if index < localCommonUrls.count {
                                                    var updatedUrls = localCommonUrls
                                                    updatedUrls[index].name = newValue
                                                    localCommonUrls = updatedUrls
                                                    
                                                    // Update the parent's commonUrls array
                                                    NotificationCenter.default.post(
                                                        name: Notification.Name("UpdateCommonUrls"),
                                                        object: nil,
                                                        userInfo: ["urls": updatedUrls]
                                                    )
                                                }
                                            }
                                        ))
                                        .font(.system(size: 12))
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .padding(3)
                                        .background(Color(.textBackgroundColor).opacity(0.5))
                                        .cornerRadius(3)
                                        .frame(width: 150)
                                        .id("nickname_\(index)_\(item.name)") // Add unique ID to ensure proper updates
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            var updatedUrls = localCommonUrls
                                            updatedUrls.remove(at: index)
                                            localCommonUrls = updatedUrls
                                            
                                            // Update the parent's commonUrls array through NotificationCenter
                                            NotificationCenter.default.post(
                                                name: Notification.Name("UpdateCommonUrls"),
                                                object: nil,
                                                userInfo: ["urls": updatedUrls]
                                            )
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.red.opacity(0.7))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.trailing, 5)
                                        .help("Remove URL")
                                    }
                                    
                                    Button(action: {
                                        tempUrlString = item.url
                                    }) {
                                        HStack {
                                            Text(item.url)
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "arrow.up.forward.app")
                                                .font(.system(size: 11))
                                                .foregroundColor(.blue)
                                        }
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 8)
                                        .background(tempUrlString == item.url ? Color.blue.opacity(0.1) : Color.clear)
                                        .cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                if index != localCommonUrls.count - 1 {
                                    Divider()
                                        .padding(.leading, 10)
                                        .padding(.vertical, 3)
                                }
                            }
                        }
                        .background(Color(.textBackgroundColor).opacity(0.3))
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(.textBackgroundColor).opacity(0.3))
                    .cornerRadius(10)
                    
                    // Debug info section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Debug Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            DebugInfoRow(label: "Error", value: webViewModel.error?.localizedDescription ?? "None")
                            
                            if let urlError = webViewModel.error as? URLError {
                                DebugInfoRow(label: "Error Code", value: "\(urlError.code.rawValue)")
                            }
                            
                            DebugInfoRow(label: "Can Go Back", value: webViewModel.canGoBack ? "Yes" : "No")
                            DebugInfoRow(label: "Can Go Forward", value: webViewModel.canGoForward ? "Yes" : "No")
                            DebugInfoRow(label: "Network", value: networkMonitor.isConnected ? "Connected" : "Disconnected")
                        }
                        .padding()
                        .background(Color(.textBackgroundColor).opacity(0.3))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(.textBackgroundColor).opacity(0.3))
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
        .onAppear {
            tempUrlString = urlString
            localCommonUrls = commonUrls
        }
    }
}

struct DebugInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
    }
}

class WebViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    var webView: WKWebView?
    
    func reload() {
        webView?.reload()
    }
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func loadURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            self.error = NSError(domain: "Invalid URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "The URL is not valid"])
            return
        }
        
        let request = URLRequest(url: url)
        webView?.load(request)
    }
    
    func updateNavigationState() {
        canGoBack = webView?.canGoBack ?? false
        canGoForward = webView?.canGoForward ?? false
    }
}

struct WebView: NSViewRepresentable {
    @Binding var urlString: String
    @ObservedObject var webViewModel: WebViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webViewModel.webView = webView
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // This is called when the view updates
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.webViewModel.isLoading = true
            parent.webViewModel.error = nil
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.webViewModel.isLoading = false
            parent.webViewModel.error = nil
            parent.webViewModel.updateNavigationState()
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.webViewModel.isLoading = false
            parent.webViewModel.error = error
            parent.webViewModel.updateNavigationState()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.webViewModel.isLoading = false
            parent.webViewModel.error = error
            parent.webViewModel.updateNavigationState()
        }
        
        // Handle JavaScript alerts
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = NSAlert()
            alert.messageText = "JavaScript Alert"
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.runModal()
            completionHandler()
        }
    }
}

#Preview {
    ContentView()
}
