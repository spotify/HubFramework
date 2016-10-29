/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

import AppKit

/// Class representing the Hub Framework Live application
class Live {
    /**
     *  Run the application with an array of command line arguments
     *
     *  - Parameter arguments: The command line arguments to run the application with
     */
    static func run(withArguments arguments: [String]) throws {
        let filePath = try self.filePath(fromArguments: arguments)
        let fileWatcher = FileWatcher(filePath: filePath)
        
        let socketPort = self.socketPort(fromParguments: arguments)
        let socketClient = SocketClient(port: socketPort)
        
        do {
            try socketClient.connect()
            
            try fileWatcher.start { event in
                switch event {
                case .fileChanged(let data):
                    socketClient.send(data: data)
                case .errorEncountered(let error):
                    error.print()
                }
            }
        } catch {
            fileWatcher.stop()
            socketClient.disconnect()
            throw error
        }
        
        print("Live is running on port \(socketPort) for file \"\(filePath)\". Press any key to stop.")
        _ = FileHandle.standardInput.availableData
        
        fileWatcher.stop()
        socketClient.disconnect()
    }
    
    private static func filePath(fromArguments arguments: [String]) throws -> String {
        guard arguments.count > 1 else {
            throw LiveError.noFilePath
        }
        
        let filePath = arguments[1]
        
        guard filePath.characters.count > 0 else {
            throw LiveError.noFilePath
        }
        
        return (filePath as NSString).expandingTildeInPath
    }
    
    private static func socketPort(fromParguments arguments: [String]) -> Int {
        let defaultPort = 7777
        
        guard arguments.count > 2 else {
            return defaultPort
        }
        
        return Int(arguments[2]) ?? defaultPort
    }
}
