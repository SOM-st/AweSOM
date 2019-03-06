Class {
	#name : #SOMBCPopField,
	#superclass : #SOMBytecodeWithFieldIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCPopField >> interpret: interp [
	interp doPopField
]

{ #category : #accessing }
SOMBCPopField >> stackDepth [

	^ -1
]
