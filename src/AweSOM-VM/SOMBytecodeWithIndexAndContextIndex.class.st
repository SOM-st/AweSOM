Class {
	#name : #SOMBytecodeWithIndexAndContextIndex,
	#superclass : #SOMBytecodeWithIndex,
	#instVars : [
		'contextIndex'
	],
	#category : #'AweSOM-Interpreter'
}

{ #category : #'instance creation' }
SOMBytecodeWithIndexAndContextIndex class >> in: mgenc index: idx contextIndex: ctxIdx [

	^ (self in: mgenc)
		index: idx;
		contextIndex: ctxIdx;
		yourself.
]

{ #category : #accessing }
SOMBytecodeWithIndexAndContextIndex >> contextIndex [
	^ contextIndex
]

{ #category : #accessing }
SOMBytecodeWithIndexAndContextIndex >> contextIndex: anObject [
	contextIndex := anObject
]

{ #category : #constant }
SOMBytecodeWithIndexAndContextIndex >> length [

	^ 3
]

{ #category : #'as yet unclassified' }
SOMBytecodeWithIndexAndContextIndex >> printOn: stream [
	
	stream
		nextPut: $<;
		nextPutAll: self printName;
		nextPutAll: ' index: ';
		print: self index;
		nextPutAll: ' context: ';
		print: self contextIndex;
		nextPut: $>.
]
