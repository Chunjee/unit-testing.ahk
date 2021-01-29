SetBatchLines, -1
#SingleInstance, force
#NoTrayIcon
#Include %A_ScriptDir%\..\export.ahk

assert := new unittesting()

assert.category := "test"
assert.label("vars, arrays, objects")
assert.test("hello", "hello")
assert.test(["hello"], ["hello"])
assert.test({"key": "value"}, {"key": "value"})


assert.category := "equal"
assert.label("vars, arrays, objects")
assert.equal("hello", "hello")
assert.equal(["hello"], ["hello"])
assert.equal({"key": "value"}, {"key": "value"})


assert.category := "notEqual"
assert.label("vars, arrays, objects")
assert.notEqual("hello", "hello!")
assert.notEqual(["hello"], ["world"])
assert.notEqual({"key": "value"}, {"key": "differentValue"})


assert.category := "true"
assert.label("vars")
assert.true(true)
assert.true(1)
assert.label("expressions")
assert.true((1 == 1))
assert.true((1 != 0))
assert.label("Function")
assert.true(inStr("String", "s"))


assert.category := "false"
assert.label("vars")
assert.false(false)
assert.false(0)
assert.label("expressions")
assert.false((1 == 0))
assert.false((1 != 1))

assert.category := "undefined"
assert.label("detect undefined value")
assert.undefined("")
assert.undefined(undefinedVar)


assert.writeTestResultsToFile()
assert.fullReport()
ExitApp
