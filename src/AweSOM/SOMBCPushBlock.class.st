Class {
	#name : #SOMBCPushBlock,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBCPushBlock >> isPushBlock [
	^ true
]

{ #category : #accessing }
SOMBCPushBlock >> stackDepth [

	^ 1
]
