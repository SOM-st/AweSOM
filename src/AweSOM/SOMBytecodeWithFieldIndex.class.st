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

{ #category : #'as yet unclassified' }
SOMBytecodeWithFieldIndex >> inferFieldIndexFrom: object [

	| fieldName |
	fieldName := object universe newSymbol: self literalValue.
	self fieldIndex: (object indexOfInstanceField: fieldName).
]
