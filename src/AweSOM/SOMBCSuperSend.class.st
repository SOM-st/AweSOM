Class {
	#name : #SOMBCSuperSend,
	#superclass : #SOMBCSend,
	#category : #'AweSOM-Interpreter'
}

{ #category : #interpreting }
SOMBCSuperSend >> interpret: interp [
	interp doSuperSend
]
