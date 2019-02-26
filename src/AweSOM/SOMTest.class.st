Class {
	#name : #SOMTest,
	#superclass : #TestCase,
	#category : #'AweSOM-VM-Test'
}

{ #category : #tests }
SOMTest >> exec: aTest [
	| universe |
	universe := SOMUniverse new.
	universe start: {'TestSuite/TestHarness.som'. aTest}.
	self assert: universe exitCode equals: 0.

]

{ #category : #tests }
SOMTest >> setUp [
	SOMUniverse classPaths: SOMTools basicInterpreterTestClassPath
]

{ #category : #tests }
SOMTest >> testArray [
	self exec: 'Array'

]

{ #category : #tests }
SOMTest >> testBlock [
	self exec: 'Block'

]

{ #category : #tests }
SOMTest >> testClassLoading [
	self exec: 'ClassLoading'

]

{ #category : #tests }
SOMTest >> testClassStructure [
	self exec: 'ClassStructure'

]

{ #category : #tests }
SOMTest >> testClosure [
	self exec: 'Closure'

]

{ #category : #tests }
SOMTest >> testCoercion [
	self exec: 'Coercion'

]

{ #category : #tests }
SOMTest >> testCompilerReturn [
	self exec: 'CompilerReturn'

]

{ #category : #tests }
SOMTest >> testDoesNotUnderstand [
	self exec: 'DoesNotUnderstand'

]

{ #category : #tests }
SOMTest >> testDouble [
	self exec: 'Double'

]

{ #category : #tests }
SOMTest >> testEmpty [
	self exec: 'Empty'

]

{ #category : #tests }
SOMTest >> testGlobal [
	self exec: 'Global'

]

{ #category : #tests }
SOMTest >> testHash [
	self exec: 'Hash'

]

{ #category : #tests }
SOMTest >> testInteger [
	self exec: 'Integer'

]

{ #category : #tests }
SOMTest >> testPreliminary [
	self exec: 'Preliminary'

]

{ #category : #tests }
SOMTest >> testReflection [
	self exec: 'Reflection'

]

{ #category : #tests }
SOMTest >> testSelfBlock [
	self exec: 'SelfBlock'

]

{ #category : #tests }
SOMTest >> testSet [
	self exec: 'Set'

]

{ #category : #tests }
SOMTest >> testSpecialSelectors [
	self exec: 'SpecialSelectors'

]

{ #category : #tests }
SOMTest >> testString [
	self exec: 'String'

]

{ #category : #tests }
SOMTest >> testSuper [
	self exec: 'Super'

]

{ #category : #tests }
SOMTest >> testSymbol [
	self exec: 'Symbol'

]

{ #category : #tests }
SOMTest >> testSystem [
	self exec: 'System'

]

{ #category : #tests }
SOMTest >> testVector [
	self exec: 'Vector'

]
