unit-testing.ahk
===========

A unit test framework for AutoHotkey

## Installation

In a terminal or command line navigated to your project folder:
```bash
npm install unit-testing.ahk
```

In your code:
```autohotkey
#Include %A_ScriptDir%\node_modules
#Include unit-testing.ahk\export.ahk
assert := new unittesting.ahk

testVar := 2 + 2
assert.equal(testVar, 4)
assert.fullReport()
```
You may also review or copy the library from [./export.ahk on GitHub](https://github.com/Chunjee/unit-testing.ahk); #Include as you would normally when manually downloading.


## Usage

Grants access to a class named `unittesting` with the following methods: `.equal`, `.true`, `.false`, `.notEqual`, `.label`, `.report`, `.fullReport`, and `.writeTestResultsToFile`

```autohotkey
assert := new unittesting()

; .equal checks and logs whether or not both arguments are the same
assert.label("string comparison")
assert.equal("StringExample", "StringExample")

assert.label("value testing")
assert.equal((1 > 0 ), true)

assert.label("true/false testing")
assert.true((1 == 1))
assert.false((1 != 1))
assert.notEqual(true,false)

assert.report()
assert.fullReport()
assert.writeTestResultsToFile()
```

## API

### .equal(actual, expected)

Alias: `.test`

checks if actual and expected are the same or equal. The comparison is case-insensitive when ahk is `inStringCaseSense, Off` (default ahk behavior)

##### Arguments
1. actual (*): The actual value computed
2. expected (*): The expected value

##### Returns
(boolean): returns true if the values were the same, else false

##### Example
```autohotkey
assert.equal("string", "tsring")
; => false

assert.equal((1 > 0 ), true)
; => true
```


### .true(actual)
checks if actual value is true.

##### Arguments
1. actual (*): The actual value computed

##### Returns
(boolean): returns true if the value is true, else false

##### Example
```autohotkey
assert.true((1 == 1))
; => true

assert.true(InStr("String", "S"))
; => true
```


### .false(actual)
checks if actual value is false.

##### Arguments
1. actual (*): The actual value computed

##### Returns
(boolean): returns true if the value is false, else false

##### Example
```autohotkey
assert.false((1 != 1))
; => true

assert.false(InStr("String", "X"))
; => true
```


### .notEqual(actual, expected)
checks if actual and expected are NOT the same or equal. The comparison is case-insensitive when ahk is `inStringCaseSense, Off` (default ahk behavior)

##### Arguments
1. actual (*): The actual value computed
2. expected (*): The expected value

##### Returns
(boolean): returns true if the value is false, else false

##### Example
```autohotkey
assert.notEqual((1 != 1))
; => true

assert.notEqual(InStr("String", "X"))
; => true
```


### .undefined(actual)
checks if actual is undefined (`""`).

##### Arguments
1. actual (*): The actual value computed

##### Returns
(boolean): returns true if the value is `""`, else false

##### Example
```autohotkey
assert.false((1 != 1))
; => true

assert.false(InStr("String", "X"))
; => true
```


### .label(label)
labels the following tests for logs and readability

##### Arguments
1. label (string): A human readable label for the next test(s) in sequence


##### Example
```autohotkey
assert.label("string comparisons")

assert.equal("String", "s")
assert.fullReport()
/*---------------------------
1 tests completed with 0% success (1 failure)
=================================
== string comparisons ==
Test Number: 1
Expected: s
Actual: String
---------------------------*/
```

### .group(label)
appends the label to a group of following tests for logs and readability

This may be useful when one has a lot of tests; and doesn't want to type out a repeatative label

##### Arguments
1. label (string): A human readable label prepend for the next test(s) in sequence


##### Example
```autohotkey
assert.group("strings")
assert.label("comparison")
assert.equal("String", "s")

assert.label("length")
assert.equal(strLen("String"), 9)

assert.fullReport()
/*---------------------------
2 tests completed with 0% success (2 failures)
=================================
== strings - comparisons ==
Test Number: 1
Expected: s
Actual: String

== strings - length ==
Test Number: 2
Expected: 99
Actual: 6
---------------------------*/
```


### .report()
Uses msgbox to display the results of all tests

##### Example
```autohotkey
assert.true(InStr("String", "S"))

assert.report()
/*---------------------------
1 test completed with 100% success
---------------------------*/
```


### .fullReport()
Uses msgbox to display the results of all tests with details of any failures

##### Example
```autohotkey
assert.true(InStr("String", "X"))

assert.fullReport()
/*---------------------------
1 tests completed with 0% success (1 failure)
=================================
Test Number: 1
Expected: true
Actual: false
---------------------------*/
```


### .writeTestResultsToFile([filepath])
writes test results to a file

##### Arguments
1. filepath (string): Optional, The file path to write all tests results to, the default is `A_ScriptDir "\result.tests.log"`

##### Example
```autohotkey
assert.true(InStr("String", "X"))

assert.writeTestResultsToFile()
/*Test Number: 1
Expected: true
Actual: false*/
```
