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
SOMInteger >> primSlash: other [

	^ universe newNumber: self number // other number
]

{ #category : #primitives }
SOMInteger >> primatRandom [

	^ universe newNumber: self number atRandom.
]
