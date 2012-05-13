Class {
	#name : #SOMMethodTest,
	#superclass : #TestCaseWithUniverse,
	#instVars : [
		'method'
	],
	#category : #'AweSOM-VM-Test'
}

{ #category : #'as yet unclassified' }
SOMMethodTest >> createMethod: source [

	method := ((SOMMethodParser
		inUniverse: universe
		onSource: source) apply: #method) assembleIn: universe.
]

{ #category : #'as yet unclassified' }
SOMMethodTest >> test01MaxStackSize [

	self createMethod: 'x = ()'.
	self assert: method maxStackDepth equals: 1.
	self createMethod: 'x = (1. 2. ''abc''. #def)'.
	self assert: method maxStackDepth equals: 1.
]

{ #category : #'as yet unclassified' }
SOMMethodTest >> test02MaxStackSize [

	self createMethod: 'x = (1+2)'.
	self assert: method maxStackDepth equals: 2.
]

{ #category : #'as yet unclassified' }
SOMMethodTest >> test03MaxStackSize [

	self createMethod: 'x: a = ( self a: 3 b: a)'.
	self assert: method maxStackDepth equals: 3.
]
