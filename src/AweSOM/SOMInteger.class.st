Class {
	#name : #SOMInteger,
	#superclass : #SOMNumber,
	#category : #'AweSOM-CoreObjects'
}

{ #category : #constant }
SOMInteger class >> maxInt [

	"(2 raisedTo: 31) - 1"
	^ 2147483647
]

{ #category : #primitives }
SOMInteger >> primGreaterThanGreaterThanGreaterThan: other [
	^ universe newNumber: self number >> other number
]

{ #category : #primitives }
SOMInteger >> primLowerThanLowerThan: other [

	^ universe newNumber: self number << other number
]

{ #category : #primitives }
SOMInteger >> primSlash: other [

	^ universe newNumber: self number // other number
]

{ #category : #primitives }
SOMInteger >> primas32BitSignedValue [
	self flag: 'todo'.
	^ universe newNumber: self number
]

{ #category : #primitives }
SOMInteger >> primas32BitUnsignedValue [
	self flag: 'todo'.
	^ universe newNumber: self number
]

{ #category : #primitives }
SOMInteger >> primatRandom [

	^ universe newNumber: self number atRandom.
]

{ #category : #primitives }
SOMInteger >> primbitXor: other [

	^ universe newNumber: (self number bitXor: other number)
]

{ #category : #primitives }
SOMInteger >> primrem: other [

	^ universe newNumber: (self number rem: other number)
]

{ #category : #accessing }
SOMInteger >> setDefaultClass [
	somClass := universe globalIntegerClass
]
