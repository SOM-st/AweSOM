Class {
	#name : #SOMBytecodeWithFieldIndex,
	#superclass : #SOMBytecodeWithIndex,
	#instVars : [
		'fieldIndex'
	],
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBytecodeWithFieldIndex >> fieldIndex [
	^ fieldIndex
]

{ #category : #accessing }
SOMBytecodeWithFieldIndex >> fieldIndex: anObject [
	fieldIndex := anObject
]
