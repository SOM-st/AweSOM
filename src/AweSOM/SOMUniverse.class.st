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
		'exitCode',
		'isInitialized',
		'somObjectClass',
		'somClassClass',
		'somMetaclassClass',
		'somNilClass',
		'somIntegerClass',
		'somArrayClass',
		'somMethodClass',
		'somSymbolClass',
		'somPrimitiveClass',
		'somStringClass',
		'somDoubleClass',
		'somBooleanClass',
		'somTrueObject',
		'somFalseObject',
		'somSystemObject',
		'somTrueClass',
		'somFalseClass',
		'somSystemClass',
		'somNilObject',
		'somBlockClass'
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

{ #category : #initializing }
SOMUniverse >> allocateBasicObjects [
	"Allocate the nil object"
	somNilObject := SOMObject inUniverse: self.
	
	"Allocate the Metaclass classes"
	somMetaclassClass := self newMetaclassClass.

	"Allocate the rest of the system classes"
	somObjectClass := self newSystemClass.
	somNilClass := self newSystemClass.
	somClassClass := self newSystemClass.
	somArrayClass := self newSystemClass.
	somSymbolClass := self newSystemClass.
	somMethodClass := self newSystemClass.
	somIntegerClass := self newSystemClass.
	somPrimitiveClass := self newSystemClass.
	somStringClass := self newSystemClass.
	somDoubleClass := self newSystemClass.
	
	"Setup the class reference for the nil object"
	somNilObject somClass: somNilClass.
	
	"Initialize the system classes"
	self initializeSystemClass: somObjectClass superclass: nil named: #Object.
	self initializeSystemClass: somClassClass  superclass: somObjectClass  named: #Class.
	self initializeSystemClass: somMetaclassClass superclass: somClassClass named: #Metaclass.
	self initializeSystemClass: somNilClass superclass: somObjectClass named: #Nil.
	self initializeSystemClass: somArrayClass superclass: somObjectClass named: #Array.
	self initializeSystemClass: somMethodClass superclass: somArrayClass named: #Method.
	self initializeSystemClass: somStringClass superclass: somObjectClass named: #String.
	self initializeSystemClass: somSymbolClass superclass: somStringClass named: #Symbol.
	self initializeSystemClass: somIntegerClass superclass: somObjectClass named: #Integer.
	self initializeSystemClass: somPrimitiveClass superclass: somObjectClass named: #Primitive.
	self initializeSystemClass: somDoubleClass superclass: somObjectClass named: #Double.
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

	^ SOMMethod
		inUniverse: self
		named: #bootstrap
		numArgs: 1
		numLocals: 0
		maxStackDepth: 2
		bytecodes: {SOMBCHalt new}
		holder: self globalSystemClass
		lexicalContext: self globalNil.

]

{ #category : #bootstrapping }
SOMUniverse >> bootstrapWithArguments: args [ 

	self 
		bootstrapWithEntryPoint: ((self globalSystemClass) lookupInvokable: #initialize:)
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

{ #category : #'as yet unclassified' }
SOMUniverse >> classpathPrepend: aString [
	| cp |
	cp := self class classPaths asOrderedCollection.
	cp add: aString beforeIndex: 1.
	self class classPaths: cp asArray
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
	somClass ifNil: [ Error signal: 'Loading class ', className, ' failed. Classpath: ', SOMUniverse classPaths printString ].
	
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
	self initializeObjectSystemIfNecessary.
	shellClassSource := self createShellClassWith: code.
	shellClass := self loadAndStoreFromSource: shellClassSource.
	self start: {shellClass somName string}.
]

{ #category : #accessing }
SOMUniverse >> exitCode [
	^ exitCode
]

{ #category : #'as yet unclassified' }
SOMUniverse >> getPathClassExt: aString [
  " take argument of the form '../foo/Test.som' and return
    '../foo', 'Test', 'som'"

	| pathElements fileName parentPath nameParts |
	pathElements := ('/' split: aString) asOrderedCollection.
	
	fileName   := pathElements removeLast.
	parentPath := '/' join: pathElements.
	nameParts  := '.' split: fileName.
	
	nameParts size > 2 ifTrue: [
		Error signal: 'Does class name in arguments have . in its name? Argument: ', aString  ].
	
	^ { parentPath ifNil: [ '' ] ifNotNil: [ parentPath ].
		 nameParts at: 1.
		 nameParts size > 1 ifTrue: [ nameParts at: 2 ] ifFalse: [ '' ] }

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
	^ result
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalAt: aSymbol put: anObject [ 

	^ globals 
		at: aSymbol
		put: anObject
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalBlockClass [
	^ somBlockClass
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalClassClass [
	^ somClassClass
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalDoubleClass [
	^ somDoubleClass
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalFalse [
	^ somFalseObject
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalIntegerClass [
	^ somIntegerClass
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalMetaclassClass [
	^ somMetaclassClass
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalNil [

	^ somNilObject
]

{ #category : #'gobal accessing' }
SOMUniverse >> globalSystemClass [
	^ somSystemClass
]

{ #category : #'gobal accessing' }
SOMUniverse >> globals [

	^ globals
]

{ #category : #'as yet unclassified' }
SOMUniverse >> handleArguments: args [
	| gotClasspath remainingArgs i |
	gotClasspath := false.
	remainingArgs := OrderedCollection new.
	
	i := 1.
	[ i <= args size ] whileTrue: [ 
		| arg |
		arg := args at: i.
		arg = '-cp'
			ifTrue: [ 
				i + 1 >= args size ifTrue: [ 
					self printUsage.
					^ nil ].
			
				self setupClasspath: (args at: i + 1).
				i := i + 1. "skip classpath"
				gotClasspath := true ]
			ifFalse: [
				({ '-h'. '--help'. '-?' } includes: arg)
					ifTrue: [ 
						self printUsage.
						^ nil ]
					ifFalse: [ 
						remainingArgs add: arg ]
				].
		i := i + 1 ].
	
	gotClasspath ifFalse: [ self setupDefaultClasspath. ].
	
	remainingArgs := remainingArgs asArray.
	
	remainingArgs doWithIndex: [ :e :idx |
		| split |
		split := self getPathClassExt: e.
		(split at: 1) = '' ifFalse: [ 
			self classpathPrepend: (split at: 1) ].
		
		remainingArgs at: idx put: (split at: 2) ].
	
	^ remainingArgs
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
SOMUniverse >> initialize [

	super initialize.
	self interpreter: (self class defaultInterpreter inUniverse: self).
	globals := IdentityDictionary new.
	heap := SOMHeap in: self.
	symbolTable := SOMSymbolTable in: self.
	numberCache := IdentityDictionary new.

	exitCode := 0.
	isInitialized := false.
]

{ #category : #initializing }
SOMUniverse >> initializeGlobalsDict: systemObject [
	"Put special objects and classess into the dictionary of globals"
	self globalAt: #nil put: somNilObject.
	self globalAt: #true put: somTrueObject.
	self globalAt: #false put: somFalseObject.
	self globalAt: #system put: systemObject.

	^ systemObject

]

{ #category : #initializing }
SOMUniverse >> initializeObjectSystem [
	| systemObject |
	self allocateBasicObjects.
	
	"Load methods and fields into the system classes"
	self loadSystemClass: somObjectClass.
	self loadSystemClass: somClassClass.
	self loadSystemClass: somMetaclassClass.
	self loadSystemClass: somNilClass.
	self loadSystemClass: somArrayClass.
	self loadSystemClass: somMethodClass.
	self loadSystemClass: somStringClass.
	self loadSystemClass: somSymbolClass.
	self loadSystemClass: somIntegerClass.
	self loadSystemClass: somPrimitiveClass.
	self loadSystemClass: somDoubleClass.

	"Fix up objectClass"
	somObjectClass somSuperClass: somNilObject.
	
	"Load the generic block class"
	somBlockClass := self loadSOMClass: #Block.
	
	"Setup the true and false objects"
	somTrueClass := self loadSOMClass: #True.
	somTrueObject := self newInstance: somTrueClass.
	
	somFalseClass := self loadSOMClass: #False.
	somFalseObject := self newInstance: somFalseClass.
	
	somSystemClass := self loadSOMClass: #System.
	systemObject := SOMSystem inUniverse: self withSomClass: somSystemClass.
	
	self initializeGlobalsDict: systemObject.
	
	isInitialized := true.
	^ systemObject

]

{ #category : #initializing }
SOMUniverse >> initializeObjectSystemIfNecessary [

	isInitialized ifFalse: [ self initalizeObjectSystem ]
]

{ #category : #initializing }
SOMUniverse >> initializeSystemClass: systemClass superclass: superClass named: name [
	self assert: name isSymbol.

	superClass
		ifNotNil: [
			systemClass somSuperClass: superClass.
			systemClass somClass somSuperClass: superClass somClass ]
		ifNil: [ 
			systemClass somClass somSuperClass: somClassClass ].
	
	"Initialize the array of instance fields"
	systemClass somInstanceFields: (self newArray: 0).
	systemClass somClass somInstanceFields: (self newArray: 0).

	"Initialize the array of instance invokables"
	systemClass somInstanceInvokables: (self newArray: 0).
	systemClass somClass somInstanceInvokables: (self newArray: 0).
	
	"Initialize the name of the system class"
	systemClass somName: (self newSymbol: name).
	systemClass somClass somName: (self newSymbol: name, ' class').

	"Insert the system class into the globals dictionary"
	self globalAt: name put: systemClass

]

{ #category : #initializing }
SOMUniverse >> initializeTestObjectSystem [
	self allocateBasicObjects.
	
	somBlockClass := self newSystemClass.
	self initializeSystemClass: somBlockClass superclass: somObjectClass named: #Block.

	self initializeGlobalsDict: somNilObject.

	somSystemClass := self newSystemClass.
	self globalAt: #System put: somSystemClass.

	isInitialized := true.
	^ somNilObject
	
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
		globalAt: class somName symbol
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

	^ self loadSOMClass: className stub: nil
]

{ #category : #loading }
SOMUniverse >> loadSOMClass: className stub: stub [

	^ self globalAt: className ifAbsentPut: [
		self compiler
			loadAndCompileSOMClass: className
			stub: stub ]
.
	
]

{ #category : #loading }
SOMUniverse >> loadSystemClass: systemClass [
	| className |
	className := systemClass somName symbol.

	^ self compiler
		loadAndCompileSOMClass: className
		stub: systemClass.
]

{ #category : #'object creation' }
SOMUniverse >> newArray: size [

	^ SOMArray
		inUniverse: self
		size: size
]

{ #category : #'object creation' }
SOMUniverse >> newArrayWithAll: collection [

	^ SOMArray
		inUniverse: self
		withAll: collection
]

{ #category : #'object creation' }
SOMUniverse >> newBool: squeakBool [

	^  squeakBool ifTrue: [ somTrueObject ] ifFalse: [ somFalseObject ]
]

{ #category : #'object creation' }
SOMUniverse >> newInstance: aSomClass [
	^ SOMObject inUniverse: self withSomClass: aSomClass
]

{ #category : #initializing }
SOMUniverse >> newMetaclassClass [
	| result |
	"Allocate the metaclass classes"
	result := SOMClass inUniverse: self.
	result somClass: (SOMClass inUniverse: self).
	"Setup the metaclass hierarchy"
	
	result somClass somClass: result.

	"Return the freshly allocated metaclass class"
	^ result

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

{ #category : #'object creation' }
SOMUniverse >> newSystemClass [
	| systemClass |
	systemClass := SOMClass inUniverse: self.
	
	systemClass somClass: (SOMClass inUniverse: self).
	systemClass somClass somClass: somMetaclassClass.
	
	^ systemClass
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

{ #category : #printing }
SOMUniverse >> printUsage [
	 self outStream
		nextPutAll: 'Usage: som [-options] [args...]'; lf;
		lf;
		nextPutAll: 'where options include:'; lf;
		nextPutAll: '    -cp <directories separated by ":">'; lf;
		nextPutAll: '              sets search path for application classes'; lf;
		lf

]

{ #category : #quiting }
SOMUniverse >> quit: errorCode [

	interpreter stop.
	exitCode := errorCode number.

]

{ #category : #'as yet unclassified' }
SOMUniverse >> setupClasspath: classpathString [
	| cp |
	cp := ':' split: classpathString.
	self class classPaths: cp

]

{ #category : #'as yet unclassified' }
SOMUniverse >> setupDefaultClasspath [
	self setupClasspath: '.'
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

	| remainingArgs wrappedArguments |
	remainingArgs := self handleArguments: arguments.
 	self initializeObjectSystem.
	wrappedArguments := remainingArgs collect: [ :arg | self newString: arg].
	self bootstrapWithArguments: (SOMArray inUniverse: self withAll: wrappedArguments).
]

{ #category : #initializing }
SOMUniverse >> start: className method: methodName [
	| invokable class frame |
 	self initializeObjectSystem.
	
	class := self loadSOMClass: className asSymbol.
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
