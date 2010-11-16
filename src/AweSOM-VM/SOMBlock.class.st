Class {
	#name : #SOMBlock,
	#superclass : #SOMObject,
	#instVars : [
		'somBlockMethod',
		'somContext'
	],
	#category : #'AweSOM-CoreObjects'
}

{ #category : #accessing }
SOMBlock >> cacheEvaluationMethodWithParameters: numParams [ 
	| signature replaceIndex evaluationMethod |
	signature := self evaluationMethodWithParameters: numParams.

	"check if block class already has an evaluationMethod for the given parameter"
	evaluationMethod := self somClass lookupInvokable: signature.
	evaluationMethod class = SOMBlockEvaluation ifTrue: [ ^ self ].

	"add to instance methods or replace existing primitives"
	evaluationMethod ifNotNil: 
		[ replaceIndex := self somClass somInstanceInvokables indexOf: evaluationMethod ].
	evaluationMethod := self createEvalutationMethodWithParameters: numParams.
	replaceIndex ifNil: [ ^ self somClass somInstanceInvokables add: evaluationMethod ].
	self somClass somInstanceInvokables 
		at: replaceIndex
		put: evaluationMethod
]

{ #category : #accessing }
SOMBlock >> createEvalutationMethodWithParameters: numParams [ 
	^ (SOMBlockEvaluation inUniverse: self universe)
		somSignature: (universe newSymbol: (self evaluationMethodWithParameters: numParams));
		numberOfArguments: numParams;
		yourself
]

{ #category : #accessing }
SOMBlock >> evaluationMethodWithParameters: numParams [
	numParams = 0 ifTrue: [^ #value].
	"append with: for each parameter except the first"
	^ (2 to: numParams) inject: #value: into: [ :sig :each | sig, #with:]
	
]

{ #category : #primitives }
SOMBlock >> primrestart [
	universe interpreter somFrame
		bytecodeIndex: 1;
		resetStackPointer
]

{ #category : #accessing }
SOMBlock >> somBlockMethod [
	^ somBlockMethod
]

{ #category : #accessing }
SOMBlock >> somBlockMethod: anObject [ 
	somBlockMethod := anObject.
	self cacheEvaluationMethodWithParameters: anObject numberOfArguments
]

{ #category : #accessing }
SOMBlock >> somContext [
	^ somContext
]

{ #category : #accessing }
SOMBlock >> somContext: anObject [ 
	somContext := anObject
]
