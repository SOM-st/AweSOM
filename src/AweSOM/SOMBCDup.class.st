Class {
	#name : #SOMBCDup,
	#superclass : #SOMBytecode,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCDup >> interpret: interp [
	interp doDup
]

{ #category : #accessing }
SOMBCDup >> stackDepth [

	^ 1
]
