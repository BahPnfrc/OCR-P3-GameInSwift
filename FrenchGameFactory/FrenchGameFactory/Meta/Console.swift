//
//  Console.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 02/03/2021.
//

import Foundation

class Console {

    enum OutputType { case error, standard }
    
    // MARK: Write functions
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
    
    static func writeError(atLine: Int, inFunc: String) {
        Console.write(1, 1, "❌ Guard failed at lign \(atLine) in \(inFunc)",0)
        Console.getBreakPrompt(tab: 1)
        Console.emptyLine()
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
    
    // MARK: Errors
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
        Console.write(0, 0,
        "➡️ Type a number from \(range.lowerBound) to \(range.upperBound) and press 'Enter' ✅".withNum(),
        0)
    }
    private static func promptForIntInputWithHelp(_ range: ClosedRange<Int>) {
        Console.write(0, 0,
        "➡️ Type 'help' ✳️ or a number from \(range.lowerBound) to \(range.upperBound) and press 'Enter' ✅".withNum(),
        0)
    }
    static func getIntInput(fromTo range: ClosedRange<Int>, withHelp: Bool = false, inGame game: Game? = nil) -> Int {
        repeat {
            if withHelp { promptForIntInputWithHelp(range) }
            else { promptForIntInput(range) }
            do {
                let rawInput = try getRawInput()
                if withHelp && rawInput == "help" {
                    if let game = game { Console.write(1, 1, game.help(), 1)}
                } else {
                    guard let intInput: Int = Int(rawInput) else {
                        Console.write(0, 1, "⚠️ Expected number was not found : \(randomError) ⚠️", 1)
                        continue
                    }
                    guard range.contains(intInput) else {
                        Console.write(0, 1, "⚠️ \(intInput) is not expected : \(randomError) ⚠️", 1)
                        continue
                    }
                    return intInput
                }
            } catch {
                Console.write(0,1, "⚠️ No input was found : \(randomError) ⚠️", 1)
                continue
            }
        } while true
    }
    
    // MARK: String input
    private static func promptForStringInput(_ required: String) {
        Console.write(0, 0, "➡️ Type \(required) and press 'Enter' ✅", 0)
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
                    Console.write(0, 1, "⚠️ No space is allowed : \(defaultError) ⚠️", 1)
                    continue
                }
                if !allowDigit && contentCheck(content: stringInput, check: .decimalDigits) {
                    Console.write(0, 1, "⚠️ No digit is allowed : \(defaultError) ⚠️", 1)
                    continue
                }
                return stringInput
            } catch {
                Console.write(0, 1, "⚠️ No input was found : \(randomError) ⚠️", 1)
                continue
            }
        } while true
    }
    static func getExitPrompt(exitWord:String) -> Bool {
        while true {
            Console.write(0, 0, "⏸ Type '\(exitWord)' ❎ or press 'Enter' to continue ✅", 0)
            guard let typedText = readLine() else { return false }
            return typedText == exitWord
        }
    }
    
    static func getBreakPrompt(tab: Int = 0) {
        Console.write(0, tab, "⏸ Press 'Enter' to continue ✅", 0)
        _ = readLine()
    }
}
