Class {
	#name : #SOMSymbol,
	#superclass : #SOMString,
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'instance creation' }
SOMSymbol class >> inUniverse: universe string: string [

	^ super
		inUniverse: universe
		string: string asSymbol.
]

{ #category : #testing }
SOMSymbol >> isSOMSymbol [

	^ true
]

{ #category : #primitives }
SOMSymbol >> primEqualEqual: other [
	other isSOMSymbol ifFalse: [^ self universe newBool: false].
	
	^ self universe newBool: 
	  (self symbol = other symbol
	    ifTrue: [true]
	    ifFalse: [false])
]

{ #category : #primitives }
SOMSymbol >> primasString [

	^ self universe newString: self symbol asString
]

{ #category : #accessing }
SOMSymbol >> symbol [

	^ string
]
