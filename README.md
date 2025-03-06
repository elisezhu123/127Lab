Silicon Local 

Description:
SiliconLocal is a native macOS utility that lets developers create custom URL mappings for localhost (127.0.0.1), perfect for testing web projects, APIs, and multi-service environments. Optimized for Apple Silicon and running entirely on your machine, it eliminates the need for complex hosts file edits or cloud dependencies.

Techniques:
- Custom Domain Mapping: Route your-app.local → 127.0.0.1:3000
- Apple Silicon Native: M1/M2 optimized performance
- Zero-Config SSL: Automatic HTTPS for local domains
- Port Proxy: Forward traffic between ports
- Preset Templates: Quick setups for React, Next.js, Flask, etc.
- Hosts File Integration: Optional system-wide domain binding

Development Stack:
- Swift + SwiftUI (native macOS UI)
- Network Extension Framework
- libuv for low-level networking
- Secure Transport for SSL

I use Dify as an example to show how it look like.
![Screenshot 2025-03-06 at 4 41 53 AM](https://github.com/user-attachments/assets/072ea925-0b7b-4dd2-8d24-063e8d047f14)
"Setting" is automatically hidden unless you hover over it.
![Screenshot 2025-03-06 at 4 41 57 AM](https://github.com/user-attachments/assets/836c7ae3-8ab5-4482-afb4-12924908bc7c)
