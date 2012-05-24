Class {
	#name : #SOMFrame,
	#superclass : #SOMArray,
	#instVars : [
		'somPreviousFrame',
		'somContext',
		'somMethod',
		'stackPointer',
		'bytecodeIndex',
		'localOffset'
	],
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'as yet unclassified' }
SOMFrame >> argumentAtIndex: index contextLevel: level [

	| contextFrame |
	contextFrame := self frameAtContextLevel: level.
	
	index > contextFrame somMethod numberOfArguments
		ifTrue: [self error: 'index > #args'].
		
	^ contextFrame at: index
]

{ #category : #'as yet unclassified' }
SOMFrame >> argumentAtIndex: index contextLevel: level put: object [
	| contextFrame |
	contextFrame := self frameAtContextLevel: level.
	
	index > contextFrame somMethod numberOfArguments 
		ifTrue: [self error: 'index > #args'].
		
	(self frameAtContextLevel: level)
		at: index put: object
]

{ #category : #'as yet unclassified' }
SOMFrame >> arguments [

	^ (1 to: self somMethod numberOfArguments) collect: [ :argIndex |
			self argumentAtIndex: argIndex contextLevel: 1
		]
]

{ #category : #accessing }
SOMFrame >> at: index put: object [

	object = false ifTrue: [self halt].
	^ self indexableFields at: index put: object
]

{ #category : #accessing }
SOMFrame >> bytecodeIndex [
	^ bytecodeIndex
]

{ #category : #accessing }
SOMFrame >> bytecodeIndex: anObject [
	bytecodeIndex := anObject
]

{ #category : #'as yet unclassified' }
SOMFrame >> clearPreviousFrame [
	self somPreviousFrame: self universe globalNil
]

{ #category : #'as yet unclassified' }
SOMFrame >> copyArgumentsFrom: oldFrame [

	| numArgs |
	numArgs := self somMethod numberOfArguments.
	1 to: numArgs do: [:argIndex |
		self 
			at: argIndex
			put: (oldFrame stackElementAtIndex: numArgs - argIndex + 1)].
]

{ #category : #'as yet unclassified' }
SOMFrame >> frameAtContextLevel: level [ 
	| frame |
	frame := self.
	level - 1 timesRepeat: [ frame := frame somContext ].
	^ frame
]

{ #category : #testing }
SOMFrame >> hasContext [
	^ self somContext ~= self universe globalNil
]

{ #category : #testing }
SOMFrame >> hasPreviousFrame [
	^ self somPreviousFrame ~= self universe globalNil
]

{ #category : #initialization }
SOMFrame >> initialize [
	self localOffset: 0.
	self bytecodeIndex: 0.
	self stackPointer: 0.
	self clearPreviousFrame
]

{ #category : #debugging }
SOMFrame >> installStep [

	| stepBytecodeIndex |
	"find next send or popLocal"
	stepBytecodeIndex := (bytecodeIndex to: self somMethod bytecodes size)
		detect: [:index |
			{SOMBCSend. SOMBCSuperSend. SOMBCPopLocal. SOMBCReturnLocal. SOMBCReturnNonLocal} 
				anySatisfy: [:bytecodeClass | 
					(self somMethod bytecodeAt: index) isKindOf: bytecodeClass]]
		ifNone: [
			self somPreviousFrame ~= universe globalNil
				ifTrue: [self somPreviousFrame installStep].			
			^ self ].
		
	self installStepBytecodeAt: stepBytecodeIndex.
]

{ #category : #debugging }
SOMFrame >> installStepBytecode [

	"find next bytecode or look in caller frame"
	bytecodeIndex > self somMethod bytecodes size
		ifTrue: [
			self somPreviousFrame ~= universe globalNil
				ifTrue: [self somPreviousFrame installStepBytecode].			
			^ self ].
		
	self installStepBytecodeAt: bytecodeIndex
]

{ #category : #debugging }
SOMFrame >> installStepBytecodeAt: stepBytecodeIndex [
	"replace next bytecode with step bytecode"
	
	| bytecode stepBytecode |
	bytecode := self somMethod bytecodeAt: stepBytecodeIndex.
	bytecode ifKindOf: SOMBCStep thenDo: [^ bytecode owningFrames add: self].
	stepBytecode := (SOMBCStep new)
		originalBytecode: bytecode;
		owningFrames: {self} asSet;
		yourself.
	self somMethod bytecodeAt: stepBytecodeIndex put: stepBytecode
]

{ #category : #testing }
SOMFrame >> isBootstrapFrame [
	^ self hasPreviousFrame not
]

{ #category : #'as yet unclassified' }
SOMFrame >> localAtIndex: index contextLevel: level [
	|contextFrame|
	contextFrame := self frameAtContextLevel: level.
	^ contextFrame at: (contextFrame localOffset + index)
]

{ #category : #'as yet unclassified' }
SOMFrame >> localAtIndex: index contextLevel: level put: object [
	|contextFrame|
	contextFrame := self frameAtContextLevel: level.
	contextFrame at: (contextFrame localOffset + index) put: object
]

{ #category : #accessing }
SOMFrame >> localOffset [
	^ localOffset
]

{ #category : #accessing }
SOMFrame >> localOffset: anObject [
	localOffset := anObject
]

{ #category : #'as yet unclassified' }
SOMFrame >> outerContext [
	| currentContext |
	currentContext := self.
	[ currentContext hasContext ] whileTrue: [ currentContext := currentContext somContext ].
	^ currentContext
]

{ #category : #'stack manipulation' }
SOMFrame >> pop [

	| oldPosition |
	oldPosition := self stackPointer.
	oldPosition <= (self somMethod numberOfLocals + self somMethod numberOfArguments) 
		ifTrue: [self error: 'Stack is empty'].
	self stackPointer: oldPosition - 1.
	^ self at: oldPosition
]

{ #category : #'stack manipulation' }
SOMFrame >> popN: numOfElements [

	| oldPosition |
	numOfElements = 0 ifTrue: [^ {}].
	oldPosition := self stackPointer.
	oldPosition < (self somMethod numberOfLocals + self somMethod numberOfArguments + numOfElements) 
		ifTrue: [self error: 'Stack is empty'].
	self stackPointer: oldPosition - numOfElements.
	^ self copyFrom: oldPosition - numOfElements + 1 to: oldPosition
]

{ #category : #printing }
SOMFrame >> printBytecodes [

	self printBytecodesOn: Transcript.
	Transcript endEntry
]

{ #category : #printing }
SOMFrame >> printBytecodesOn: stream [

	"prints value of stack pointer and the current bytecodes"
	stream
		nextPutAll: 'Method: ';
		nextPutAll: self somMethod asString.
	self somMethod numberOfArguments > 0 ifTrue: [
		stream
			nextPutAll: ' in object: ';
			nextPutAll: (self argumentAtIndex: 1 contextLevel: 1) asString].
	stream cr.
	self somMethod bytecodes doWithIndex: [:bc :index |
		index = (self bytecodeIndex - 1) ifTrue: [stream nextPutAll: '->'].
		stream nextPutAll: bc asString; cr.
	]
]

{ #category : #printing }
SOMFrame >> printOn: stream [

	stream nextPutAll: 'SOMFrame:'.
	stream cr.
	self printStackOn: stream
]

{ #category : #printing }
SOMFrame >> printStack [
	
	self printStackOn: Transcript.
	Transcript endEntry.
]

{ #category : #printing }
SOMFrame >> printStackElement: somObject atIndex: index on: stream [ 
	
	| somNil somClazz |
	stream
		nextPutAll: '[';
		nextPutAll: index asString;
		nextPutAll: '] '.
		
	index <= self somMethod numberOfArguments 
		ifTrue: [stream nextPutAll: '(arg '; nextPutAll: index asString; nextPutAll: ') '].
	((index > self somMethod numberOfArguments) and: [index <= (self somMethod numberOfLocals + self somMethod numberOfArguments)])
		ifTrue: [stream nextPutAll: '(local '; nextPutAll: (index - self somMethod numberOfArguments) asString; nextPutAll: ') '].
			
	somNil := self universe globalNil.
	(somObject isNil or: [ somObject == somNil ]) ifTrue: 
		[ stream
			nextPutAll: 'nil';
			cr.
		^ self ].
	somClazz := [somObject somClass] on: Error do: [somObject].
	(somClazz isNil or: [ somClazz == somNil ]) ifTrue: 
		[ stream
			nextPutAll: 'object without class';
			cr.
		^ self ].
	stream
		nextPutAll: somObject asString;
		nextPutAll: ' with class: ';
		nextPutAll: somClazz asString;
		cr
]

{ #category : #printing }
SOMFrame >> printStackOn: stream [
	"prints value of stack pointer and the content of each stack slot"

	stream nextPutAll: '    Method: ';
		nextPutAll: self somMethod asString;
		cr;
		nextPutAll: '    Stackpointer: ';
		nextPutAll: self stackPointer asString;
		cr.
	
	self stackPointer to: 1 by: -1 do:
		[ :index |
		| somObject |
		index = self stackPointer ifTrue: [stream nextPutAll: '-> ']
									   ifFalse:[stream nextPutAll: '   '].
		somObject := self at: index.
		self printStackElement: somObject atIndex: index on: stream ]
]

{ #category : #'stack manipulation' }
SOMFrame >> push: object [

	self stackPointer: self stackPointer + 1.
	self at: self stackPointer put: object.
]

{ #category : #'as yet unclassified' }
SOMFrame >> remainingStackSize [
	^ self numberOfIndexableFields - self stackPointer
]

{ #category : #'stack manipulation' }
SOMFrame >> removeN: numOfElements [

	| oldPosition |
	numOfElements = 0 ifTrue: [^ self].
	oldPosition := self stackPointer.
	oldPosition < (self somMethod numberOfLocals + self somMethod numberOfArguments + numOfElements) 
		ifTrue: [self error: 'Stack is empty'].
	self stackPointer: oldPosition - numOfElements.
]

{ #category : #'as yet unclassified' }
SOMFrame >> resetStackPointer [
	self localOffset: 
		(self somMethod numberOfArguments).
	self stackPointer: 
		(self somMethod numberOfLocals + self somMethod numberOfArguments) 
]

{ #category : #accessing }
SOMFrame >> somContext [
	^ somContext
]

{ #category : #accessing }
SOMFrame >> somContext: anObject [ 
	somContext := anObject
]

{ #category : #'as yet unclassified' }
SOMFrame >> somCurrentObject [
	self somMethod somSignature = self universe globalNil
		ifTrue: [^ self universe globalNil].
	self somMethod numberOfArguments = 0
		ifTrue: [^ self universe globalNil].
	^ self argumentAtIndex: 1 contextLevel: 1
]

{ #category : #accessing }
SOMFrame >> somMethod [
	^ somMethod
]

{ #category : #accessing }
SOMFrame >> somMethod: anObject [ 
	somMethod := anObject
]

{ #category : #accessing }
SOMFrame >> somPreviousFrame [
	^ somPreviousFrame
]

{ #category : #accessing }
SOMFrame >> somPreviousFrame: anObject [ 
	somPreviousFrame := anObject
]

{ #category : #'as yet unclassified' }
SOMFrame >> stackElementAtIndex: index [
	^ self at: (self stackPointer - index + 1) 
]

{ #category : #'as yet unclassified' }
SOMFrame >> stackElementAtIndex: index put: object [
	self at: (self stackPointer - index + 1) 
		put: object
]

{ #category : #accessing }
SOMFrame >> stackPointer [
	^ stackPointer
]

{ #category : #accessing }
SOMFrame >> stackPointer: anObject [
	stackPointer := anObject
]
