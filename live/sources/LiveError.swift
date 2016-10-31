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

/// Enum containing errors that can be thrown when running the live application
enum LiveError: Error {
    /// Thrown when no file path was given
    case noFilePath
    /// Thrown when an invalid file path was given
    case invalidFilePath
    /// Thrown when the given file path contained invalid data
    case invalidFileData
    /// Thrown when a connection error occured (contains an error message)
    case couldNotConnect(String)
}

extension LiveError: CustomStringConvertible {
    var description: String {
        switch self {
        case .noFilePath:
            return "No file path given"
        case .invalidFilePath:
            return "Invalid file path given"
        case .invalidFileData:
            return "Invalid data for given file path. Make sure the file is a JSON file."
        case .couldNotConnect(let message):
            return "Could not connect to live service. Error: \(message)"
        }
    }
}
