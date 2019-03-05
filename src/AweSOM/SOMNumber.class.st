Class {
	#name : #SOMNumber,
	#superclass : #SOMObject,
	#instVars : [
		'number'
	],
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'as yet unclassified' }
SOMNumber class >> create: number in: universe [

	number isFloat ifTrue: [^ SOMDouble inUniverse: universe new: number].
	number isInteger ifTrue: [
		^ number <=  SOMInteger maxInt
			ifTrue: [SOMInteger inUniverse: universe new: number]
			ifFalse: [SOMBigInteger inUniverse: universe new: number]].

	Error signal: 'The value: ', number asString, ' is not one of the supported numbers'
]

{ #category : #'as yet unclassified' }
SOMNumber class >> inUniverse: universe new: int [

	^ (self inUniverse: universe)
		basicNumber: int;
		yourself
]

{ #category : #accessing }
SOMNumber >> basicNumber: n [

	"Private!"
	number := n
]

{ #category : #testing }
SOMNumber >> isSOMNumber [

	^ true
]

{ #category : #accessing }
SOMNumber >> number [
	^ number
]

{ #category : #primitives }
SOMNumber >> primAnd: other [
	^ universe newNumber: (self number bitAnd: other number)
]

{ #category : #primitives }
SOMNumber >> primEqual: other [

	^ universe newBool: 
		((other isKindOf: SOMNumber)
			and: [self number = other number])
]

{ #category : #primitives }
SOMNumber >> primLowerThan: other [
	
	^ universe newBool: self number < other number
]

{ #category : #primitives }
SOMNumber >> primMinus: other [
	^ universe newNumber: self number - other number
]

{ #category : #primitives }
SOMNumber >> primPercent: other [
	^ universe newNumber: self number \\ other number
]

{ #category : #primitives }
SOMNumber >> primPlus: other [
	^ universe newNumber: self number + other number
]

{ #category : #primitives }
SOMNumber >> primSlashSlash: other [

	^ universe newNumber: self number asFloat / other number
]

{ #category : #primitives }
SOMNumber >> primStar: other [
	^ universe newNumber: self number * other number
]

{ #category : #primitives }
SOMNumber >> primasString [

	^ self universe newString: self number asString
]

{ #category : #primitives }
SOMNumber >> primsqrt [
	^ universe newNumber: self number sqrt
]

{ #category : #printing }
SOMNumber >> printOn: stream [

	stream 
		nextPutAll: 'SOMNumber(';
		print: self number;
		nextPut: $).
]
