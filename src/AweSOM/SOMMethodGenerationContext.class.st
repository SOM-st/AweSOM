Class {
	#name : #SOMMethodGenerationContext,
	#superclass : #Object,
	#instVars : [
		'signature',
		'holder',
		'outer',
		'arguments',
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
	idx := self literals identityIndexOf: literal.
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
		nextPutAll: self combineSelectorAndArgs; cr])
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
SOMMethodGenerationContext >> bcPopArgumentIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPopArgument in: self index: idx contextIndex: ctxIdx).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPopField: fieldName [

	| idx fieldIdx bc |
	self assert: (self hasField: fieldName).
	idx := self addLiteralIfAbsent: fieldName.
	fieldIdx := holder fieldIndex: fieldName.
	bc := SOMBCPopField in: self index: idx.
	bc fieldIndex: fieldIdx.
	^ self bytecode add: bc.

]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPopLocalIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPopLocal in: self index: idx contextIndex: ctxIdx).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushArgumentIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPushArgument in: self index: idx contextIndex: ctxIdx).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushBlock: method [
	
	| idx |
	idx := self addLiteralIfAbsent: method.
	^ self bytecode add: (SOMBCPushBlock in: self index: idx).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushConstant: const [
	| literalIndex |
	literalIndex := self addLiteralIfAbsent: const.
	self bytecode add: (SOMBCPushConstant in: self index: literalIndex).
	^ literalIndex
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushField: fieldName [

	| idx fieldIdx bc |
	self assert: [holder isNil or: [self hasField: fieldName]].
	idx := self addLiteralIfAbsent: fieldName.
	fieldIdx := holder fieldIndex: fieldName.
	bc := SOMBCPushField in: self index: idx.
	bc fieldIndex: fieldIdx.
	^ self bytecode add: bc.
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushGlobal: global [

	| idx |
	idx := self addLiteralIfAbsent: global.
	^ self bytecode add: (SOMBCPushGlobal in: self index: idx).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcPushLocalIndex: idx ctxIndex: ctxIdx [

	self bytecode add: (SOMBCPushLocal in: self index: idx contextIndex: ctxIdx).
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

	| idx |
	self assert: selector isSymbol.
	idx := self addLiteralIfAbsent: selector.
	^ self bytecode add: (SOMBCSend in: self index: idx numArgs: selector numArgs).
]

{ #category : #bytecode }
SOMMethodGenerationContext >> bcSuperSend: selector [

	| idx |
	self assert: selector isSymbol.
	idx := self addLiteralIfAbsent: selector.
	^ self bytecode add: (SOMBCSuperSend in: self index: idx numArgs: selector numArgs).
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
	parts := (self signature substrings: ':')
		with: args
		collect: [:sig :arg | sig , ': ' , arg].
	"Neeeeed join!!!"
	^ (parts inject: '' into: [:all :ea | all , ' ' , ea]) trimBoth.
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

{ #category : #lookup }
SOMMethodGenerationContext >> findVariable: varName context: ctx ifFound: aBlock [
	| idx isArgument |
	isArgument := false.

	idx := locals indexOf: varName.
	idx = 0 ifTrue: [
		idx := arguments indexOf: varName.
		idx = 0
			ifTrue: [
				outer ifNil: [ ^ false ]
				ifNotNil: [
					^ outer findVariable: varName context: ctx + 1 ifFound: aBlock ]]
			ifFalse: [ isArgument := true ]].
	
	^ aBlock value: idx value: ctx value: isArgument
]

{ #category : #accessing }
SOMMethodGenerationContext >> finished [

	isFinished := true
]

{ #category : #lookup }
SOMMethodGenerationContext >> hasField: field [
	^ holder hasField: field
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
SOMMethodGenerationContext >> removeLastBytecode [
	self bytecode removeLast.
]

{ #category : #bytecode }
SOMMethodGenerationContext >> returnSelf [

	self bcPushArgumentIndex: 1 ctxIndex: 1.
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

{ #category : #accessing }
SOMMethodGenerationContext >> updateLiteralAt: index with: literal [
	self literals at: index put: literal
]
