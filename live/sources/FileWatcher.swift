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

/// Class that enables observation of a file on disk
class FileWatcher {
    /// Enum containing events that `FileWatcher` generates
    enum Event {
        /// Sent when the observed file was changed. Contains the new file data.
        case fileChanged(Data)
        /// Sent when an error occurred. Contains the error that was encountered.
        case errorEncountered(Error)
    }
    
    private let filePath: String
    private let dispatchQueue: DispatchQueue
    private var dispatchSource: DispatchSourceFileSystemObject?
    private var fileDescriptor: CInt?
    
    /**
     *  Initialize an instance of this class
     *
     *  - Parameter filePath: The path of the file to watch
     */
    init(filePath: String) {
        self.filePath = filePath
        dispatchQueue = DispatchQueue(label: "com.spotify.hubframework.live")
    }
    
    /**
     *  Start watching the file that this watcher is for
     *
     *  - Parameter handler: The handler to call whenever an event occured. See
     *    `FileWatcher.Event` for more information about events.
     */
    func start(withHandler handler: @escaping (Event) -> Void) throws {
        let fileSystemRepresentation = (filePath as NSString).fileSystemRepresentation
        let fileDescriptor = open(fileSystemRepresentation, O_EVTONLY)
        
        guard fileDescriptor >= 0 else {
            throw LiveError.invalidFilePath
        }
        
        let dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: dispatchQueue)
        self.dispatchSource = dispatchSource
        self.fileDescriptor = fileDescriptor
        
        let fileEventHandler = {
            let url = URL(fileURLWithPath: self.filePath)
            
            do {
                let data = try Data(contentsOf: url)
                handler(.fileChanged(data))
            } catch {
                handler(.errorEncountered(error))
            }
        }
        
        dispatchSource.setEventHandler(handler: fileEventHandler)
        
        dispatchSource.setCancelHandler {
            self.stop()
        }
        
        dispatchSource.resume()
        
        fileEventHandler()
    }
    
    /// Stop the file watcher, and tear down any current file observations.
    func stop() {
        if let fileDescriptor = fileDescriptor {
            close(fileDescriptor)
        }
        
        dispatchSource?.cancel()
        
        fileDescriptor = nil
        dispatchSource = nil
    }
}
