class Expectation
  assert: (expr, message) ->
    if not expr
      throw new Error "Expected #{@actual} #{message}"

  constructor: (@actual) ->
    @not = new NegatedExpectation(@actual)

  toEqual: (expected) ->
    @assert @actual == expected, "to equal #{expected}"

  toMatch: (pattern) ->
    @assert pattern.test(@actual), "to match #{pattern}"

  toBe: (expected) ->
    @assert @actual == expected, "to be #{expected}"

  toBeDefined: ->
    @assert (typeof @actual) != 'undefined', "to be defined"

  toBeUndefined: ->
    @assert (typeof @actual) == 'undefined', "to be undefined"

  toBeTruthy: ->
    @assert @actual, "to be truthy"

  toBeFalsy: ->
    @assert not @actual, "to be falsy"

  toContain: (y) ->
    @assert @actual.indexOf(y) != -1, "to contain #{y}"

  toBeLessThan: (y) ->
    @assert @actual < y, "to be less than #{y}"

  toBeGreaterThan: (y) ->
    @assert @actual > y, "to be greater than #{y}"

  toThrow: (y) ->
    thrown = null
    try
      @actual()
    catch e
      thrown = e

    exceptionMatch = (y?.message || y) == (thrown?.message || thrown)
    @assert exceptionMatch, "to throw #{y}"

class NegatedExpectation extends Expectation
  constructor: (@actual) ->
    @negated = true

  assert: (expr, msg) ->
    super not expr, "not #{msg}"

exports.expect = (actual) -> new Expectation(actual)
