Class {
	#name : #ParseBytecodeTest,
	#superclass : #ParseClassTest,
	#instVars : [
		'bytecode'
	],
	#category : #'AweSOM-Compiler-Test'
}

{ #category : #assertion }
ParseBytecodeTest >> assertBcAt: idx is: bcType [

	self assert: ((bytecode at: idx) isKindOf: bcType).
]

{ #category : #assertion }
ParseBytecodeTest >> assertLiteralAt: idx accessor: accessorSelector equals: expected [

	| literal inner |
	literal := (bytecode at: idx) literalValue.
	self
		assert: (literal respondsTo: accessorSelector)
		description: 'wrong kind of SOMObject?'.
	inner := literal perform: accessorSelector.
	self assert: inner equals: expected.
]

{ #category : #assertion }
ParseBytecodeTest >> assertLiteralAt: idx equals: expected [

	| literal |
	literal := (bytecode at: idx) literalValue.
	self assert: literal equals: expected.
]

{ #category : #running }
ParseBytecodeTest >> parserClass [

	^ SOMMethodParser
]

{ #category : #'as yet unclassified' }
ParseBytecodeTest >> setUpParser: source [

	super setUpParser: source.
	parser
		fakeCgenc;
		fakeMgenc.
]

{ #category : #running }
ParseBytecodeTest >> setUpParser: source andApply: rule [

	super setUpParser: source andApply: rule.
	(result respondsTo: #bytecode) ifTrue: [
		bytecode := result bytecode]
]

{ #category : #running }
ParseBytecodeTest >> setUpParser: source withMgencAndApply: rule [

	self setUpParser: source.
	result := parser apply: rule.
	(result respondsTo: #bytecode) ifTrue: [
		bytecode := result bytecode]
]

{ #category : #tests }
ParseBytecodeTest >> test01EmptyMethod [

	self setUpParser: 'x = ()' andApply: #method.
	self assertNoFail: result.
	self assert: result locals isEmpty.
	self assert: result arguments size equals: 1. "self"
	self assert: result literals isEmpty.
	self assert: result bytecodeCount equals: 4.
	self assertBcAt: 2 is: SOMBCReturnLocal.
]

{ #category : #tests }
ParseBytecodeTest >> test02Constant [

	self setUpParser: 'x = (1)' andApply: #method.
	self assertNoFail: result.
	self assert: result literals size equals: 1.
	self assert: result bytecodeCount equals: 7.
	self assert: result literals first number equals: 1.
]

{ #category : #tests }
ParseBytecodeTest >> test03aReturnObject [

	self setUpParser: 'x = (^1.)' andApply: #method.
	self assertNoFail: result.
	self assert: result bytecodeCount equals: 3.
	self assert: result bytecode size equals: 2
]

{ #category : #tests }
ParseBytecodeTest >> test03bReturnObject [

	self setUpParser: 'x = (^1)' andApply: #method.
	self assertNoFail: result.
	self assert: result bytecodeCount equals: 3.
	self assert: result bytecode size equals: 2
]

{ #category : #tests }
ParseBytecodeTest >> test04MultipleExpressions [

	self setUpParser: 'x = (1. 2. 3. ^self)' andApply: #method.
	self assertNoFail: result.
	self assert: result isFinished.
	self assert: result bytecodeCount equals: 13.
	self assert: result bytecode size equals: 8.
	self assertBcAt: 8 is: SOMBCReturnLocal.
]

{ #category : #tests }
ParseBytecodeTest >> test05UnaryMessage [

	self setUpParser: 'x = (1 test)' andApply: #method.
	self assertNoFail: result.
	self assert: result bytecode size equals: 5.
	self assertLiteralAt: 2 equals: 'test'.
	self assert: result bytecodeCount equals: 9.

]

{ #category : #tests }
ParseBytecodeTest >> test06MultipleUnaryMessages [

	self setUpParser: 'x = (1 test test2 test3)' andApply: #method.
	self assertNoFail: result.
	self assert: result bytecode size equals: 7.
	self assertLiteralAt: 3 equals: 'test2'.
	self assertLiteralAt: 4 equals: 'test3'.
	self assert: result bytecodeCount equals: 13.

]

{ #category : #tests }
ParseBytecodeTest >> test07BinaryMessage [

	self setUpParser: 'x = (1 + 2)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertLiteralAt: 2 accessor: #number equals: 2.
	self assertLiteralAt: 3 equals: '+'.
]

{ #category : #tests }
ParseBytecodeTest >> test08BinaryUnaryMessage [

	self setUpParser: 'x = (1 + 2 test)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertLiteralAt: 2 accessor: #number equals: 2.
	self assertLiteralAt: 3 equals: 'test'.
	self assertLiteralAt: 4 equals: '+'.
	self assert: result bytecode size equals: 7.
]

{ #category : #tests }
ParseBytecodeTest >> test09MultipleBinaryMessages [

	self setUpParser: 'x = (1 + 2 ++ 3)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertLiteralAt: 2 accessor: #number equals: 2.
	self assertLiteralAt: 4 accessor: #number equals: 3.
	self assertLiteralAt: 3 equals: '+'.
	self assertLiteralAt: 5 equals: '++'.
]

{ #category : #tests }
ParseBytecodeTest >> test10aKeywordMessage [

	self setUpParser: 'x = (1 a: 2)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertLiteralAt: 2 accessor: #number equals: 2.
	self assertLiteralAt: 3 equals: 'a:'.
]

{ #category : #tests }
ParseBytecodeTest >> test10bKeywordMessage [

	self setUpParser: 'x = (1 a: 2 b: 3)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertLiteralAt: 2 accessor: #number equals: 2.
	self assertLiteralAt: 3 accessor: #number equals: 3.
	self assertLiteralAt: 4 equals: 'a:b:'.
]

{ #category : #tests }
ParseBytecodeTest >> test10cKeywordMessage [

	self setUpParser: 'x = (1 a: self test)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertLiteralAt: 3 equals: 'test'.
	self assertLiteralAt: 4 equals: 'a:'.
]

{ #category : #tests }
ParseBytecodeTest >> test10dKeywordMessage [

	self setUpParser: 'x = (self test a: 1)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 3 accessor: #number equals: 1.
	self assertLiteralAt: 2 equals: 'test'.
	self assertLiteralAt: 4 equals: 'a:'.
]

{ #category : #tests }
ParseBytecodeTest >> test11KeywordBinaryMessage [

	self setUpParser: 'x = (1 + 2 a: 3 b: 4)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertLiteralAt: 2 accessor: #number equals: 2.
	self assertLiteralAt: 3 equals: '+'.
	self assertLiteralAt: 4 accessor: #number equals: 3.
	self assertLiteralAt: 5 accessor: #number equals: 4.
	self assertLiteralAt: 6 equals: 'a:b:'.
]

{ #category : #tests }
ParseBytecodeTest >> test12KeywordBinaryUnaryMessage [

	self setUpParser: 'x = (1 + 2 test a: 3 test2 b: 4 test3.)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertLiteralAt: 2 accessor: #number equals: 2.
	self assertLiteralAt: 3 equals: 'test'.
	self assertLiteralAt: 4 equals: '+'.
	self assertLiteralAt: 5 accessor: #number equals: 3.
	self assertLiteralAt: 6 equals: 'test2'.
	self assertLiteralAt: 7 accessor: #number equals: 4.
	self assertLiteralAt: 8 equals: 'test3'.
	self assertLiteralAt: 9 equals: 'a:b:'.
]

{ #category : #tests }
ParseBytecodeTest >> test13ParenthesisExpr [

	self setUpParser: 'x = ((1 + 2) test)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertLiteralAt: 2 accessor: #number equals: 2.
	self assertLiteralAt: 3 equals: '+'.
	self assertLiteralAt: 4 equals: 'test'.
]

{ #category : #tests }
ParseBytecodeTest >> test14aSuperSimple [

	self setUpParser: 'x = (super test)' andApply: #method.
	self assertNoFail: result.
	self assert: bytecode first index equals: 1. "self"
	self assertLiteralAt: 2 equals: 'test'.
	self assertBcAt: 2 is: SOMBCSuperSend.
]

{ #category : #tests }
ParseBytecodeTest >> test14bSuperMsgAsArg [

	self setUpParser: 'x = (1 a: super test)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assert: bytecode second index equals: 1. "self"
	self assertLiteralAt: 3 equals: 'test'.
	self assertBcAt: 3 is: SOMBCSuperSend.
	self assertLiteralAt: 4 equals: 'a:'.
	self assertBcAt: 4 is: SOMBCSend.
]

{ #category : #tests }
ParseBytecodeTest >> test15SimpleBlock [

	self setUpParser: 'x = ([])' andApply: #method.
	self assertNoFail: result.
	self assertBcAt: 1 is: SOMBCPushBlock.
]

{ #category : #tests }
ParseBytecodeTest >> test16SimpleBlockWithContent [

	self setUpParser: 'x = ([1])' andApply: #method.
	self assertNoFail: result.
	self assertBcAt: 1 is: SOMBCPushBlock.
	self assertNoFail: bytecode first mgenc.
]

{ #category : #tests }
ParseBytecodeTest >> test17SimpleBlockWithContent [

	self setUpParser: '[1]' withMgencAndApply: #nestedBlock.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertBcAt: 2 is: SOMBCReturnLocal.
	self assert: bytecode size equals: 2.
]

{ #category : #tests }
ParseBytecodeTest >> test18BlockReturn [

	self setUpParser: '[^1]' withMgencAndApply: #nestedBlock.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 1.
	self assertBcAt: 2 is: SOMBCReturnNonLocal.
	self assert: bytecode size equals: 2.
]

{ #category : #tests }
ParseBytecodeTest >> test19BlockArguments [

	self setUpParser: '[:a :abc | 1]' withMgencAndApply: #nestedBlock.
	self assertNoFail: result.
	self assert: result arguments size = 2.
	self assert: (result arguments includes: 'a').
	self assert: (result arguments includes: 'abc').
]

{ #category : #tests }
ParseBytecodeTest >> test20MultipleArguments [

	self setUpParser: '[''abc'' println. ^nil]' withMgencAndApply: #nestedBlock.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #string equals: 'abc'.
	self assertLiteralAt: 2 equals: 'println'.
	self assertBcAt: 4 is: SOMBCPushGlobal.
	self assertLiteralAt: 4 equals: 'nil'.
	self assertBcAt: 5 is: SOMBCReturnNonLocal.
]

{ #category : #tests }
ParseBytecodeTest >> test21aSimpleSymbol [

	self setUpParser: 'x=(#someSymbol)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #symbol equals: #someSymbol.
]

{ #category : #tests }
ParseBytecodeTest >> test21bSymbol [

	self setUpParser: 'x=(#someSymbol:a:)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #symbol equals: #someSymbol:a:.
]

{ #category : #tests }
ParseBytecodeTest >> test22aSimpleAssignment [

	self setUpParser: 'x=(| a | a := 2)' andApply: #method.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 2.
	self assertBcAt: 2 is: SOMBCDup.
	self assertBcAt: 3 is: SOMBCPopLocal.
	self assert: bytecode third index equals: 1.
	self assert: bytecode third contextIndex equals: 1.
]

{ #category : #tests }
ParseBytecodeTest >> test22bMultipleAssignments [

	self setUpParser: 'x=(| a b | b := a := field := 2)'.
	parser cgenc addFields: {'field'}.
	bytecode := (parser apply: #method) bytecode.
	self assertNoFail: result.
	self assertLiteralAt: 1 accessor: #number equals: 2.
	self assertBcAt: 2 is: SOMBCDup.
	self assertBcAt: 3 is: SOMBCDup.
	self assertBcAt: 4 is: SOMBCDup.
	self assertBcAt: 5 is: SOMBCPopField.
	self assert: bytecode fifth index equals: 3. "literal indexof field"
	self assert: bytecode sixth index equals: 1. "local index"
	self assert: bytecode seventh index equals: 2. "local index"
]

{ #category : #tests }
ParseBytecodeTest >> test23MultipleAssignments [

	self setUpParser: 'x: a=(1 + a)' andApply: #method.
	self assertNoFail: result.
	self assertBcAt: 2 is: SOMBCPushArgument.
	self assert: bytecode second index equals: 2. "1 is self"
	self assert: bytecode second contextIndex equals: 1.
]

{ #category : #tests }
ParseBytecodeTest >> test24aSelfLookupWithBlock [

	| blockBc |
	self setUpParser: 'x: a=( [self].)' andApply: #method.
	self assertNoFail: result.
	blockBc := (result literals at: bytecode first index ) bytecodes.
	self assert: (blockBc first isKindOf: SOMBCPushArgument).
	self assert: blockBc first index equals: 1.
	self assert: blockBc first contextIndex equals: 2.
]

{ #category : #tests }
ParseBytecodeTest >> test24bLocalAndArgumentLookupWithBlock [

	| innerBlockBc firstInnerBlock |
	self setUpParser: 'x: a y: b=([ |x y| [b + y] ])' andApply: #method.
	self assertNoFail: result.
	firstInnerBlock := (result literals at: bytecode first index) bytecodes first.
	innerBlockBc := (firstInnerBlock mgenc literals at: firstInnerBlock index) bytecodes.
	self assert: (innerBlockBc first isKindOf: SOMBCPushArgument).
	self assert: innerBlockBc first index equals: 3. "first is self, second a, third b"
	self assert: innerBlockBc first contextIndex equals: 3.
	self assert: (innerBlockBc second isKindOf: SOMBCPushLocal).
	self assert: innerBlockBc second index equals: 2.
	self assert: innerBlockBc second contextIndex equals: 2.
]

{ #category : #tests }
ParseBytecodeTest >> test25BlockInBlock [

	self setUpParser: '[ [] ]' andApply: #nestedBlock.
	self assertNoFail: result.
	self assertBcAt: 1 is: SOMBCPushBlock.
]

{ #category : #tests }
ParseBytecodeTest >> test26returnArgument [

	self setUpParser: 'x: a = (^a)' andApply: #method.
	self assertNoFail: result.
	self assertBcAt: 1 is: SOMBCPushArgument.
	self assertBcAt: 2 is: SOMBCReturnLocal.
]

{ #category : #tests }
ParseBytecodeTest >> test27StoreIntoArgument [

	self setUpParser: 'x: a = (a := 1)' andApply: #method.
	self assertNoFail: result.
	self assertBcAt: 1 is: SOMBCPushConstant.
	self assertBcAt: 2 is: SOMBCDup.
	self assertBcAt: 3 is: SOMBCPopArgument.
]

{ #category : #tests }
ParseBytecodeTest >> test28GlobalsTest [

	self setUpParser: 'x = (^ EmptyTest, DoubleTest, HashTest)' andApply: #method.
	self assertNoFail: result.
	"self halt."
	"self assertBcAt: 1 is: SOMBCPushConstant."
]

{ #category : #tests }
ParseBytecodeTest >> test29do [

	self setUpParser: 'do: block = ( self doIndexes: [ :i | block value: (self at: i) ] )' andApply: #method.
	self assertNoFail: result.
	"self halt."
	"self assertBcAt: 1 is: SOMBCPushConstant."
]
