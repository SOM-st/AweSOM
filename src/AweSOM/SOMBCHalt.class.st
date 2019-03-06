Class {
	#name : #SOMBCHalt,
	#superclass : #SOMBytecode,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCHalt >> interpret: interp [
	interp doHalt
]
