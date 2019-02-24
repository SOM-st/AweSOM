Class {
	#name : #SOMNumberTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-VM-Test'
}

{ #category : #'as yet unclassified' }
SOMNumberTest >> testIntegerVsBigInteger [

	| n |
	n := universe newNumber: SOMInteger maxInt.
	self assert: n class equals: SOMInteger.
	n := universe newNumber: SOMInteger maxInt + 1.
	self assert: n class equals: SOMBigInteger.
]
