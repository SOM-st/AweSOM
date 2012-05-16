Class {
	#name : #SOMBCSend,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBCSend >> selector [

	^ self literalValue
]

{ #category : #accessing }
SOMBCSend >> stackDepth [

	^ self selector string numArgs negated + 1
]
