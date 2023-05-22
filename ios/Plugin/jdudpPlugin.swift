import Foundation
import Capacitor
import CocoaAsyncSocket
import ffmpegkit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(jdudpPlugin)
public class jdudpPlugin: CAPPlugin {
  private let implementation = jdudp()

  @objc func echo(_ call: CAPPluginCall) {
    let value = call.getString("value") ?? ""
    call.resolve([
        "value": implementation.echo(value)
    ])
  }

  @objc func searchCams(_ call: CAPPluginCall) {
    let test = "test"

    call.resolve([
          "test": test
    ])
  }

  private var sockets: [Int: UdpSocket] = [Int: UdpSocket]()
    private var nextSocketId: Int = 0
    
    public override func load() {
       NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "capacitor-udp-forward"), object: nil, queue: nil, using: handleUdpForward )
    }
    
    private func handleUdpForward(_ notification: Notification) -> Void {
        let socketId:Int = notification.userInfo?["socketId"] as? Int ?? -1;
        var address:String = notification.userInfo?["address"] as? String ?? "";
        let port = notification.userInfo?["port"] as? Int ?? -1;
        let socket = sockets[socketId];
        let data = notification.userInfo?["data"] as? Data ?? Data.init();
        if(socket == nil || port < 0 || address == "" || socket?.isBound == false) {
            return;
        }
        if(!(socket?.broadcastEnabled ?? false) && address.trimmingCharacters(in: .whitespacesAndNewlines) == "255.255.255.255"){
            return;
        }
        if(address.contains(":") && (!address.contains("%"))){
            address = address + "%en0"
        }
        socket?.socket?.send(data, toHost: address, port: (port as NSNumber).uint16Value, withTimeout: -1, tag: -1)
    }
    
    
    @objc func create(_ call: CAPPluginCall) {
        let properties = call.getObject("properties")
        let socket = UdpSocket.init(plugin: self, id: nextSocketId, properties: properties)
        nextSocketId+=1
        sockets[socket.socketId] = socket;
        try? socket.socket?.enableReusePort(true)
        
        call.success(["socketId":socket.socketId,"ipv4":socket.getIPv4Address(),"ipv6":socket.getIPv6Address() ])
    }
    
    
    @objc func update(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        let properties:[String:Any] = call.getObject("properties") ?? [String:Any]()
        let socket = sockets[socketId]
        if( socket != nil){
            socket?.setProperties(properties)
            call.success()
        } else {
            call.error("no socket found")
        }
    }
    
    @objc func setPaused(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        let paused = call.getBool("paused")
        let socket = sockets[socketId]
        if( socket != nil && paused != nil){
            socket?.setPaused(paused ?? false)
            call.success()
        } else {
            call.error("setPaused failed")
        }
    }
    
    @objc func bind(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        let socket = sockets[socketId]
        var address = call.getString("address")
        let port = call.getInt("port") ?? -1
        if(socket == nil || port<0) {
            call.error("Invalid Argument")
            return
        }
        if(address == "0.0.0.0"){
            address = nil
        }
        do{
            try socket?.socket?.bind(toPort: (port as NSNumber).uint16Value, interface: address)
            if( !(socket?.paused ?? false) ){
                 try? socket?.socket?.beginReceiving()
            }
            socket?.isBound = true
            call.success()
        }catch{
            call.error("bind Error")
        }
    }
    
    @objc func send(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        var address = call.getString("address") ?? ""
        let port = call.getInt("port") ?? -1
        let socket = sockets[socketId]
        let dataString = call.getString("buffer") ?? ""
        //let data = Data(base64Encoded: dataString, options: .ignoreUnknownCharacters) ?? Data.init()
        let data = Data([0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFA, 0x05, 0x00, 0x00, 0x00, 0x00]) ?? Data.init()

        if(socket == nil || port < 0 || address == "") {
            call.error("Invalid Argument")
            return
        }
        if(socket?.isBound == false){
            call.error("Not bound yet")
            return
        }
        if(!(socket?.broadcastEnabled ?? false) && address.trimmingCharacters(in: .whitespacesAndNewlines) == "255.255.255.255"){
            call.error("Broadcast not allowed")
            return
        }
        if(address.contains(":") && (!address.contains("%"))){
            address = address + "%en0"
        }
        socket?.socket?.send(data, toHost: address, port: (port as NSNumber).uint16Value, withTimeout: -1, tag: -1)
        call.success(["bytesSent":data.count])
    }
    
    private func closeSocket(_ socket:UdpSocket?){
        if(!(socket?.socket?.isClosed() ?? true)){
            socket?.socket?.closeAfterSending()
        }
    }
    
    @objc func close(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        let socket = sockets[socketId]
        if(socket == nil) {
            call.error("Invalid Argument")
            return
        }
        closeSocket(socket)
        sockets[socketId] = nil
        call.success()
    }
    
    @objc func closeAllSockets(_ call: CAPPluginCall) {
        for (socketId, socket) in sockets {
            closeSocket(socket)
            sockets[socketId] = nil
        }
        call.success([
            "success": "close all"
        ])
    }
    
    @objc func getInfo(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        let socket = sockets[socketId]
        if(socket == nil) {
            call.error("Invalid Argument")
            return
        }
        call.success(socket?.getInfo() ?? [String:Any]())
    }
    
    @objc func getSockets(_ call: CAPPluginCall) {
        var socketsInfo = [Any]()
        for (_, socket) in sockets {
            socketsInfo.append(socket.getInfo())
        }
        call.success(["sockets":socketsInfo])
    }
    
    @objc func setBroadcast(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        let socket = sockets[socketId]
        let enabled = call.getBool("enabled")
        if(socket == nil || enabled == nil) {
            call.error("Invalid Argument")
            return
        }
        socket?.broadcastEnabled = enabled ?? false
        try? socket?.socket?.enableBroadcast(enabled ?? false)
        call.success();
    }
    
    @objc func joinGroup(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        let address = call.getString("address")
        let socket = sockets[socketId]
        if(socket == nil || address == nil){
            call.error("Invalid Argument")
            return
        }
        if(socket?.multicastGroup.contains(address ?? "") ?? false){
            call.error("Already bound")
            return
        }
        do {
            try socket?.socket?.joinMulticastGroup(address ?? "", onInterface: "en0")
            socket?.multicastGroup.insert(address ?? "")
            call.success()
        } catch {
            call.error("joinGroup error")
        }
    }
    
    @objc func leaveGroup(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        let address = call.getString("address")
        let socket = sockets[socketId]
        if(socket == nil || address == nil){
            call.error("Invalid Argument")
            return
        }
        if(!(socket?.multicastGroup.contains(address ?? "") ?? false)){
            call.success()
            return
        }
        do {
            try socket?.socket?.leaveMulticastGroup(address ?? "", onInterface: "en0")
            socket?.multicastGroup.remove(address ?? "")
            call.success()
        } catch {
            call.error("leaveGroup error")
        }
        
    }
    
    @objc func setMulticastTimeToLive(_ call: CAPPluginCall) {
        let socketId:Int = call.getInt("socketId") ?? -1
        let ttl = call.getInt("ttl") ?? -1
        let socket = sockets[socketId]
        if(socket == nil || ttl == -1){
            call.error("Invalid Argument")
            return
        }
        
        socket?.socket?.perform({ () -> Void in
            if(socket?.socket?.isIPv4() ?? false){
                var ttlCpy:CUnsignedChar = (ttl as NSNumber).uint8Value
                if( setsockopt(socket?.socket?.socket4FD() ?? 0,IPPROTO_IP,IP_MULTICAST_TTL, &ttlCpy, UInt32( MemoryLayout.size(ofValue: ttlCpy)) )<0){
                    call.error("ttl ipv4 error")
                }
            }
            if(socket?.socket?.isIPv6() ?? false){
                var ttlCpy = ttl
                if( setsockopt(socket?.socket?.socket6FD() ?? 0,IPPROTO_IPV6,IP_MULTICAST_TTL, &ttlCpy, UInt32( MemoryLayout.size(ofValue: ttlCpy)) )<0){
                    call.error("ttl ipv6 error")
                }
            }
            call.success()
        })
    }
    
    @objc func setMulticastLoopbackMode(_ call: CAPPluginCall) {
        
        let socketId:Int = call.getInt("socketId") ?? -1
        let enabled = call.getBool("enabled")
        let socket = sockets[socketId]
        if(socket == nil || enabled == nil){
            call.error("Invalid Argument")
            return
        }
        socket?.socket?.perform({ () -> Void in
            if(socket?.socket?.isIPv4() ?? false){
                var loop:CUnsignedChar = (enabled ?? false) ? 1 : 0
                if( setsockopt(socket?.socket?.socket4FD() ?? 0,IPPROTO_IP,IP_MULTICAST_LOOP, &loop, UInt32( MemoryLayout.size(ofValue: loop)) )<0){
                    call.error("loopback ipv4 error")
                }
            }
            if(socket?.socket?.isIPv6() ?? false){
                var loop:Int32 = (enabled ?? false) ? 1 : 0
                if( setsockopt(socket?.socket?.socket6FD() ?? 0,IPPROTO_IPV6,IP_MULTICAST_LOOP, &loop, UInt32( MemoryLayout.size(ofValue: loop)) )<0){
                    call.error("loopback ipv6 error")
                }
            }
            call.success()
        })
    }
    
    @objc func getJoinedGroups(_ call: CAPPluginCall){
        let socketId:Int = call.getInt("socketId") ?? -1
        let socket = sockets[socketId]
        let groups = socket?.multicastGroup ?? Set<String>()
        var groupArray = [String]()
        for group in groups {
            groupArray.append(group)
        }
        call.success(["groups":groupArray])
    }

    @objc func startRtspStream(_ call: CAPPluginCall) {

        /*NSLog("Check local Network Permission Before")
        if #available(iOS 14.0, *) {
          NSLog("Check local Network Permission 2")
          LocalNetworkPrivacy().checkAccessState { granted in
            NSLog("Check local Network Permission 3")
            NSLog("Check local Network Permission - Response: %@", granted)
          }
        }else{
          NSLog("Kleiner iOS 14, LocalNetwork immer moeglich")
        }
        NSLog("Check local Network Permission After")*/

        var pathObj: URL
        do {
          pathObj = try FileManager.default.url(
              for: .documentDirectory,
              in: .userDomainMask,
              appropriateFor: nil,
              create: false
          ).appendingPathComponent("rtspcache")
        } catch {
          NSLog("Error TryCatch get Path %@", error.localizedDescription)
          pathObj = URL(fileURLWithPath: "file://path/to/directory/egal.pdf")
        }

        var path = pathObj.path

        NSLog("path %@", path) 

        var isDir:ObjCBool = true
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
          NSLog("rtspcache Ordner nicht vorhanden, erstellen...")
          do {
            try FileManager.default.createDirectory(at: pathObj, withIntermediateDirectories: true)
          } catch {
            NSLog("Error TryCatch get Path %@", error.localizedDescription)
          }
        }else{
          NSLog("rtspcache Ordner vorhanden, TODO: Dateien löschen");
        }

        let ts = NSDate().timeIntervalSince1970;

        let indexFile = path + "/index_" + String(ts) + ".m3u8";

        let ipAddress = call.getString("ipadress") ?? ""
        let password = call.getString("password") ?? ""
        let channel = call.getString("channel") ?? ""
        let stream = call.getString("stream") ?? ""

        let rtspURL = "rtsp://" + ipAddress + ":554/user=admin_password=" + password + "_channel=" + channel + "_stream=" + stream + ".sdp?real_stream"
        let hls_segment_filename = path + "/" + String(ts) + "_%d.ts"
        let hls_base_url = "capacitor://localhost/_capacitor_file_" + path + "/"
        let command = "-fflags nobuffer -rtsp_transport tcp -probesize 3200 -analyzeduration 0 -i " + rtspURL + " -fps_mode passthrough -copyts -vcodec copy -movflags frag_keyframe+empty_moov -an -hls_flags delete_segments+append_list -f hls -preset veryfast -tune zerolatency -segment_list_flags live -hls_time 0.5 -hls_list_size 6 -segment_format mpegts -hls_base_url " + hls_base_url + " -hls_segment_filename " + hls_segment_filename + " " + indexFile

        var ret = [
          "path": indexFile
        ]

        NSLog("ffmpeg command %@", command);

        var streamRunningHasSend = false

        FFmpegKit.executeAsync(command) { session in
          guard let session = session else {
              NSLog("!! Invalid session")
              return
          }
          guard let returnCode = session.getReturnCode() else {
              NSLog("!! Invalid return code")
              return
          }

          NSLog("FFmpeg process exited 1: %@", FFmpegKitConfig.sessionState(toString: session.getState()))
          NSLog("FFmpeg process exited 2: %@", returnCode.description ?? "Unknown")
          NSLog("FFmpeg process exited 3: %@", session.getFailStackTrace() ?? "Unknown")
          //ret["status"] = "beendet"
          //call.success(ret)
        } withLogCallback: { logs in
          guard let logs = logs else { return }
          var logMessage = logs.getMessage()!;
          NSLog("withLogCallback %@", logMessage)

          if streamRunningHasSend == false && logMessage.contains("m3u8.tmp' for writing") {
            streamRunningHasSend = true
            ret["status"] = "running"
            call.success(ret)
          }

          if streamRunningHasSend == false && logMessage.contains("No route to host") {
            ret["status"] = "noroutetohost"
            call.success(ret)
          }
          // CALLED WHEN SESSION PRINTS LOGS
        } withStatisticsCallback: { stats in
          guard let stats = stats else { return }
          NSLog("withStatisticsCallback %@",stats)
          // CALLED WHEN SESSION GENERATES STATISTICS
        }

        //call.success()
    }

    @objc func stopRtspStream(_ call: CAPPluginCall) {
      var sessions = FFmpegKitConfig.getSessions()
      for session in sessions ?? [] {
        var castedSession = session as! Session
        var sessionId = castedSession.getId()
        FFmpegKit.cancel(sessionId)
      }
      call.success()
    }
    
    
    private class UdpSocket:NSObject, GCDAsyncUdpSocketDelegate {
        private weak var plugin:jdudpPlugin?
        let socketId:Int
        private var name:String
        private var bufferSize:NSNumber
        var paused:Bool
        var socket:GCDAsyncUdpSocket?
        var broadcastEnabled:Bool
        var isBound:Bool
        var multicastGroup: Set<String>

        init(plugin:jdudpPlugin, id: Int, properties: [String:Any]?) {
            self.socketId = id
            self.plugin = plugin
            self.bufferSize = 4096
            self.name = ""
            self.paused = false
            self.multicastGroup = Set<String>()
            self.broadcastEnabled = false
            self.isBound = false
            super.init()
            self.socket = GCDAsyncUdpSocket.init(delegate: self, delegateQueue:DispatchQueue.main)
            try? self.socket?.enableBroadcast(false)
            self.setProperties(properties ?? [String:Any]())
        }
        
        
        func getInfo() -> [String: Any] {
            let localAddress = socket?.localHost()
            let localPort = socket?.localPort()
            var socketInfo: [String: Any] = ["socketId":socketId,"name":name,"bufferSize":bufferSize,"paused":paused]
            if (localAddress != nil){
                socketInfo["localAddress"] =  localAddress
                socketInfo["localPort"]  = localPort
            }
            return socketInfo
        }
        
        func setProperties(_ properties:[String: Any]){
            name = properties["name"] as? String ?? name
            bufferSize = properties["bufferSize"] as? NSNumber ?? bufferSize
            if(bufferSize.intValue > UINT16_MAX){
                socket?.setMaxSendBufferSize(UInt16.max)
            }else {
                socket?.setMaxSendBufferSize(bufferSize.uint16Value)
            }
            if(socket?.isIPv4() ?? false){
                if(bufferSize.intValue > UINT16_MAX){
                    socket?.setMaxReceiveIPv4BufferSize(UInt16.max)
                }else {
                    socket?.setMaxReceiveIPv4BufferSize(bufferSize.uint16Value)
                }
            }
            if(socket?.isIPv6() ?? false){
                if(bufferSize.intValue > UINT32_MAX){
                    socket?.setMaxReceiveIPv6BufferSize(UInt32.max)
                }else {
                    socket?.setMaxReceiveIPv6BufferSize(bufferSize.uint32Value)
                }
            }
        }
        
        func setPaused(_ paused:Bool) {
            self.paused = paused
            if(paused){
                socket?.pauseReceiving()
            } else {
               try? socket?.beginReceiving()
            }
        }
        
        func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
            var ret = [String: Any]()
            ret["socketId"] = self.socketId
            ret["remoteAddress"] = GCDAsyncUdpSocket.host(fromAddress: address)
            ret["remotePort"] = GCDAsyncUdpSocket.port(fromAddress: address)
            ret["buffer"] = data.base64EncodedString();
            plugin?.notifyListeners("receive", data: ret, retainUntilConsumed: false)
        }
        
        func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
            plugin?.notifyListeners("receiveError", data: ["socketId":self.socketId ,"error":"socket closed"], retainUntilConsumed: false)
        }
        
      func getIPv6Address() -> String? {
          var address : String?

          // Get list of all interfaces on the local machine:
          var ifaddr : UnsafeMutablePointer<ifaddrs>?
          guard getifaddrs(&ifaddr) == 0 else { return nil }
          guard let firstAddr = ifaddr else { return nil }

          // For each interface ...
          for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
              let interface = ifptr.pointee

              // Check for IPv4 or IPv6 interface:
              let addrFamily = interface.ifa_addr.pointee.sa_family
              if addrFamily == UInt8(AF_INET6) {

                  // Check interface name:
                  let name = String(cString: interface.ifa_name)
                  if  name == "en0" {
                      var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                      getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                  &hostname, socklen_t(hostname.count),
                                  nil, socklen_t(0), NI_NUMERICHOST)
                      address = String(cString: hostname)
                  }
              }
          }
          freeifaddrs(ifaddr)
        if (address != nil){
            let index = address!.firstIndex(of: "%") ?? address?.endIndex
            let beginning = address![..<index!]
            let shortAddress = String(beginning)
            return shortAddress
            
        } else {
            return nil;
        }

        // beginning is "Hello"
        // Convert the result to a String for long-term storage.
        
        

      }
        
    func getIPv4Address() -> String? {
        var address : String?
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
        
    }
}
