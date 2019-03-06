Class {
	#name : #SOMBCPushField,
	#superclass : #SOMBytecodeWithFieldIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCPushField >> interpret: interp [
	interp doPushField
]

{ #category : #accessing }
SOMBCPushField >> stackDepth [

	^ 1
]
