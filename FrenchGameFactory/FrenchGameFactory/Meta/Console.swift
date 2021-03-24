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
        _ lineBefore: Int = 0,
        _ tab: Int = 0,
        _ message: String,
        _ lineAfter: Int = 0) {
        
        if lineBefore > 0 { print(String(repeating: "\t", count: lineBefore)) }
        
        if tab > 0 {
            let lines: [String] = message.components(separatedBy: CharacterSet.newlines)
            for line in lines {
                print(String(repeating: "\t", count: tab) + line)
            }
        } else {
            print(message)
        }
        if lineAfter > 0 { print(String(repeating: "\t", count: lineAfter))}
    }
    
    static func writeError(_ message: String) {
        fputs("[Error] " + message + "\n", stderr) // Uses the C function
    }
    
    static func newSection(lines:Int = 2){
        print(String(repeating: "\n", count: lines - 1))
    }
    static func emptyLine(){
        print("")
    }
    static func tab(){
        print("\t")
    }
    
    enum InputError: Error {
        case noInput (info: String = "No input was found")
        case intExpected (info: String = "No number was found")
        case stringExpected (info: String = "No content was found")
        case counterExceeded (info: String = "Max input was exceeded")
    }
    
    static var defaultError: String = "consider retrying"
    static var randomError: String {
        let message: [String] =
        ["pay attention",
        "computer almost crashed"]
        return message.randomElement()!
    }
    
    // MARK: Raw input
    private static func getRawInput() throws -> String {
        guard var rawInput: String = readLine() else{
            throw InputError.noInput()
        }
        rawInput = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if rawInput.count < 1 {
            throw InputError.noInput()
        }
        return rawInput
    }
    
    // MARK: Int input
    private static func promptForIntInput(_ range: ClosedRange<Int>) {
        Console.write(0, 0, "➡️ Type a number from \(range.lowerBound) to \(range.upperBound) and press 'Enter' to confirm ✅", 0)
    }
    static func getIntInput(fromTo range: ClosedRange<Int>) -> Int {
        repeat {
            promptForIntInput(range)
            do {
                let rawInput = try getRawInput()
                guard let intInput: Int = Int(rawInput) else {
                    Console.write(1, 1, "⚠️ Expected number was not found : \(randomError) ⚠️", 1)
                    continue
                }
                guard range.contains(intInput) else {
                    Console.write(1, 1, "⚠️ \(intInput) is not expected : \(randomError) ⚠️", 1)
                    continue
                }
                return intInput
            } catch {
                Console.write(1,1, "⚠️ No input was found : \(randomError) ⚠️", 1)
                continue
            }
        } while true
    }
    
    // MARK: String input
    private static func promptForStringInput(_ required: String) {
        Console.write(0, 0, "➡️ Type \(required) and press 'Enter' to confirm ✅", 0)
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
                    Console.write(1, 1, "⚠️ No space is allowed : \(defaultError) ⚠️", 1)
                    continue
                }
                if !allowDigit && contentCheck(content: stringInput, check: .decimalDigits) {
                    Console.write(1, 1, "⚠️ No digit is allowed : \(defaultError) ⚠️", 1)
                    continue
                }
                return stringInput
            } catch {
                Console.write(1, 1, "⚠️ No input was found : \(randomError) ⚠️", 1)
                continue
            }
        } while true
    }
}
