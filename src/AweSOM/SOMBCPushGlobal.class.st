Class {
	#name : #SOMBCPushGlobal,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBCPushGlobal >> global [
	^ self literalValue
]

{ #category : #interpreting }
SOMBCPushGlobal >> interpret: interp [
	interp doPushGlobal
]

{ #category : #accessing }
SOMBCPushGlobal >> stackDepth [

	^ 1
]
