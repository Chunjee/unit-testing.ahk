unit-testing.ahk
===========

A unit test framework for AutoHotkey

## Installation

Install by defining the package in package.json:

```javascript
"dependencies": {
	"unit-testing.ahk": "chunjee/unit-testing.ahk"
}
```

```shell
yarn newinstall
```

## Usage

Grants access to a class named `unittesting` with three methods: `test`, `report`, `fullreport`

```autohotkey
assert := new unittesting()

; .test checks and logs whether or not both arguments are equal
assert.test("StringExample", "StringExample")
assert.test((1 > 0 ), true)

assert.true((1 == 1))
assert.false((1 != 1))

assert.notequal(true,false)

assert.report()
assert.fullreport()
```
