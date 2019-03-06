Class {
	#name : #SOMBCReturnNonLocal,
	#superclass : #SOMBytecode,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCReturnNonLocal >> interpret: interp [
	interp doReturnNonLocal
]
