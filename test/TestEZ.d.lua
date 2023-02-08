export type ExpectationEnd = {
	a: (typeName: string) -> ExpectationEnd,
	an: (typeName: string) -> ExpectationEnd,
	ok: () -> ExpectationEnd,
	equal: (otherValue: any) -> ExpectationEnd,
	near: (otherValue: number, limit: number) -> ExpectationEnd,
	throw: (messageSubstring: string?) -> ExpectationEnd,
	never: () -> ExpectationEnd,

	to: () -> ExpectationEnd,
	be: () -> ExpectationEnd,
	been: () -> ExpectationEnd,
	have: () -> ExpectationEnd,
	was: () -> ExpectationEnd,
	at: () -> ExpectationEnd,
}

export type ExpectationBody = {
	a: ExpectationEnd & ExpectationBody & ExpectationPass,
	an: ExpectationEnd & ExpectationBody & ExpectationPass,
	ok: ExpectationEnd & ExpectationBody & ExpectationPass,
	equal: ExpectationEnd & ExpectationBody & ExpectationPass,
	near: ExpectationEnd & ExpectationBody & ExpectationPass,
	throw: ExpectationEnd & ExpectationBody & ExpectationPass,
	never: ExpectationEnd & ExpectationBody & ExpectationPass,
}

export type ExpectationPass = {
	to: ExpectationEnd & ExpectationBody & ExpectationPass,
	be: ExpectationEnd & ExpectationBody & ExpectationPass,
	been: ExpectationEnd & ExpectationBody & ExpectationPass,
	have: ExpectationEnd & ExpectationBody & ExpectationPass,
	was: ExpectationEnd & ExpectationBody & ExpectationPass,
	at: ExpectationEnd & ExpectationBody & ExpectationPass,
}

declare function expect(value: any): ExpectationBody & ExpectationPass

-- declare function a(typeName: string): Expectation
-- declare function an(typeName: string): Expectation
-- declare function ok(): Expectation
-- declare function equal(otherValue: any): Expectation
-- declare function near(otherValue: number, limit: number): Expectation
-- declare function throw(messageSubstring: string?): Expectation
-- declare function never(): Expectation
-- declare function to(): Expectation
-- declare function be(): Expectation
-- declare function been(): Expectation
-- declare function have(): Expectation
-- declare function was(): Expectation
-- declare function at(): Expectation

-- export type LifecycleHooks = {
-- 	beforeAll: (callback: () -> ()) -> (),
-- 	beforeEach: (callback: () -> ()) -> (),
-- 	afterAll: (callback: () -> ()) -> (),
-- 	afterEach: (callback: () -> ()) -> (),
-- }

declare function beforeAll(callback: () -> ()): ()
declare function beforeEach(callback: () -> ()): ()
declare function afterAll(callback: () -> ()): ()
declare function afterEach(callback: () -> ()): ()

declare function describeFOCUS(phrase: string, callback: () -> ()): ()
declare function describeSKIP(phrase: string, callback: () -> ()): ()
declare function describe(phrase: string, callback: () -> ()): ()
declare function itFOCUS(phrase: string, callback: () -> ()): ()
declare function itSKIP(phrase: string, callback: () -> ()): ()
declare function itFIXME(phrase: string, callback: () -> ()): ()
declare function it(phrase: string, callback: () -> ()): ()
