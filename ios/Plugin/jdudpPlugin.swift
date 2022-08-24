import Foundation
import Capacitor

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
    let test = 'test'

    call.resolve([
          "test": test
    ])
  }
}
