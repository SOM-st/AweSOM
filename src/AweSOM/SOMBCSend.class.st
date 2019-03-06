Class {
	#name : #SOMBCSend,
	#superclass : #SOMBytecodeWithIndex,
	#instVars : [
		'numArgs'
	],
	#category : #'AweSOM-Interpreter'
}

{ #category : #'as yet unclassified' }
SOMBCSend class >> in: mgenc index: idx numArgs: numArgs [
	^ (super in: mgenc index: idx)
		numArgs: numArgs
]

{ #category : #interpreting }
SOMBCSend >> interpret: interp [
	interp doSend
]

{ #category : #accessing }
SOMBCSend >> numArgs [
	^ numArgs
]

{ #category : #accessing }
SOMBCSend >> numArgs: anInt [
	numArgs := anInt
]

{ #category : #accessing }
SOMBCSend >> selector [

	^ self literalValue
]

{ #category : #accessing }
SOMBCSend >> stackDepth [

	^ self selector string numArgs negated + 1
]
