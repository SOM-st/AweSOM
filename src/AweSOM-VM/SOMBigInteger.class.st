Class {
	#name : #SOMBigInteger,
	#superclass : #SOMNumber,
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'as yet unclassified' }
SOMBigInteger >> primSlash: other [

	^ universe newNumber: self number // other number
]
