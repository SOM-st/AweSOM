Class {
	#name : #SOMBCPushBlock,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #'as yet unclassified' }
SOMBCPushBlock >> isPushBlock [
	^ true
]

{ #category : #'as yet unclassified' }
SOMBCPushBlock >> stackDepth [

	^ 1
]
