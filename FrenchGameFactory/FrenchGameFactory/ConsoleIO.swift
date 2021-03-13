//
//  ConsoleIO.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 02/03/2021.
//
// https://www.raywenderlich.com/511-command-line-programs-on-macos-tutorial
// https://www.journaldev.com/19612/swift-readline-swift-print

import Foundation

// Types of data used
enum OutputType {
  case error
  case standard
}

class ConsoleIO {
    
    // Messages can be passed to the console as Stderr or Stdout by default
    static func write(_ message: String, to: OutputType = .standard) {
      switch to {
        case .standard:
            // Uses the regular Swift print() function
            print("\(message)\n")
        case .error:
            // Uses the C function fputs to write to stderr
            // Stderr is a global variable and points to the standard error stream
            fputs("Error: \(message)\n", stderr)
      }
    }
    
    
    
    static func printHelp() {

        // Upon running a program the path to its executable is passed as argument[0]
        // Argument[0] is accessible through the global CommandLine enum
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
            
        write("\(executableName) :")
        write("\(executableName) -n : Start a new game")
        write("\(executableName) -s : Stats of the active game")
        write("\(executableName) -q : Quit the active game")
        write("\(executableName) -h : Show this help menu")
        write("Type \(executableName) without an option to enter interactive mode.")
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
