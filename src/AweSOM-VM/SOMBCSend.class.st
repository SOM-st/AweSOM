Class {
	#name : #SOMBCSend,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBCSend >> selector [

	^ self literalValue
]

{ #category : #'as yet unclassified' }
SOMBCSend >> stackDepth [

	^ self selector string numArgs negated + 1
]
