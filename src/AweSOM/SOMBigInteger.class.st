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
	self flag: 'todo'.
	^ universe newNumber: self number
]

{ #category : #primitives }
SOMBigInteger >> primas32BitUnsignedValue [
	self flag: 'todo'.
	^ universe newNumber: self number
]

{ #category : #accessing }
SOMBigInteger >> setDefaultClass [
	somClass := universe globalIntegerClass
]
