Class {
	#name : #SOMBCPushBlock,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCPushBlock >> interpret: interp [
	interp doPushBlock
]

{ #category : #accessing }
SOMBCPushBlock >> isPushBlock [
	^ true
]

{ #category : #accessing }
SOMBCPushBlock >> stackDepth [

	^ 1
]
