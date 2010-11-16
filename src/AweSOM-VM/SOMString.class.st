Class {
	#name : #SOMString,
	#superclass : #SOMObject,
	#instVars : [
		'string'
	],
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'instance creation' }
SOMString class >> inUniverse: universe string: string [

	^ (self inUniverse: universe)
		string: string;
		yourself.
]

{ #category : #comparing }
SOMString >> = other [
	^ (other isKindOf: SOMString) and: [
		self string = other string]
]

{ #category : #testing }
SOMString >> hash [
	^ self string hash
]

{ #category : #primitives }
SOMString >> primEqual: other [
	^ universe newBool: self = other
]

{ #category : #primitives }
SOMString >> primasSymbol [
	
	^ self universe newSymbol: self string
]

{ #category : #primitives }
SOMString >> primconcatenate: somString [ 
	
	^ self universe newString: self string, somString string
]

{ #category : #primitives }
SOMString >> primhashcode [
	^ universe newNumber: self hash
]

{ #category : #primitives }
SOMString >> primlength [
	^ universe newNumber: self string size
]

{ #category : #primitives }
SOMString >> primobjectSize [
	
	"add 32-bit aligned size of string to basic objectSize"
	^ (super primobjectSize) primPlus:
		(self universe newNumber: ((self string size / 4) ceiling * 4))
]

{ #category : #primitives }
SOMString >> primprimSubstringFrom: start to: end [ 
	
	^ self universe newString: 
		(self string copyFrom: start number to: end number)
]

{ #category : #printing }
SOMString >> printOn: stream [

	stream 
		nextPutAll: self className;
		nextPut: $(;
		nextPutAll: self string printString;
		nextPut: $).
]

{ #category : #accessing }
SOMString >> string [
	^ string
]

{ #category : #accessing }
SOMString >> string: anObject [
	string := anObject
]
