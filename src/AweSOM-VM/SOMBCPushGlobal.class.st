Class {
	#name : #SOMBCPushGlobal,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBCPushGlobal >> global [
	^ self literalValue
]

{ #category : #'as yet unclassified' }
SOMBCPushGlobal >> stackDepth [

	^ 1
]
