//
//  ConsoleIO.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 02/03/2021.
//
// https://www.raywenderlich.com/511-command-line-programs-on-macos-tutorial

import Foundation

// Types of data used
enum OutputType {
  case error
  case standard
}

class ConsoleIO {
    
    // Messages can be passed to the console as Stderr or Stdout by default
    func writeMessage(_ message: String, to: OutputType = .standard) {
      switch to {
        case .standard:
            // Uses the regular Swift print() function
            print("\(message)")
        case .error:
            // Uses the C function fputs to write to stderr
            // Stderr is a global variable and points to the standard error stream
            fputs("Error: \(message)\n", stderr)
      }
    }
    
    func printHelp() {

        // Upon running a program the path to its executable is passed as argument[0]
        // Argument[0] is accessible through the global CommandLine enum
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
            
        writeMessage("\(executableName) :")
        writeMessage("\(executableName) -n : Start a new game")
        writeMessage("\(executableName) -s : Stats of the active game")
        writeMessage("\(executableName) -q : Quit the active game")
        writeMessage("\(executableName) -h : Show this help menu")
        writeMessage("Type \(executableName) without an option to enter interactive mode.")
    }
    
    func getInput() -> String {
      // 1
      let keyboard = FileHandle.standardInput
      // 2
      let inputData = keyboard.availableData
      // 3
      let strData = String(data: inputData, encoding: String.Encoding.utf8)!
      // 4
      return strData.trimmingCharacters(in: CharacterSet.newlines)
    }



    
}
