Class {
	#name : #ParseClassTest,
	#superclass : #TestCaseWithUniverse,
	#instVars : [
		'parser',
		'result'
	],
	#category : #'AweSOM-Compiler-Test'
}

{ #category : #running }
ParseClassTest >> parserClass [

	^ SOMClassParser
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
		onSource: source
		from: 'test'.
]

{ #category : #running }
ParseClassTest >> setUpParser: source andApply: rule [

	self setUpParser: source.
	result := parser apply: rule.
]

{ #category : #tests }
ParseClassTest >> test01SimpleClassDef [

	self setUpParser: 'Class1 = ()'.
	parser start.
	self assert: parser cgenc theName equals: #Class1.
	self assert: parser cgenc superName equals: #Object.
]

{ #category : #tests }
ParseClassTest >> test02ClassInstVars [

	self setUpParser: 'Class1 = ( | a b cdef |)'.
	parser start.
	self
		assert: parser cgenc instanceFields
		equals: {'a'. 'b'. 'cdef'} asOrderedCollection.
]

{ #category : #tests }
ParseClassTest >> test03RecognizeSpaces [

	self setUpParser: '"bla " Class1 = ()'.
	parser start.
	self assert: parser cgenc theName equals: #Class1.
]

{ #category : #tests }
ParseClassTest >> test04aRecognizeMethodUnary [
	| methods |
	self setUpParser: 'Class1 = ( abc = ())'.
	parser start.
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
	parser start.
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
	parser start.
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
	parser start.
	methods := parser cgenc instanceMethods.
	self assert: methods size equals: 3.
]

{ #category : #tests }
ParseClassTest >> test06RecognizeClassMethods [

	| methods |
	self setUpParser: 'Class1 = ( ---- test = () )'.
	parser start.
	self assert: parser cgenc isClassSide.
	methods := parser cgenc classMethods.
	self assert: methods size equals: 1.
]

{ #category : #tests }
ParseClassTest >> test06aRecognizeClassSide [

	self setUpParser: 'Class1 = ( ---- | a | test = () x = (1 +2))'.
	parser start.
	self assert: parser cgenc isClassSide.
	self assert: parser cgenc classMethods size equals: 2.
	self assert: parser cgenc classFields size equals: 1.
]

{ #category : #tests }
ParseClassTest >> test06bRecognizeInstanceAndClassSide [

	self setUpParser: 'Class1 = ( | a | y = (1) ---- | a | test = ())'.
	parser start.
	self assert: parser cgenc instanceMethods size equals: 1.
	self assert: parser cgenc instanceFields size equals: 1.
	self assert: parser cgenc classMethods size equals: 1.
	self assert: parser cgenc classFields size equals: 1.
]

{ #category : #tests }
ParseClassTest >> test07AccessInstanceVars [

	| mgenc bc |
	self setUpParser: 'Class1 = (|a| y = (^a))'.
	parser start.
	mgenc := parser cgenc instanceMethods first.
	bc := mgenc bytecode.
	self assert: (bc first isKindOf: SOMBCPushField).
	self assert: (bc second isKindOf: SOMBCReturnLocal).
]
