Class {
	#name : #SOMBasicInterpreterTest,
	#superclass : #TestCase,
	#category : #'AweSOM-VM-Test'
}

{ #category : #asserting }
SOMBasicInterpreterTest >> assert: actual equals: aValue as: aType [
	aType = #Integer ifTrue: [
		self assert: actual number equals: aValue.
		^ self ].
	
	aType = #Double ifTrue: [
		self assert: actual number equals: aValue.
		^ self ].
	
	aType = #Class ifTrue: [
		self assert: actual somName symbol equals: aValue.
		^ self ].
	
	aType = #Symbol ifTrue: [
		self assert: actual symbol equals: aValue.
		^ self ].
	
	self fail: 'SOM Value handler missing for ', actual asString.
	
	
]

{ #category : #tests }
SOMBasicInterpreterTest >> load: className execute: methodName expect: aValue as: aType [
	| result |
	SOMUniverse classPaths: SOMTools basicInterpreterTestClassPath.
	
	[ result := SOMUniverse new start: className method: methodName. ] on: SOMParseError do: [:e | 
		aType == #SOMParseError ifFalse: [ e signal ]
	 ].
	
	aType == #SOMParseError ifFalse: [
		self assert: result equals: aValue as: aType ]
]

{ #category : #tests }
SOMBasicInterpreterTest >> testArrays1 [
	self load: 'Arrays' execute: 'testEmptyToInts' expect: 3 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testArrays2 [
	self load: 'Arrays' execute: 'testPutAllInt' expect: 5 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testArrays3 [
	self load: 'Arrays' execute: 'testPutAllNil' expect: 'Nil' as: #Class
]

{ #category : #tests }
SOMBasicInterpreterTest >> testArrays4 [
	self load: 'Arrays' execute: 'testPutAllBlock' expect: 3 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testArrays5 [
	self load: 'Arrays' execute: 'testNewWithAll' expect: 1 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining1 [
	self load: 'BlockInlining' execute: 'testNoInlining' expect: 1 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining10 [
	self load: 'BlockInlining' execute: 'testDeepNestedBlocksInInlinedIfFalse' expect: 43 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining11 [
	self load: 'BlockInlining' execute: 'testDeepDeepNestedTrue' expect: 9 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining12 [
	self load: 'BlockInlining' execute: 'testDeepDeepNestedFalse' expect: 43 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining13 [
	self load: 'BlockInlining' execute: 'testToDoNestDoNestIfTrue' expect: 2 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining2 [
	self load: 'BlockInlining' execute: 'testOneLevelInlining' expect: 1 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining3 [
	self load: 'BlockInlining' execute: 'testOneLevelInliningWithLocalShadowTrue' expect: 2 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining4 [
	self load: 'BlockInlining' execute: 'testOneLevelInliningWithLocalShadowFalse' expect: 1 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining5 [
	self load: 'BlockInlining' execute: 'testBlockNestedInIfTrue' expect: 2 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining6 [
	self load: 'BlockInlining' execute: 'testBlockNestedInIfFalse' expect: 42 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining7 [
	self load: 'BlockInlining' execute: 'testDeepNestedInlinedIfTrue' expect: 3 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining8 [
	self load: 'BlockInlining' execute: 'testDeepNestedInlinedIfFalse' expect: 42 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlockInlining9 [
	self load: 'BlockInlining' execute: 'testDeepNestedBlocksInInlinedIfTrue' expect: 5 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlocks1 [
	self load: 'Blocks' execute: 'testArg1' expect: 42 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlocks2 [
	self load: 'Blocks' execute: 'testArg2' expect: 77 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlocks3 [
	self load: 'Blocks' execute: 'testArgAndLocal' expect: 8 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testBlocks4 [
	self load: 'Blocks' execute: 'testArgAndContext' expect: 8 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testCompilerSimplification1 [
	self load: 'CompilerSimplification' execute: 'testReturnConstantSymbol' expect: 'constant' as: #Symbol
]

{ #category : #tests }
SOMBasicInterpreterTest >> testCompilerSimplification2 [
	self load: 'CompilerSimplification' execute: 'testReturnConstantInt' expect: 42 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testCompilerSimplification3 [
	self load: 'CompilerSimplification' execute: 'testReturnSelf' expect: 'CompilerSimplification' as: #Class
]

{ #category : #tests }
SOMBasicInterpreterTest >> testCompilerSimplification4 [
	self load: 'CompilerSimplification' execute: 'testReturnSelfImplicitly' expect: 'CompilerSimplification' as: #Class
]

{ #category : #tests }
SOMBasicInterpreterTest >> testCompilerSimplification5 [
	self load: 'CompilerSimplification' execute: 'testReturnArgumentN' expect: 55 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testCompilerSimplification6 [
	self load: 'CompilerSimplification' execute: 'testReturnArgumentA' expect: 44 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testCompilerSimplification7 [
	self load: 'CompilerSimplification' execute: 'testSetField' expect: 'foo' as: #Symbol
]

{ #category : #tests }
SOMBasicInterpreterTest >> testCompilerSimplification8 [
	self load: 'CompilerSimplification' execute: 'testGetField' expect: 40 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testHash [
	self load: 'Hash' execute: 'testHash' expect: 444 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testIfTrueIfFalse [
	self load: 'IfTrueIfFalse' execute: 'test' expect: 42 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testIfTrueIfFalse2 [
	self load: 'IfTrueIfFalse' execute: 'test2' expect: 33 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testIfTrueIfFalse3 [
	self load: 'IfTrueIfFalse' execute: 'test3' expect: 4 as: #Integer
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
SOMBasicInterpreterTest >> testNonLocalReturn1 [
	self load: 'NonLocalReturn' execute: 'test1' expect: 42 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testNonLocalReturn2 [
	self load: 'NonLocalReturn' execute: 'test2' expect: 43 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testNonLocalReturn3 [
	self load: 'NonLocalReturn' execute: 'test3' expect: 3 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testNonLocalReturn4 [
	self load: 'NonLocalReturn' execute: 'test4' expect: 42 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testNonLocalReturn5 [
	self load: 'NonLocalReturn' execute: 'test5' expect: 22 as: #Integer.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testNonLocalVars [
	self load: 'NonLocalVars' execute: 'testWriteDifferentTypes' expect: 3.75 as: #Double
]

{ #category : #tests }
SOMBasicInterpreterTest >> testNumberOfTests [
	| numTestMethods |
	numTestMethods := (self class methods select: [ :m | m selector beginsWith: 'test' ]) size.
	numTestMethods := numTestMethods - 1. "ignoring this method"
	self load: 'NumberOfTests' execute: 'numberOfTests' expect: numTestMethods as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testObjectCreation [
	<expectedFailure> "Currently, AweSOM is simply too slow to execute this test sensibly"
	self timeLimit: 5 seconds.
	
	self load: 'ObjectCreation' execute: 'test' expect: 1000000 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testRegressions1 [
	self load: 'Regressions' execute: 'testSymbolEquality' expect: 1 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testRegressions2 [
	self load: 'Regressions' execute: 'testSymbolReferenceEquality' expect: 1 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testReturn1 [
	self load: 'Return' execute: 'testReturnSelf' expect: 'Return' as: #Class
]

{ #category : #tests }
SOMBasicInterpreterTest >> testReturn2 [
	self load: 'Return' execute: 'testReturnSelfImplicitly' expect: 'Return' as: #Class
]

{ #category : #tests }
SOMBasicInterpreterTest >> testReturn3 [
	self load: 'Return' execute: 'testNoReturnReturnSelf' expect: 'Return' as: #Class
]

{ #category : #tests }
SOMBasicInterpreterTest >> testReturn4 [
	self load: 'Return' execute: 'testBlockReturnsImplicitlyLastValue' expect: 4 as: #Integer
]

{ #category : #tests }
SOMBasicInterpreterTest >> testSelfTestAssignSelf [
	self load: 'Self' execute: 'testAssignSelf' expect: 42 as: #SOMParseError.
]

{ #category : #tests }
SOMBasicInterpreterTest >> testSelfTestAssignSuper [
	self load: 'Self' execute: 'testAssignSuper' expect: 42 as: #SOMParseError.
]
