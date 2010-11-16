Class {
	#name : #SOMMethodParser2,
	#superclass : #SOMParser2,
	#instVars : [
		'bracketCount',
		'mgenc',
		'clazzName'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #'method parsing' }
SOMMethodParser2 >> assignation [ =

	spaces assignment+:vars evaluation
		[vars size timesRepeat: [mgenc bcDup]]
		[vars reverseDo: [:v | mgenc lookUpAndPop: v in: universe]]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> assignment [ =

	spaces identifier:v token(':=')
		[mgenc addLiteralIfAbsent: v]
		-> [v]
]

{ #category : #helper }
SOMMethodParser2 >> binaryChar [ =

	char:x ?[self isBinaryChar: x] -> [x]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> binaryId [ =

	binaryOp:op spaces identifier:arg
		-> [{op. {arg}}]
]

{ #category : #messages }
SOMMethodParser2 >> binaryMsg [ :isSuper =

	spaces binaryOp:sel binaryMsgArg
		[mgenc
			emitSend: sel
			isSuper: isSuper]
]

{ #category : #messages }
SOMMethodParser2 >> binaryMsgArg [ =

	primary:s (unaryMsg(s) unaryMsg(false)* | empty)
]

{ #category : #'method parsing' }
SOMMethodParser2 >> binaryOp [ =

	<binaryChar binaryChar*>
]

{ #category : #blocks }
SOMMethodParser2 >> blockArgPattern [ =

	(token(':') identifier:arg [mgenc addArgumentIfAbsent: arg])*
	(?[mgenc arguments isEmpty] empty | token('|'))
]

{ #category : #'method parsing' }
SOMMethodParser2 >> blockBody [ :seenPeriod =

	token('^') expression
		[mgenc isBlockMethod
			ifTrue: [mgenc bcReturnNonLocal]
			ifFalse: [mgenc bcReturnLocal]]
		[mgenc finished]
	(token('.') | empty)
|	~~token(']')
		[seenPeriod
			ifTrue: [mgenc bytecode removeLast]
			ifFalse: [mgenc bcReturnLocal; finished]]
|	~~token(')') [mgenc returnSelf; finished]
|	expression (token('.') [mgenc bcPop] blockBody(true) | empty)
|	empty [mgenc isFinished ifFalse: [mgenc returnSelf]]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> blockContents [ =

	(locals | empty) blockBody(false)
]

{ #category : #accessing }
SOMMethodParser2 >> clazzName [
	^ clazzName
]

{ #category : #accessing }
SOMMethodParser2 >> clazzName: anObject [
	clazzName := anObject
]

{ #category : #'method parsing' }
SOMMethodParser2 >> countBracket [ :x =
	
	[x = $( ifTrue: [bracketCount := bracketCount + 1]]
	[x = $) ifTrue: [bracketCount := bracketCount - 1]]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> evaluation [ =

	primary:isSuper (messageSend(isSuper) | empty)
]

{ #category : #'method parsing' }
SOMMethodParser2 >> expression [ =

	assignation | evaluation
]

{ #category : #helper }
SOMMethodParser2 >> fakeCgenc [

	cgenc := SOMClassGenerationContext new
			theName: #Dummy;
			yourself.
]

{ #category : #helper }
SOMMethodParser2 >> fakeMgenc [

	mgenc := (SOMMethodGenerationContext named: #dummy)
		somHolder: cgenc;
		yourself
]

{ #category : #initialization }
SOMMethodParser2 >> initialize [

	super initialize.
	bracketCount := 0.
]

{ #category : #helper }
SOMMethodParser2 >> isBinaryChar: char [

	^ #($~ $& $| $* $/ $\ $+ $- $= $> $< $, $@ $%) includes: char
]

{ #category : #'method parsing' }
SOMMethodParser2 >> keywordId [ =

	keywordPart:x spaces identifier:args
	(keywordPart:x2 spaces identifier:args2 -> [{x2. args2}])*:xs
		[xs
			inject: {x. {args}}
			into: [:all :ea | {all first, ea first. all second , {ea second}}]]
]

{ #category : #messages }
SOMMethodParser2 >> keywordMsg [ :isSuper =

	spaces keywordPart:k keywordMsgArg
	(spaces keywordPart:k2 keywordMsgArg -> [k2])*:ks
		[mgenc
			emitSend: (ks inject: k into: [:all :ea | all , ea])
			isSuper: isSuper]
]

{ #category : #messages }
SOMMethodParser2 >> keywordMsgArg [ =

	binaryMsgArg binaryMsg(false)*
]

{ #category : #'method parsing' }
SOMMethodParser2 >> keywordPart [ =

	spaces <identifier:x $:>
]

{ #category : #'method parsing' }
SOMMethodParser2 >> literal [ =

	spaces (literalSymbol
	| 	literalString
	|	literalNumber):l
		[mgenc bcPushConstant: l]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> literalNumber [ =

	($+ -> [1] | $- -> [-1] | empty -> [1]):sign digit+:s
		[s
			inject: ''
			into: [:concat :ea | concat , ea asString]]:n
		-> [universe newNumber: n asNumber * sign]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> literalString [ =

	$' <($' $' | ~$' char)*>:s $'
		-> [universe newString: s]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> literalSymbol [ =

	(token('#') (<(identifier:i $:)+> | identifier | <binaryChar+>)):sym
		-> [universe newSymbol: sym]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> locals [ =

	token('|') (spaces identifier)*:vars token('|')
		[vars do: [:var | mgenc addLocalIfAbsent: var]]
		-> [vars]
]

{ #category : #messages }
SOMMethodParser2 >> messageSend [ :isSuper =

	unaryMsg(isSuper) unaryMsg(false)* binaryMsg(false)* (keywordMsg(false) | empty)
|	binaryMsg(isSuper)	binaryMsg(false)* (keywordMsg(false) | empty)
|	keywordMsg(isSuper)
]

{ #category : #'method parsing' }
SOMMethodParser2 >> method [ =

	methodName token('=')
	(	methodBodyPrimitive
	|	token('(')
		(blockContents
			[mgenc isFinished ifFalse: [mgenc bcPop; returnSelf]]
			[self shouldReadSources ifTrue: [OMeta2Fail signal]]
		| recordSource)
		token(')')
	)
		-> [mgenc]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> methodBodyPrimitive [ =

	token('primitive')
		[mgenc isPrimitive: true]
		[mgenc fakeSource: '^ SOMPrimitives ', self cgenc theName , mgenc combineSelectorAndArgs]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> methodName [ =

	spaces (keywordId | binaryId | unaryId):nameAndArgs
	[mgenc := (SOMMethodGenerationContext named: nameAndArgs first asSymbol)
		arguments: {'self'} , nameAndArgs second;
		holder: cgenc;
		yourself]
]

{ #category : #accessing }
SOMMethodParser2 >> methodParser [

	^ super methodParser
		mgenc: (SOMMethodGenerationContext blockIn: mgenc);
		yourself
]

{ #category : #accessing }
SOMMethodParser2 >> mgenc [
	^ mgenc
]

{ #category : #accessing }
SOMMethodParser2 >> mgenc: anObject [
	mgenc := anObject
]

{ #category : #blocks }
SOMMethodParser2 >> nestedBlock [ =

	token('[')
		[mgenc isBlockMethod: true]
		blockArgPattern
		blockContents
	token(']')
	[mgenc isFinished ifFalse: [mgenc bcReturnLocal; finished]]
		-> [mgenc]
]

{ #category : #helper }
SOMMethodParser2 >> newInteger: n [

	^ universe newNumber: n
]

{ #category : #blocks }
SOMMethodParser2 >> parseNestedBlock [

	| parser result blockMethod |
	parser := self methodParser.
	result := parser apply: #nestedBlock.
	blockMethod := result assembleIn: universe.
	mgenc bcPushBlock: blockMethod.
	input := parser input.
	^ result			
			
]

{ #category : #'method parsing' }
SOMMethodParser2 >> primary [ =

	variable:v -> [v = 'super']
|	token('(') expression token(')') -> [false]
|	~~token('[') parseNestedBlock -> [false]
|	literal() -> [false]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> recordSource [ =

	char:x ?[x ~= $) or: [bracketCount > 0]] countBracket(x) recordSource:xs
		[mgenc fakeSource: x asString , xs]
		-> [mgenc fakeSource]
| 	empty -> [String new]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> unaryId [ =

	identifier:x ~$: -> [{x. {}}]
]

{ #category : #messages }
SOMMethodParser2 >> unaryMsg [ :isSuper =

	spaces unaryId:selAndArg
		[mgenc
			emitSend: selAndArg first
			isSuper: isSuper]
]

{ #category : #'method parsing' }
SOMMethodParser2 >> variable [ =

	spaces identifier:i
		[mgenc lookupVariable: i in: universe]
		-> [i]
]
