Class {
	#name : #SOMBCPushLocal,
	#superclass : #SOMBytecodeWithIndexAndContextIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCPushLocal >> interpret: interp [
	interp doPushLocal
]

{ #category : #accessing }
SOMBCPushLocal >> stackDepth [

	^ 1
]
