//
//  ConsoleIO.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 02/03/2021.
//
// https://www.raywenderlich.com/511-command-line-programs-on-macos-tutorial
// https://www.journaldev.com/19612/swift-readline-swift-print

import Foundation

class Console {
    
    // Upon running a program the path to its executable is passed as argument[0]
    // Argument[0] is accessible through the global CommandLine enum
    static let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
    
    enum OutputType { case error, standard }

    static func write(
        _ message: String,
        to: OutputType = .standard,
        with header: String? = nil) {
      switch to {
        case .standard:
            // Uses the regular Swift print() function
            guard let header = header else {
                print(message)
                return
            }
            print(header + " " + message)
        case .error:
            // Uses the C function fputs to write to stderr
            // Stderr is a global variable and points to the standard error stream
            fputs("Error : " + message, stderr)
      }
    }
    
    enum InputError: Error {
        case noInput (info: String = "No input was found")
        case intExpected (info: String = "No number was found")
        case stringExpected (info: String = "No content was found")
        case counterExceeded (info: String = "Max input was exceeded")
    }
    
    // MARK: Raw input
    private static func getRawInput() throws -> String {
        guard let rawInput: String = readLine() else{
            throw InputError.noInput()
        }
        return rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: Int input
    private static func promptForIntInput(_ range: ClosedRange<Int>) {
        Console.write("Type a number from \(range.lowerBound) to \(range.upperBound) and press 'Enter' to confirm")
    }
    static func getIntInput(fromTo range: ClosedRange<Int>) -> Int {
        repeat {
            promptForIntInput(range)
            do {
                let rawInput = try getRawInput()
                guard let intInput: Int = Int(rawInput) else {
                    Console.write("No number was found : consider retrying", to: .standard)
                    continue
                }
                guard range.contains(intInput) else {
                    Console.write("\(intInput) is not expected : consider retrying", to: .standard)
                    continue
                }
                return intInput
            } catch {
                Console.write("No input was found : consider retrying", to: .error)
                continue
            }
        } while true
    }
    
    // MARK: String input
    private static func promptForStringInput(_ required: String) {
        Console.write("Type \(required) and press 'Enter' to confirm")
    }
    private static func contentCheck(content string: String, check charactereSet: CharacterSet) -> Bool {
        let range = string.rangeOfCharacter(from: charactereSet)
        return range != nil ? true : false
    }
    static func getStringInput(
        prompt: String,
        space allowSpace: Bool = false,
        digit allowDigit: Bool = false) -> String {
        repeat {
            promptForStringInput(prompt)
            do {
                let stringInput = try getRawInput()
                if !allowSpace && contentCheck(content: stringInput, check: .whitespaces) {
                    Console.write("No space is allowed : consider retrying", to: .standard)
                    continue
                }
                if !allowDigit && contentCheck(content: stringInput, check: .decimalDigits) {
                    Console.write("No digit is allowed : consider retrying", to: .standard)
                    continue
                }
                return stringInput
            } catch {
                Console.write("No input was found : consider retrying", to: .error)
                continue
            }
        } while true
    }
}
