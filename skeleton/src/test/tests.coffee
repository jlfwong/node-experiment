{expect} = require './expect'

describe 'a mocha test', ->
  it 'can pass', ->
    expect(true).toEqual true

  it 'can be pending'

  it 'can fail', ->
    expect(false).not.toEqual false

  describe 'with nesting', ->
    it 'still works', ->
      expect('still works').toMatch /works/
