Class {
	#name : #SOMBCPushConstant,
	#superclass : #SOMBytecodeWithIndex,
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBCPushConstant >> const [
	^ self literalValue
]

{ #category : #interpreting }
SOMBCPushConstant >> interpret: interp [
	interp doPushConstant
]

{ #category : #accessing }
SOMBCPushConstant >> stackDepth [

	^ 1
]
