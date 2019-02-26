Class {
	#name : #SOMUniverse,
	#superclass : #Object,
	#instVars : [
		'globals',
		'interpreter',
		'outStream',
		'heap',
		'symbolTable',
		'numberCache',
		'exitCode'
	],
	#classVars : [
		'ClassPaths',
		'Default',
		'DefaultInterpreter'
	],
	#category : #'AweSOM-VM'
}

{ #category : #accessing }
SOMUniverse class >> classPaths [

	^ ClassPaths ifNil: [
		self notify: 'classPaths was not set. Use SOMTools>>setClassPathBase: and pass the path to the SOM directory'].
]

{ #category : #accessing }
SOMUniverse class >> classPaths: anObject [
	ClassPaths := anObject
]

{ #category : #accessing }
SOMUniverse class >> default [
	Default ifNil: [Default := self].
	^ Default
]

{ #category : #accessing }
SOMUniverse class >> default: aUniverseClass [
	Default := aUniverseClass
]

{ #category : #accessing }
SOMUniverse class >> defaultInterpreter [
	DefaultInterpreter ifNil: [DefaultInterpreter := SOMInterpreter ].
	^ DefaultInterpreter
]

{ #category : #accessing }
SOMUniverse class >> defaultInterpreter: interpClass [
	DefaultInterpreter := interpClass
]

{ #category : #bootstrapping }
SOMUniverse >> bootstrapFrameFor: receiver withArguments: args [
	| frame |
	frame := self interpreter pushNewFrameWithMethod: self bootstrapMethod.
	frame push: receiver.
	args ifNotNil: [
		frame push: args ].

	^ frame

]

{ #category : #bootstrapping }
SOMUniverse >> bootstrapMethod [

	^ self methodClass
		inUniverse: self
		named: #bootstrap
		numArgs: 1
		numLocals: 0
		maxStackDepth: 2
		bytecodes: {SOMBCHalt new}
		holder: (self globalAt: #System)
		lexicalContext: self globalNil.

]

{ #category : #bootstrapping }
SOMUniverse >> bootstrapWithArguments: args [ 

	self 
		bootstrapWithEntryPoint: ((self globalAt: #System) lookupInvokable: #initialize:)
		on: (self globalAt: #system)
		withArguments: args.
]

{ #category : #bootstrapping }
SOMUniverse >> bootstrapWithEntryPoint: invokable on: receiver withArguments: args [

	| bootstrapFrame |
	bootstrapFrame := self bootstrapFrameFor: receiver withArguments: args.
	invokable ifNotNil: [invokable invokeInFrame: bootstrapFrame].
	self interpreter start.
	^ bootstrapFrame
]

{ #category : #'universe configuration' }
SOMUniverse >> classClass [
	^ SOMClass
]

{ #category : #'universe configuration' }
SOMUniverse >> classParser [
	^ SOMClassParser
]

{ #category : #accessing }
SOMUniverse >> compiler [

	^ SOMCompiler inUniverse: self on: self class classPaths
]

{ #category : #'object creation' }
SOMUniverse >> createGlobal: globalName somClass: className [

	| sqClassName sqClass somClass instance |
	"If class exists in Squeak use it as base class"
	sqClassName :=  ('SOM' , className) asSymbol.
	sqClass := (Smalltalk
		classNamed: sqClassName)
		ifNil: [SOMObject].
	somClass := self
		globalAt: className
		ifAbsentPut: [self loadSOMClass: className].
	instance := sqClass
		inUniverse: self
		withSomClass: somClass.
	^ self
		globalAt: globalName
		put: instance.
]

{ #category : #'code evaluation' }
SOMUniverse >> createShellClassWith: code [

	^ String streamContents: [:stream |
		stream
			nextPutAll: 'ShellClass = ('; cr;
			nextPutAll: 'run = ('; cr;
			nextPutAll: code; cr;
			nextPutAll: '))'].
]

{ #category : #'code evaluation' }
SOMUniverse >> eval: code [

	| shellClassSource shellClass |
	self initializeRealGlobalsIfNecessary.
	shellClassSource := self createShellClassWith: code.
	shellClass := self loadAndStoreFromSource: shellClassSource.
	self start: {shellClass somName string}.
]

{ #category : #accessing }
SOMUniverse >> exitCode [
	^ exitCode
]

{ #category : #'universe configuration' }
SOMUniverse >> frameClass [
	^ SOMFrame
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalAt: aSymbol [ 

	^ globals at: aSymbol
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalAt: aSymbol ifAbsent: aBlock [
	^ globals at: aSymbol ifAbsent: aBlock.
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalAt: aSymbol ifAbsentPut: aBlock [
"Treat nil values as absent values"
	| result |
	result := globals at: aSymbol ifAbsentPut: aBlock.
	result ifNil: [
		result := aBlock value.
		globals at: aSymbol put: result].
	^ result
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalAt: aSymbol put: anObject [ 

	^ globals 
		at: aSymbol
		put: anObject
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalNil [

	^ self globalAt: #nil
]

{ #category : #'gobal accessing' }
SOMUniverse >> globals [

	^ globals
]

{ #category : #'gobal accessing' }
SOMUniverse >> hasGlobalAt: aSymbol [ 
	^ globals includesKey: aSymbol
]

{ #category : #accessing }
SOMUniverse >> heap [
	^ heap
]

{ #category : #accessing }
SOMUniverse >> heap: anObject [
	heap := anObject
]

{ #category : #initializing }
SOMUniverse >> initClassSystem [

	| class metaclass |
	class     := self classClass inUniverse: self.
	metaclass := self classClass inUniverse: self.
	class somClass: metaclass.
	metaclass somClass: class.
	metaclass somSuperClass: class.
	self globalAt: #Class put: class.
	self globalAt: #Metaclass put: metaclass.
]

{ #category : #initializing }
SOMUniverse >> initNil [

	self globalAt: #nil put: nil.
	self globalAt: #nil put: (SOMObject inUniverse: self).
]

{ #category : #initializing }
SOMUniverse >> initSystemClassFrom: sqClass [

	| superclass somClass |
	superclass := sqClass = SOMObject
		ifTrue: [self globalNil]
		ifFalse: [self globalAt: sqClass superclass somName].
	somClass := self classClass
		inUniverse: self
		withSomSuperClass: superclass.
	self
		globalAt: sqClass somName
		ifAbsentPut: [somClass].
]

{ #category : #initializing }
SOMUniverse >> initSystemClassesWith: classLoader [

	| systemClasses name |
	systemClasses := self sortedSubClassesOf: SOMObject.
	systemClasses do: [:class | self initSystemClassFrom: class].
	(self globalAt: #Class) somSuperClass: (self globalAt: #Object).
	systemClasses do: [:class |
		name := class somName.
		(self globalAt: name) somName: (self newSymbol: name).
		classLoader value: name].
]

{ #category : #initializing }
SOMUniverse >> initialize [

	super initialize.
	self interpreter: (self class defaultInterpreter inUniverse: self).
	globals := Dictionary new.
	heap := SOMHeap in: self.
	symbolTable := SOMSymbolTable in: self.
	numberCache := IdentityDictionary new.
]

{ #category : #initializing }
SOMUniverse >> initializeFakeGlobals [

	| nilClass |
	self
		initNil;
		initClassSystem;
		initSystemClassesWith: [:className | "do nothing"].
	"prepare for tests"
	nilClass := self classClass 
		inUniverse: self
		withSomSuperClass: (self globalAt: #Object).
	(self globalAt: #nil) somClass: nilClass.
	self globalAt: #Nil put: nilClass.
	self globalAt: #system put: (SOMSystem inUniverse: self).
	self globalAt: #System put: (self classClass inUniverse: self).
	self globalAt: #true put: (SOMObject inUniverse: self).
	self globalAt: #false put: (self classClass inUniverse: self).
]

{ #category : #initializing }
SOMUniverse >> initializeRealGlobals [

	"self initializeGlobalsWithClassLoader: [:className | self loadSOMClass: className]."
	| preliminaryNil |
	self
		initNil;
		initClassSystem.
	
	preliminaryNil := self globalAt: #nil.
	self createGlobal: #nil somClass: #Nil.
	
	"This hack is necessary since the parsing can already create literals like numbers and others
	 which might have the nil object in object slots.
	 If we do not do the #becomeForward: these slotes refer to the old, useless object since it is not recognized as nil."
	preliminaryNil becomeForward: (self globalAt: #nil).	
	
	self
		createGlobal: #true somClass: #True;
		createGlobal: #false somClass: #False;
		initSystemClassesWith: [:className | self loadSystemClass: className];
		createGlobal: #system somClass: #System.
]

{ #category : #initializing }
SOMUniverse >> initializeRealGlobalsIfNecessary [

	self globalAt: #Array ifAbsent: [self initializeRealGlobals].
]

{ #category : #accessing }
SOMUniverse >> interpreter [
	^ interpreter
]

{ #category : #accessing }
SOMUniverse >> interpreter: anObject [
	interpreter := anObject
]

{ #category : #loading }
SOMUniverse >> loadAndStoreFromSource: source [

	| class |
	class := self compiler
		compileSOMClassSource: source
		stub: nil
		from: '<eval>'.
	^ self
		globalAt: class somName string
		put: class
]

{ #category : #loading }
SOMUniverse >> loadAndStoreSOMClass: className [

	^ self
		globalAt: className
		put: (self loadSOMClass: className)
]

{ #category : #loading }
SOMUniverse >> loadSOMClass: className [

	^ self compiler
		loadAndCompileSOMClass: className
		stub: nil.
]

{ #category : #loading }
SOMUniverse >> loadSystemClass: classStubName [

	^ self compiler
		loadAndCompileSOMClass: classStubName
		stub: (self globalAt: classStubName ifAbsent: [nil]).
]

{ #category : #'universe configuration' }
SOMUniverse >> methodClass [
	^ SOMMethod
]

{ #category : #'universe configuration' }
SOMUniverse >> methodGenClass [
	^ SOMMethodGenerationContext
]

{ #category : #'universe configuration' }
SOMUniverse >> methodParser [
	^ SOMMethodParser
]

{ #category : #'object creation' }
SOMUniverse >> newArrayWithAll: collection [

	^ SOMArray
		inUniverse: self
		withAll: collection
]

{ #category : #'object creation' }
SOMUniverse >> newBool: squeakBool [

	^ self globals at: squeakBool asString asSymbol.
]

{ #category : #'object creation' }
SOMUniverse >> newNumber: number [

	^ self numberCache
		at: number
		ifAbsentPut: [SOMNumber create: number in: self].
]

{ #category : #'object creation' }
SOMUniverse >> newString: string [

	^ SOMString
		inUniverse: self
		string: string
]

{ #category : #'object creation' }
SOMUniverse >> newSymbol: symbolOrString [

	^ self symbolTable somSymbolFor: symbolOrString.
]

{ #category : #accessing }
SOMUniverse >> numberCache [
	^ numberCache
]

{ #category : #accessing }
SOMUniverse >> numberCache: anObject [
	numberCache := anObject
]

{ #category : #accessing }
SOMUniverse >> outStream [

	^ outStream ifNil: [Transcript]
]

{ #category : #accessing }
SOMUniverse >> outStream: writeStream [

	outStream := writeStream
]

{ #category : #'universe configuration' }
SOMUniverse >> primitiveClass [
	^ SOMPrimitive
]

{ #category : #quiting }
SOMUniverse >> quit: errorCode [

	interpreter stop.
	exitCode := errorCode number.

]

{ #category : #initializing }
SOMUniverse >> sortedSubClassesOf: class [

	"Sort by inheritance hierarchy"
	^ (SortedCollection sortBlock: [:a :b | (a inheritsFrom: b) not])
		addAll: class withAllSubclasses;
		sortTopologically;
		yourself
]

{ #category : #initializing }
SOMUniverse >> start: arguments [

	| wrappedArguments |
 	self initializeRealGlobalsIfNecessary.
	wrappedArguments := arguments collect: [ :arg | self newString: arg].
	self bootstrapWithArguments: (SOMArray inUniverse: self withAll: wrappedArguments).
]

{ #category : #initializing }
SOMUniverse >> start: className method: methodName [
	| invokable class frame |
 	self initializeRealGlobalsIfNecessary.
	
	class := self loadSOMClass: className.
	invokable := class somClass lookupInvokable: methodName asSymbol.
	 
	frame := self 
		bootstrapWithEntryPoint: invokable
		on: class
		withArguments: nil.
	^ frame pop

]

{ #category : #'gobal accessing' }
SOMUniverse >> symbolFor: global [

	self flag: #rkrk. "Should return SOMSymbol!!?"
	^ globals keyAtValue: global ifAbsent: [nil].
]

{ #category : #accessing }
SOMUniverse >> symbolTable [
	^ symbolTable
]

{ #category : #accessing }
SOMUniverse >> symbolTable: anObject [
	symbolTable := anObject
]
