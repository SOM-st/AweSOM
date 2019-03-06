Class {
	#name : #SOMBCReturnLocal,
	#superclass : #SOMBytecode,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCReturnLocal >> interpret: interp [
	interp doReturnLocal
]
