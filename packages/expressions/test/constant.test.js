import { describe, test, expect } from 'vitest'
import { Constant, Schema } from '../lib'

describe('Constant', () => {
  describe('schema', () => {
    test('returns Constant schema', () => {
      expect(new Constant('string').schema.title).toEqual('Constant')
    })
  })

  describe('validate', () => {
    test('returns true for valid value', () => {
      expect(new Constant(true).validate().valid).toBe(true)
      expect(new Constant(false).validate().valid).toBe(true)
      expect(new Constant('string').validate().valid).toBe(true)
      expect(new Constant(42).validate().valid).toBe(true)
      expect(new Constant(3.14).validate().valid).toBe(true)
    })
  })

  describe('matches', () => {
    test('returns true for matching validator', () => {
      const schema = Schema.resolve('#/definitions/constant/anyOf/0')
      expect(new Constant('string').matches(schema)).toBe(true)
    })

    test('returns false for different schema', () => {
      const schema = Schema.resolve('#/definitions/constant/anyOf/0')
      expect(new Constant(true).matches(schema)).toBe(false)
    })
  })
})
