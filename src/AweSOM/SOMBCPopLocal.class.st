Class {
	#name : #SOMBCPopLocal,
	#superclass : #SOMBytecodeWithIndexAndContextIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCPopLocal >> interpret: interp [
	interp doPopLocal
]

{ #category : #accessing }
SOMBCPopLocal >> stackDepth [

	^ -1
]
