Class {
	#name : #SOMBCPushConstant,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBCPushConstant >> const [
	^ self literalValue
]

{ #category : #accessing }
SOMBCPushConstant >> stackDepth [

	^ 1
]
