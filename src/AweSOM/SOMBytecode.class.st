Class {
	#name : #SOMBytecode,
	#superclass : #Object,
	#instVars : [
		'mgenc'
	],
	#classInstVars : [
		'instructionName'
	],
	#category : #'AweSOM-Interpreter'
}

{ #category : #'instance creation' }
SOMBytecode class >> in: methodGenerationContext [

	^ self new
		mgenc: methodGenerationContext;
		yourself.
]

{ #category : #interpreting }
SOMBytecode >> interpret: interp [
	Error signal: 'Needs to be overridden'
]

{ #category : #accessing }
SOMBytecode >> isPushBlock [
	^ false
]

{ #category : #constant }
SOMBytecode >> length [

	^ 1
]

{ #category : #accessing }
SOMBytecode >> mgenc [
	^ mgenc
]

{ #category : #accessing }
SOMBytecode >> mgenc: anObject [
	mgenc := anObject
]

{ #category : #printing }
SOMBytecode >> printName [

	"'SOMBC' size = 6, SOMBCDup --> DUP"
	| name |
	name := self class name.
	^ (name copyFrom: 6 to: name size) asUppercase
]

{ #category : #printing }
SOMBytecode >> printOn: stream [

	stream
		nextPut: $<;
		nextPutAll: self printName;
		nextPut: $>.
]

{ #category : #accessing }
SOMBytecode >> stackDepth [

	^ 0
]
