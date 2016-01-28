//get uppercase versions of all strings from 'strings' array shorter than 4
let strings = ["m", "Dev", "Talk"]



//imperative
var longUppercaseStrings1 : [String] = []
for s in strings {
    if s.characters.count > 1 {
        longUppercaseStrings1.append(s.uppercaseString)
    }
}

longUppercaseStrings1


































//functional
let longUppercaseStrings2 = strings
    .filter { $0.characters.count > 1 }
    .map { $0.uppercaseString }

longUppercaseStrings2















