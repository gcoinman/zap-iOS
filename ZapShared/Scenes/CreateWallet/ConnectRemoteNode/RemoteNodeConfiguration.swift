//
//  Zap
//
//  Created by Otto Suess on 20.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import KeychainAccess

/// the qrCode or json generated by zapconnect. url is optional.
struct RemoteNodeConfigurationQRCode: Codable {
    let certificate: String
    let macaroon: Data
    let url: URL?
    
    enum CodingKeys: String, CodingKey {
        case certificate = "c"
        case macaroon = "m"
        case url = "ip"
    }
    
    init?(json: String) {
        guard
            let data = json.data(using: .utf8),
            let remoteNodeConfiguration = try? JSONDecoder().decode(RemoteNodeConfigurationQRCode.self, from: data)
            else { return nil }
        self = remoteNodeConfiguration
    }
}

/// saved to keychain. url is required.
public struct RemoteNodeConfiguration: Codable {
    let certificate: String
    let macaroon: Data
    let url: URL

    static private let keychain = Keychain(service: "com.jackmallers.zap")
    
    func save() {
        guard
            let data = try? JSONEncoder().encode(self)
            else { return }
        
        let keychain = RemoteNodeConfiguration.keychain
        keychain[data: "remoteNodeConfiguration"] = data
    }
    
    static func load() -> RemoteNodeConfiguration? {
        let keychain = RemoteNodeConfiguration.keychain
        guard let data = keychain[data: "remoteNodeConfiguration"] else { return nil }
        return try? JSONDecoder().decode(self, from: data)
    }
    
    static func delete() {
        try? keychain.remove("remoteNodeConfiguration")
    }
}
