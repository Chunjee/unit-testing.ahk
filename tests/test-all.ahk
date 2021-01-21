SetBatchLines, -1
#SingleInstance, force
#NoTrayIcon
#Include %A_ScriptDir%\..\export.ahk

assert := new unittesting()

assert.label("test - vars, arrays, objects")
assert.test("hello", "hello")
assert.test(["hello"], ["hello"])
assert.test({"key": "value"}, {"key": "value"})


assert.label("equal - vars, arrays, objects")
assert.equal("hello", "hello")
assert.equal(["hello"], ["hello"])
assert.equal({"key": "value"}, {"key": "value"})


assert.label("notEqual - vars, arrays, objects")
assert.notEqual("hello", "hello!")
assert.notEqual(["hello"], ["world"])
assert.notEqual({"key": "value"}, {"key": "differentValue"})


assert.label("true - vars")
assert.true(true)
assert.true(1)
assert.label("true - expressions")
assert.true((1 == 1))
assert.true((1 != 0))
assert.label("true - Function")
assert.test(inStr("String", "s"))


assert.label("false - vars")
assert.false(false)
assert.false(0)
assert.label("false - expressions")
assert.false((1 == 0))
assert.false((1 != 1))


assert.label("undefined - detect undefined value")
assert.undefined("")
assert.undefined(undefinedVar)


assert.writeTestResultsToFile()
assert.fullReport()
ExitApp
