Class {
	#name : #SOMBasicInterpreterTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-VM-Test'
}

{ #category : #tests }
SOMBasicInterpreterTest >> load: className execute: methodName expect: aValue as: aType [
	| result |
	SOMUniverse classPaths: SOMTools basicInterpreterTestClassPath.
	result := SOMUniverse new start: className method: methodName.
	self assert: result equals: aValue
]

{ #category : #tests }
SOMBasicInterpreterTest >> testMethodCall1 [
	self load: 'MethodCall' execute: 'test' expect: 42 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testMethodCall2 [
	self load: 'MethodCall' execute: 'test2' expect: 42 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testSelfTestAssignSelf [
	self load: 'Self' execute: 'testAssignSelf' expect: 42 as: #SOMParseError.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testSelfTestAssignSuper [
	self load: 'Self' execute: 'testAssignSuper' expect: 42 as: #SOMParseError.
]
