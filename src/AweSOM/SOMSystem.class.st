Class {
	#name : #SOMSystem,
	#superclass : #SOMObject,
	#category : #'AweSOM-CoreObjects'
}

{ #category : #constants }
SOMSystem class >> successCode [

	^ 0
]

{ #category : #primitives }
SOMSystem >> primexit: errorCode [
	
	errorCode number ~= SOMSystem successCode ifTrue: [
		self universe interpreter printStack].
	self universe quit: errorCode.
]

{ #category : #primitives }
SOMSystem >> primfullGC [

	universe heap collectGarbage.
	^ universe globalTrue
]

{ #category : #primitives }
SOMSystem >> primglobal: globalSymbol [

	^ self universe
		globalAt: globalSymbol symbol
		ifAbsent: [self universe globalNil].
]

{ #category : #primitives }
SOMSystem >> primglobal: globalSymbol put: globalValue [ 
	
	self universe
		globalAt: globalSymbol symbol
		put: globalValue
]

{ #category : #primitives }
SOMSystem >> primload: clazzName [

	| loadedClazz |
	loadedClazz := self universe loadSOMClass: clazzName string.
	^ loadedClazz
		ifNil: [self universe globalNil]
		ifNotNil: [loadedClazz].
]

{ #category : #primitives }
SOMSystem >> primprintNewline [
	
	self universe outStream lf; flush.
]

{ #category : #primitives }
SOMSystem >> primprintString: somString [
	
	self universe outStream
		nextPutAll: somString string;
		flush.
]

{ #category : #primitives }
SOMSystem >> primtime [
	
	^ universe newNumber: Time millisecondClockValue
]
