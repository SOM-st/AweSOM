Class {
	#name : #SOMBCPop,
	#superclass : #SOMBytecode,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCPop >> interpret: interp [
	interp doPop
]

{ #category : #accessing }
SOMBCPop >> stackDepth [

	^ -1
]
