"
Bytecodes are currently stored in a separate collection. This is not the way it is implemented in cppsom.
"
Class {
	#name : #SOMMethod,
	#superclass : #SOMInvokable,
	#instVars : [
		'numberOfLocals',
		'maxStackDepth',
		'bytecodes',
		'constants',
		'lexicalContext'
	],
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'instance creation' }
SOMMethod class >> inUniverse: universe named: squeakSymbol numArgs: nArgs numLocals: nLoc maxStackDepth: nStack bytecodes: bc holder: holder lexicalContext: ctx [

	^ (self
		inUniverse: universe
		named: squeakSymbol
		numArgs: nArgs)
		numberOfLocals: nLoc;
		maxStackDepth: nStack;
		bytecodes: bc;
		somHolder: holder;
		lexicalContext: ctx;
		yourself.
		
		
]

{ #category : #initialization }
SOMMethod >> assignLexicalContexts [
	self bytecodes
		select: [ :bc | bc isPushBlock ]
		thenDo: [ :bc | bc literalValue lexicalContext: self ].
	^ self
]

{ #category : #accessing }
SOMMethod >> bytecodeAt: index [ 
	^ self bytecodes at: index
]

{ #category : #accessing }
SOMMethod >> bytecodeAt: index put: bytecode [ 
	^ self bytecodes
		at: index
		put: bytecode
]

{ #category : #accessing }
SOMMethod >> bytecodes [
	^ bytecodes
]

{ #category : #accessing }
SOMMethod >> bytecodes: anObject [
	bytecodes := anObject
]

{ #category : #accessing }
SOMMethod >> constantAt: index [ 
	^ self constants at: index
]

{ #category : #accessing }
SOMMethod >> constantAt: index put: const [
	^ constants at: index put: const
]

{ #category : #accessing }
SOMMethod >> constants [
	^ constants
]

{ #category : #accessing }
SOMMethod >> constants: anObject [
	constants := anObject
]

{ #category : #initialization }
SOMMethod >> initialize [

	super initialize.
	self
		maxStackDepth: 0;
		numberOfLocals: 0;
		constants: #();
		bytecodes: #();
		lexicalContext: nil.
]

{ #category : #invoking }
SOMMethod >> invokeInFrame: frame [

	| newFrame |
	newFrame := self universe interpreter pushNewFrameWithMethod: self.
	newFrame copyArgumentsFrom: frame.
	^ newFrame
]

{ #category : #accessing }
SOMMethod >> isBlockMethod [
	^ self somSignature == universe globalNil
]

{ #category : #accessing }
SOMMethod >> lexicalContext [
	^ lexicalContext
]

{ #category : #accessing }
SOMMethod >> lexicalContext: aSOMMethod [
	lexicalContext := aSOMMethod
]

{ #category : #accessing }
SOMMethod >> maxStackDepth [
	^ maxStackDepth
]

{ #category : #accessing }
SOMMethod >> maxStackDepth: anObject [
	maxStackDepth := anObject
]

{ #category : #accessing }
SOMMethod >> numberOfBytecodes [
	^ bytecodes size
]

{ #category : #accessing }
SOMMethod >> numberOfConstants [
	^ self constants size
]

{ #category : #accessing }
SOMMethod >> numberOfLocals [
	^ numberOfLocals
]

{ #category : #accessing }
SOMMethod >> numberOfLocals: anObject [
	numberOfLocals := anObject
]
