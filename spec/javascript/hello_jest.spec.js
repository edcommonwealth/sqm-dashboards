import Jester from "jester"

describe('this test should pass', () => {
  test('very first test', () => {
    expect(true).toBe(true)
  })

  test('Jester.hello returns greeting', () =>{
    const jester = new Jester()
    expect(jester.hello()).toBe("Hello")
  })
})
