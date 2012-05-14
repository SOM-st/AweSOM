Class {
	#name : #ParseClassTest,
	#superclass : #TestCaseWithUniverse,
	#instVars : [
		'parser',
		'result'
	],
	#category : #'AweSOM-Compiler-Test'
}

{ #category : #assertion }
ParseClassTest >> assertNoFail: parseResult [

	"parser printPosition"
	self deny: (parseResult isKindOf: OMetaFail).
]

{ #category : #running }
ParseClassTest >> parserClass [

	^ universe classParser
]

{ #category : #running }
ParseClassTest >> setUp [
	super setUp.
	parser := nil.
]

{ #category : #running }
ParseClassTest >> setUpParser: source [

	parser := self parserClass
		inUniverse: universe
		onSource: source.
]

{ #category : #running }
ParseClassTest >> setUpParser: source andApply: rule [

	self setUpParser: source.
	result := parser apply: rule.
]

{ #category : #tests }
ParseClassTest >> test01SimpleClassDef [

	self setUpParser: 'Class1 = ()'.
	self assertNoFail: parser start.
	self assert: parser cgenc theName equals: #Class1.
	self assert: parser cgenc superName equals: #Object.
]

{ #category : #tests }
ParseClassTest >> test02ClassInstVars [

	self setUpParser: 'Class1 = ( | a b cdef |)'.
	self assertNoFail: parser start.
	self
		assert: parser cgenc instanceFields
		equals: {'a'. 'b'. 'cdef'} asOrderedCollection.
]

{ #category : #tests }
ParseClassTest >> test03RecognizeSpaces [

	self setUpParser: '"bla " Class1 = ()'.
	self assertNoFail: parser start.
	self assert: parser cgenc theName equals: #Class1.
]

{ #category : #tests }
ParseClassTest >> test04aRecognizeMethodUnary [
	| methods |
	self setUpParser: 'Class1 = ( abc = ())'.
	self assertNoFail: parser start.
	methods := parser cgenc instanceMethods.
	self 
		assert: methods size
		equals: 1.
	self 
		assert: methods first signature
		equals: #abc
]

{ #category : #tests }
ParseClassTest >> test04bRecognizeMethodBinary [
	| methods |
	self setUpParser: 'Class1 = ( & a = ())'.
	self assertNoFail: parser start.
	methods := parser cgenc instanceMethods.
	self 
		assert: methods size
		equals: 1.
	self 
		assert: methods first signature
		equals: #&
]

{ #category : #tests }
ParseClassTest >> test04cRecognizeKeywordMethod [
	| methods |
	self setUpParser: 'Class1 = ( a: x abc: y = ())'.
	self assertNoFail: parser start.
	methods := parser cgenc instanceMethods.
	self 
		assert: methods size
		equals: 1.
	self 
		assert: methods first signature
		equals: #a:abc:
]

{ #category : #tests }
ParseClassTest >> test05RecognizeMultipleMethods [

	| methods |
	self setUpParser: 'Class1 = ( a: x abc: y = ()
     & bool = ()
	test = ()
)'.
	self assertNoFail: parser start.
	methods := parser cgenc instanceMethods.
	self assert: methods size equals: 3.
]

{ #category : #tests }
ParseClassTest >> test06RecognizeClassMethods [

	| methods |
	self setUpParser: 'Class1 = ( ---- test = () )'.
	self assertNoFail: parser start.
	self assert: parser cgenc isClassSide.
	methods := parser cgenc classMethods.
	self assert: methods size equals: 1.
]

{ #category : #tests }
ParseClassTest >> test06aRecognizeClassSide [

	self setUpParser: 'Class1 = ( ---- | a | test = () x = (1 +2))'.
	self assertNoFail: parser start.
	self assert: parser cgenc isClassSide.
	self assert: parser cgenc classMethods size equals: 2.
	self assert: parser cgenc classFields size equals: 1.
]

{ #category : #tests }
ParseClassTest >> test06bRecognizeInstanceAndClassSide [

	self setUpParser: 'Class1 = ( | a | y = (1) ---- | a | test = ())'.
	self assertNoFail: parser start.
	self assert: parser cgenc instanceMethods size equals: 1.
	self assert: parser cgenc instanceFields size equals: 1.
	self assert: parser cgenc classMethods size equals: 1.
	self assert: parser cgenc classFields size equals: 1.
]

{ #category : #tests }
ParseClassTest >> test07AccessInstanceVars [

	| mgenc bc |
	self setUpParser: 'Class1 = (|a| y = (^a))'.
	self assertNoFail: parser start.
	mgenc := parser cgenc instanceMethods first.
	bc := mgenc bytecode.
	self assert: (bc first isKindOf: SOMBCPushField).
	self assert: (bc second isKindOf: SOMBCReturnLocal).
]
