Class {
	#name : #SOMBCPopArgument,
	#superclass : #SOMBytecodeWithIndexAndContextIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCPopArgument >> interpret: interp [
	interp doPopArgument
]

{ #category : #accessing }
SOMBCPopArgument >> stackDepth [

	^ -1
]
