Class {
	#name : #SOMBCPushArgument,
	#superclass : #SOMBytecodeWithIndexAndContextIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCPushArgument >> interpret: interp [
	interp doPushArgument
]

{ #category : #accessing }
SOMBCPushArgument >> stackDepth [

	^ 1
]
