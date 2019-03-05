Class {
	#name : #SOMBigInteger,
	#superclass : #SOMNumber,
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'as yet unclassified' }
SOMBigInteger >> primSlash: other [

	^ universe newNumber: self number // other number
]

{ #category : #primitives }
SOMBigInteger >> primas32BitSignedValue [
	| val hiBitSet |
	val := number.
	hiBitSet := (val bitAnd: 16r80000000) ~~ 0.
	val := val bitAnd: 16r7FFFFFFF.
	hiBitSet ifTrue: [
		val := 0 - (val bitXor: 16r7FFFFFFF) - 1 ].
	^ universe newNumber: val
]

{ #category : #primitives }
SOMBigInteger >> primas32BitUnsignedValue [

	^ universe newNumber: (self number bitAnd: 16rFFFFFFFF)
]

{ #category : #accessing }
SOMBigInteger >> setDefaultClass [
	somClass := universe globalIntegerClass
]
