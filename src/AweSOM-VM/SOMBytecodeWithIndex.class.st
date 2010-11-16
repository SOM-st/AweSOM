Class {
	#name : #SOMBytecodeWithIndex,
	#superclass : #SOMBytecode,
	#instVars : [
		'index'
	],
	#category : #'AweSOM-Interpreter'
}

{ #category : #'instance creation' }
SOMBytecodeWithIndex class >> in: mgenc index: i [

	^ (self in: mgenc)
		index: i;
		yourself.
]

{ #category : #accessing }
SOMBytecodeWithIndex >> index [
	^ index
]

{ #category : #accessing }
SOMBytecodeWithIndex >> index: anObject [
	index := anObject
]

{ #category : #constant }
SOMBytecodeWithIndex >> length [

	^ 2
]

{ #category : #accessing }
SOMBytecodeWithIndex >> literalValue [
	self mgenc ifNil: [^ nil].
	^ self mgenc literals at: self index
]

{ #category : #'as yet unclassified' }
SOMBytecodeWithIndex >> printOn: stream [

	"stream
		nextPut: $<;
		nextPutAll: self printName;
		nextPutAll: ' index: ';
		print: self index; 
		nextPut: $>."
	stream
		nextPut: $<;
		nextPutAll: self printName;
		nextPutAll: ' index: ';
		print: self index;
		nextPutAll: ' value: ';
		print: self literalValue;
		nextPut: $>.
]
