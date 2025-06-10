import UIKit
import Flutter
import Network
import CoreTelephony
import SystemConfiguration.CaptiveNetwork
import NetworkExtension
import Foundation

@main
@objc class AppDelegate: FlutterAppDelegate {

  /*
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }*/

  override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      
    GeneratedPluginRegistrant.register(with: self)
    
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
    }

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    let channelInfo = FlutterMethodChannel(name: "com.example.network.type",
                                        binaryMessenger: controller.binaryMessenger)
    
    let channelStrength = FlutterMethodChannel(name: "com.example.network.strength",
                                        binaryMessenger: controller.binaryMessenger)
    
    channelInfo.setMethodCallHandler { (call, result) in
        if call.method == "getNetworkType" {
            result(self.getNetworkType())
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    channelStrength.setMethodCallHandler { (call, result) in
        if call.method == "getNetworkStrength" {
          
            var signalStrength  = self.getNetworkStrength()

            //result(self.getWifiSignalStrength())
            result("\(signalStrength) dBm")

        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getNetworkType() -> String {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")
    monitor.start(queue: queue)
    
    if monitor.currentPath.usesInterfaceType(.wifi) {
        return "WiFi"
    } else if monitor.currentPath.usesInterfaceType(.cellular) {
        return "Cellular"
    } else if monitor.currentPath.usesInterfaceType(.wiredEthernet) {
        return "Ethernet"
    } else {
        return "Unknown"
    }
  }

  private func getNetworkStrength() -> Int {
    let networkInfo = CTTelephonyNetworkInfo()

    //print(networkInfo)

    guard let carrier = networkInfo.serviceSubscriberCellularProviders?.values.first else {
      var info = getWiFiStrengthUsingHotspotHelper()
      //var info = getWifiSignalStrength()
      return info // Kein Netzbetreiber
    }
    
    let signalStrength = carrier.mobileNetworkCode ?? "-2"
    return Int(signalStrength) ?? -1
  }

  func getWifiSignalStrength() -> Int {
    var signalStrength = -3
    if let interfaces = CNCopySupportedInterfaces() as? [String] {
        for interface in interfaces {
            if let info = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                signalStrength = info["RSSI"] as? Int ?? -1
            }
        }
    }
    return signalStrength
  }

  /*
    📌 Achtung:

    Diese API funktioniert nur mit speziellen App Store-Berechtigungen.
    Deine App muss ein MDM-Profil oder spezielle Unternehmensrechte haben (normale Apps können das nicht einfach so nutzen).
  */
  func getWiFiStrengthUsingHotspotHelper() -> Int {
    var wifiStrength = -3
    NEHotspotHelper.register(options: nil, queue: DispatchQueue.main) { cmd in
        if let network = cmd.networkList?.first {
            wifiStrength = Int(network.signalStrength * 100)
        }
    }
    return wifiStrength
  }

  /*
    nur macos, kein ios
  */

  /*
  func getWifiStrengthFromLogs() -> Int {
      let process = Process()
      process.launchPath = "/usr/bin/log"
      process.arguments = ["stream", "--predicate", "subsystem == 'com.apple.wifi'"]

      let pipe = Pipe()
      process.standardOutput = pipe
      process.launch()

      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: data, encoding: .utf8) ?? ""
      
      if let match = output.range(of: "RSSI: (-\\d+)") {
          return Int(output[match]) ?? -1
      }
      return -1
  }
  */

}
