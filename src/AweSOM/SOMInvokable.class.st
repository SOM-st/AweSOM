Class {
	#name : #SOMInvokable,
	#superclass : #SOMObject,
	#instVars : [
		'somSignature',
		'somHolder',
		'somNumberOfArguments'
	],
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'instance creation' }
SOMInvokable class >> inUniverse: universe named: squeakSymbol numArgs: numArgs [ 
	| instance |
	instance := self inUniverse: universe.
	squeakSymbol ifNotNil: [ instance somSignature: (universe newSymbol: squeakSymbol) ].
	instance numberOfArguments: numArgs.
	^ instance
]

{ #category : #initialization }
SOMInvokable >> initialize [
	super initialize.
	somNumberOfArguments := self universe newNumber: 0
]

{ #category : #invoking }
SOMInvokable >> invokeInFrame: frame [
	self subclassResponsibility.
]

{ #category : #accessing }
SOMInvokable >> numberOfArguments [
	^ somNumberOfArguments number
]

{ #category : #accessing }
SOMInvokable >> numberOfArguments: args [ 
	somNumberOfArguments := universe newNumber: args
]

{ #category : #accessing }
SOMInvokable >> printOn: stream [

	self somSignature = universe globalNil
		ifTrue: [^ stream nextPutAll: '<anonymous SOMMethod>'].
	
	stream
		nextPut: $<;
		nextPutAll: self class name; space;
		nextPutAll: (self somHolder = universe globalNil
							ifTrue: [ 'nil' ]
							ifFalse: [ self somHolder somName symbol asString]);
		nextPutAll: '>>#';
		nextPutAll:( self somSignature
							ifNil: [ 'nil' ]
							ifNotNil: [ self somSignature string ]);
		nextPut: $>.
]

{ #category : #accessing }
SOMInvokable >> somHolder [
	^ somHolder
]

{ #category : #accessing }
SOMInvokable >> somHolder: anObject [ 
	somHolder := anObject
]

{ #category : #accessing }
SOMInvokable >> somSignature [
	^ somSignature
]

{ #category : #accessing }
SOMInvokable >> somSignature: anObject [ 
	somSignature := anObject
]
