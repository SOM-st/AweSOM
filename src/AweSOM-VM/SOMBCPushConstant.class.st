Class {
	#name : #SOMBCPushConstant,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBCPushConstant >> const [
	^ self literalValue
]

{ #category : #'as yet unclassified' }
SOMBCPushConstant >> stackDepth [

	^ 1
]
