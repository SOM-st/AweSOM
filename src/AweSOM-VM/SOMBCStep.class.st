Class {
	#name : #SOMBCStep,
	#superclass : #SOMBytecode,
	#instVars : [
		'originalBytecode',
		'owningFrames'
	],
	#category : #'AweSOM-Interpreter'
}

{ #category : #accessing }
SOMBCStep >> originalBytecode [
	^ originalBytecode
]

{ #category : #accessing }
SOMBCStep >> originalBytecode: anObject [
	originalBytecode := anObject
]

{ #category : #accessing }
SOMBCStep >> owningFrames [
	^ owningFrames
]

{ #category : #accessing }
SOMBCStep >> owningFrames: anObject [
	owningFrames := anObject
]
