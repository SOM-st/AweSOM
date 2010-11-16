Class {
	#name : #SOMMethodGenerationContext,
	#superclass : #Object,
	#instVars : [
		'signature',
		'holder',
		'outer',
		'arguments',
		'fakeSource',
		'isPrimitive',
		'onClassSide',
		'locals',
		'literals',
		'bytecode',
		'isFinished',
		'isBlock'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #'as yet unclassified' }
SOMMethodGenerationContext class >> blockIn: mgenc [ 
	^ self new
		somHolder: mgenc somHolder;
		outer: mgenc;
		yourself
]

{ #category : #'as yet unclassified' }
SOMMethodGenerationContext class >> named: n [

	^ self new
		signature: n asSymbol;
		yourself
]

{ #category : #accessing }
SOMMethodGenerationContext >> addArgumentIfAbsent: argName [

	(self arguments includes: argName) ifTrue: [^ false].
	self arguments add: argName.
	^ true
]

{ #category : #accessing }
SOMMethodGenerationContext >> addLiteralIfAbsent: literal [

	| idx |
	idx := self literals indexOf: literal.
	idx isZero ifFalse: [^ idx].
	self literals add: literal.
	^ self literals size
]

{ #category : #accessing }
SOMMethodGenerationContext >> addLocalIfAbsent: varName [

	(self locals includes: varName) ifTrue: [^ false].
	self locals add: varName.
	^ true
]

{ #category : #accessing }
SOMMethodGenerationContext >> arguments [
	^ arguments
]

{ #category : #accessing }
SOMMethodGenerationContext >> arguments: anObject [
	arguments := anObject
]

{ #category : #assembling }
SOMMethodGenerationContext >> assemble: holderClass [

	| compileClass |
	compileClass := self onClassSide
		ifTrue: [holderClass class]
		ifFalse: [holderClass].
	compileClass compile: (String streamContents: [:s | s
		nextPutAll: self combineSelectorAndArgs; cr;
		nextPutAll: self fakeSource])
]

{ #category : #assembling }
SOMMethodGenerationContext >> assembleIn: universe [

	^ self isPrimitive
		ifTrue: [SOMPrimitive
			inUniverse: universe
			named: self signature
			numArgs: arguments size]
		ifFalse: [ (SOMMethod
			inUniverse: universe
			named: self signature
			numArgs: self arguments size
			numLocals: self locals size
			maxStackDepth: self computeMaxStackDepth
			bytecodes: bytecode asArray
			holder: universe globalNil
			lexicalContext: universe globalNil)
				assignLexicalContexts ].
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcDup [
	

	^ self bytecode add: (SOMBCDup in: self)
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcHalt [
	self bytecode add: SOMBCHalt new.
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPop [

	self bytecode add: (SOMBCPop in: self).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPopArgumentIndex: i1 ctxIdx: i2 [

	self bytecode add: (SOMBCPopArgument in: self index: i1 contextIndex: i2).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPopArgumentIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPopArgument in: self index: idx contextIndex: ctxIdx).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPopField: fieldName [

	| idx |
	idx := self addLiteralIfAbsent: fieldName.
	^ self bytecode add: (SOMBCPopField in: self index: idx)
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPopLocalIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPopLocal in: self index: idx contextIndex: ctxIdx).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushArgumentIdx: i1 ctxIdx: i2 [

	self bytecode add: (SOMBCPushArgument in: self index: i1 contextIndex: i2).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushBlock: method [
	
	| idx |
	idx := self addLiteralIfAbsent: method.
	^ self bytecode add: (SOMBCPushBlock in: self index: idx).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushConstant: const [
	self addLiteralIfAbsent: const.
	self bytecode add: (SOMBCPushConstant in: self index: (self literalIndex: const)).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushField: fieldName [

	| idx |
	idx := self addLiteralIfAbsent: fieldName.
	^ self bytecode add: (SOMBCPushField in: self index: idx).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushGlobal: global [

	self addLiteralIfAbsent: global.
	^ self bytecode add: (SOMBCPushGlobal in: self index: (self literalIndex: global)).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushLocalIndex: i1 ctxIndex: i2 [

	self bytecode add: (SOMBCPushLocal in: self index: i1 contextIndex: i2).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcReturnLocal [

	^ self bytecode add: (SOMBCReturnLocal in: self).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcReturnNonLocal [

	^ self bytecode add: (SOMBCReturnNonLocal in: self).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcSend: selector [

	self addLiteralIfAbsent: selector asSymbol.
	^ self bytecode add: (SOMBCSend in: self index: (self literalIndex: selector)).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcSuperSend: selector [

	self addLiteralIfAbsent: selector asSymbol.
	^ self bytecode add: (SOMBCSuperSend in: self index: (self literalIndex: selector)).
]

{ #category : #accessing }
SOMMethodGenerationContext >> bytecode [
	^ bytecode
]

{ #category : #accessing }
SOMMethodGenerationContext >> bytecode: anObject [
	bytecode := anObject
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bytecodeCount [
	^ self bytecode 
		inject: 0
		into: [ :sum :ea | sum + ea length ]
]

{ #category : #printing }
SOMMethodGenerationContext >> bytecodeString [

	^ String streamContents: [:s |
		self
			bytecodeStringTab: 0
			stream: s].
]

{ #category : #printing }
SOMMethodGenerationContext >> bytecodeStringTab: tabWidth stream: s [

	self bytecode do: [:ea |
		tabWidth timesRepeat: [s tab].
		ea printOn: s.
		s cr.
		(ea isKindOf: SOMBCPushBlock) ifTrue: [
			(ea mgenc literals at: ea index) bytecodes first mgenc
				bytecodeStringTab: tabWidth+1
				stream: s.]].
]

{ #category : #assembling }
SOMMethodGenerationContext >> combineSelectorAndArgs [

	| parts args |
	args := self arguments allButFirst. "First is self"
	args ifEmpty: [^ self signature].
	args size = 1 ifTrue: [^ self signature , ' ' , args first].
	parts := (self signature subStrings: ':')
		with: args
		collect: [:sig :arg | sig , ': ' , arg].
	"Neeeeed join!!!"
	^ (parts inject: '' into: [:all :ea | all , ' ' , ea]) withBlanksTrimmed.
]

{ #category : #'stack size' }
SOMMethodGenerationContext >> computeMaxStackDepth [

	| depth |
	depth := 0.
	^ self bytecode inject: 0 into: [:maxDepth :ea |
		depth := depth + ea stackDepth.
		depth > maxDepth
			ifTrue: [depth]
			ifFalse: [maxDepth]].
]

{ #category : #bytecode }
SOMMethodGenerationContext >> emitSend: selector isSuper: isSuper [

	isSuper
		ifTrue: [self bcSuperSend: selector]
		ifFalse: [self bcSend: selector]
]

{ #category : #accessing }
SOMMethodGenerationContext >> fakeSource [
	^ fakeSource
]

{ #category : #accessing }
SOMMethodGenerationContext >> fakeSource: anObject [
	fakeSource := anObject
]

{ #category : #accessing }
SOMMethodGenerationContext >> finished [

	isFinished := true
]

{ #category : #accessing }
SOMMethodGenerationContext >> holder [
	^ holder
]

{ #category : #accessing }
SOMMethodGenerationContext >> holder: anObject [
	holder := anObject
]

{ #category : #initialize }
SOMMethodGenerationContext >> initialize [

	super initialize.
	self
		isPrimitive: false;
		onClassSide: false;
		locals: OrderedCollection new;
		literals: OrderedCollection new;
		bytecode: OrderedCollection new;
		arguments: OrderedCollection new;
		isFinished: false;
		isBlockMethod: false.
]

{ #category : #accessing }
SOMMethodGenerationContext >> isBlockMethod [
	^ isBlock
]

{ #category : #accessing }
SOMMethodGenerationContext >> isBlockMethod: bool [
	isBlock := bool
]

{ #category : #accessing }
SOMMethodGenerationContext >> isFinished [

	^ isFinished
]

{ #category : #accessing }
SOMMethodGenerationContext >> isFinished: bool [

	isFinished := bool
]

{ #category : #accessing }
SOMMethodGenerationContext >> isPrimitive [
	^ isPrimitive
]

{ #category : #accessing }
SOMMethodGenerationContext >> isPrimitive: anObject [
	isPrimitive := anObject
]

{ #category : #accessing }
SOMMethodGenerationContext >> literalIndex: obj [

	| idx |
	idx := self literals indexOf: obj.
	idx isZero ifTrue: [self error: 'Object not found in literal collection'].
	^ idx
]

{ #category : #accessing }
SOMMethodGenerationContext >> literals [
	^ literals
]

{ #category : #accessing }
SOMMethodGenerationContext >> literals: anObject [
	literals := anObject
]

{ #category : #accessing }
SOMMethodGenerationContext >> locals [
	^ locals
]

{ #category : #accessing }
SOMMethodGenerationContext >> locals: anObject [
	locals := anObject
]

{ #category : #variables }
SOMMethodGenerationContext >> lookUpAndPop: varName in: universe [

	| lookup |
	lookup := SOMVariableLookup
		lookupVar: (varName = 'super' ifTrue: ['self'] ifFalse: varName)
		inMethodContext: self
		inUniverse: universe.
	lookup found ifFalse: [self error: 'Cannot lookup var ' , varName , ' for pop'].
	lookup isArgument ifTrue: [
		self bcPopArgumentIndex: lookup index ctxIndex: lookup contextIndex.
		^self].
	lookup isLocal ifTrue: [
		self bcPopLocalIndex: lookup index ctxIndex: lookup contextIndex.
		^self].
	lookup isField ifTrue: [
		self bcPopField: varName.
		^self].
	self halt. "trying to store in global"
]

{ #category : #variables }
SOMMethodGenerationContext >> lookupVariable: varName in: universe [

	| lookup |
	lookup := SOMVariableLookup
		lookupVar: (varName = 'super' ifTrue: ['self'] ifFalse: varName)
		inMethodContext: self
		inUniverse: universe.
	lookup found ifFalse: [Transcript cr; show: 'Cannot lookup var'. ^ self].
	lookup isArgument ifTrue: [
		self bcPushArgumentIdx: lookup index ctxIdx: lookup contextIndex.
		^self].
	lookup isLocal ifTrue: [
		self bcPushLocalIndex: lookup index ctxIndex: lookup contextIndex.
		^self].
	lookup isField ifTrue: [
		self bcPushField: varName.
		^self].
	self bcPushGlobal: varName.
	
]

{ #category : #accessing }
SOMMethodGenerationContext >> onClassSide [
	^ onClassSide
]

{ #category : #accessing }
SOMMethodGenerationContext >> onClassSide: anObject [
	onClassSide := anObject
]

{ #category : #accessing }
SOMMethodGenerationContext >> outer [
	^ outer
]

{ #category : #accessing }
SOMMethodGenerationContext >> outer: anObject [
	outer := anObject
]

{ #category : #printing }
SOMMethodGenerationContext >> printOn: stream [


	self signature ifNil: [
		super printOn: stream.
		^ self].
	stream
		nextPutAll: '<SOMMgenc signature: ';
		nextPutAll: self signature;
		nextPut: $>.
]

{ #category : #bytecode }
SOMMethodGenerationContext >> returnSelf [

	self bcPushArgumentIdx: 1 ctxIdx: 1.
	self bcReturnLocal.
]

{ #category : #accessing }
SOMMethodGenerationContext >> signature [
	^ signature
]

{ #category : #accessing }
SOMMethodGenerationContext >> signature: anObject [
	signature := anObject
]

{ #category : #accessing }
SOMMethodGenerationContext >> somHolder [
	^ holder
]

{ #category : #accessing }
SOMMethodGenerationContext >> somHolder: anObject [ 
	holder := anObject
]
