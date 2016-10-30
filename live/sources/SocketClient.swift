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

import Foundation

/// Class acting as a socket client for communication with a Hub Framework-powered application
class SocketClient {
    private let port: Int
    private var stream: OutputStream?
    
    /**
     *  Initialize an instance of this class
     *
     *  - Parameter port: The port to connect a socket to
     */
    init(port: Int) {
        self.port = port
    }
    
    /// Connect the socket, or throw an error
    func connect() throws {
        let stream = try makeStream()
        stream.open()
        
        if let error = stream.streamError {
            throw error
        }
        
        self.stream = stream
    }
    
    /// Disconnect any previously connected socket
    func disconnect() {
        self.stream?.close()
        self.stream = nil
    }
    
    /**
     *  Send binary data over the socket
     *
     *  - Parameter data: The data to send. Should be JSON data.
     */
    func send(data: Data) {
        guard let stream = stream else {
            print("Stream not setup")
            return
        }
        
        switch stream.streamStatus {
        case .notOpen:
            printError(message: "Stream is not open")
        case .opening, .writing:
            DispatchQueue(label: "Awaiting stream setup").async {
                self.send(data: data)
            }
            
            return
        case .open, .reading, .atEnd:
            break
        case .closed:
            printError(message: "Stream has been closed")
            return
        case .error:
            printError(message: "An error occured. Make sure your app is running in the iOS Simulator")
            return
        }
        
        if !stream.hasSpaceAvailable {
            printError(message: "No space available in stream")
            return
        }
        
        let result = data.withUnsafeBytes { bytes in
            return stream.write(bytes, maxLength: data.count)
        }
        
        if result <= 0 {
            printError(message: "No data could be written")
        }
    }
    
    // MARK: - Private
    
    private func makeStream() throws -> OutputStream {
        let ipConfigResult = CommandLine.execute(command: "ipconfig", arguments: ["getifaddr", "en0"])
        
        switch ipConfigResult {
        case .output(let output):
            let hostName = output.trimmingCharacters(in: .whitespacesAndNewlines)
            var stream: OutputStream? = nil
            
            Stream.getStreamsToHost(withName: hostName, port: port, inputStream: nil, outputStream: &stream)
            
            if let stream = stream {
                return stream
            }
            
            throw LiveError.couldNotConnect("Socket could not be created")
        case .error(let message):
            throw LiveError.couldNotConnect(message)
        }
    }
    
    private func printError(message: String) {
        "Could not send JSON data to application. \(message).".print(withColor: .red)
    }
}
