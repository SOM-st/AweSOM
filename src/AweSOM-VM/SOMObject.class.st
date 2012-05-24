Class {
	#name : #SOMObject,
	#superclass : #Object,
	#instVars : [
		'universe',
		'theHash',
		'fields',
		'indexableFields',
		'gcField',
		'somClass',
		'somDomain'
	],
	#classInstVars : [
		'RealFieldIndexCache',
		'NumberOfSharedFieldsCache'
	],
	#category : #'AweSOM-CoreObjects'
}

{ #category : #accessing }
SOMObject class >> allSharedFields [

	^ self allInstVarNames select: [:each | each beginsWith: 'som']
]

{ #category : #compiling }
SOMObject class >> doneCompiling [
	super doneCompiling.
	self withAllSubclassesDo: [:each | each resetCaches]
]

{ #category : #'instance creation' }
SOMObject class >> inUniverse: universe [

	^ self
		inUniverse: universe
		withNumberOfAdditionalFields: 0
]

{ #category : #'instance creation' }
SOMObject class >> inUniverse: universe withNumberOfAdditionalFields: numberOfFields [

	^ self
		inUniverse: universe
		withNumberOfAdditionalFields: numberOfFields
		withNumberOfIndexableFields: 0
]

{ #category : #'instance creation' }
SOMObject class >> inUniverse: universe withNumberOfAdditionalFields: nFields withNumberOfIndexableFields: nIndexableFields [

	"It is called 'Additional' because it's the number of fields that are
	allocated in addition to the shared fields"
	| result nilObject |
	nilObject := universe globalNil.
	result := self basicNew
		universe: universe;
		fields: (Array new: nFields);
		indexableFields: (Array new: nIndexableFields withAll: nilObject);
		yourself.
	result
		wipe;
		setDefaultClass;
		initialize;
		postInitialize.
	universe heap allocateFor: result.
	^ result
]

{ #category : #'instance creation' }
SOMObject class >> inUniverse: universe withSomClass: aSOMClass [ 
	| numberOfAdditionalFields |
	numberOfAdditionalFields := aSOMClass numberOfInstanceFields - self numberOfSharedFields.
	^ (self 
		inUniverse: universe
		withNumberOfAdditionalFields: numberOfAdditionalFields)
		somClass: aSOMClass;
		yourself
]

{ #category : #'instance creation' }
SOMObject class >> inUniverse: universe withSomClass: aSOMClass numIndexable: numIndexable [ 
	| numberOfAdditionalFields |
	numberOfAdditionalFields := aSOMClass numberOfInstanceFields - self numberOfSharedFields.
	^ (self 
		inUniverse: universe
		withNumberOfAdditionalFields: numberOfAdditionalFields
		withNumberOfIndexableFields: numIndexable)
		somClass: aSOMClass;
		yourself
]

{ #category : #initialization }
SOMObject class >> initialize [
	" self initialize "
	super initialize.
	self withAllSubclassesDo: [:each | each resetCaches].
]

{ #category : #'instance creation' }
SOMObject class >> new [
	self error: 'Use factory methods instead.'
]

{ #category : #accessing }
SOMObject class >> numberOfSharedFields [

	"Returns the number of fields that are shared between VM and SOM code"
	^ NumberOfSharedFieldsCache
]

{ #category : #accessing }
SOMObject class >> realFieldIndexFor: index [
	^ RealFieldIndexCache at: index ifAbsentPut: [
		| diff |
		diff := index - self numberOfSharedFields.
		diff <= 0
			ifTrue: [{#shared.
				self allInstVarNames indexOf: (self allSharedFields at: index)}]
			ifFalse: [{#fields. diff}].]
]

{ #category : #'as yet unclassified' }
SOMObject class >> resetCaches [
	" self resetCaches "
	RealFieldIndexCache := Dictionary new.
	NumberOfSharedFieldsCache := self allSharedFields size.
]

{ #category : #accessing }
SOMObject class >> somName [
	^ (self name allButFirst: 3) asSymbol
]

{ #category : #accessing }
SOMObject >> allMyReferences [

	| normalFields |
	normalFields := (1 to: self numberOfFields) collect: [:i | self fieldAtIndex: i].
	^ normalFields , self indexableFields 
]

{ #category : #accessing }
SOMObject >> fieldAtIndex: index [

	| realIndex |
	realIndex := self realFieldIndexFor: index.
	realIndex first = #fields ifTrue: [^ fields at: realIndex second].
	realIndex first = #shared ifTrue: [^ self instVarAt: realIndex second].
	self error: ['Unexpected symbol'].
]

{ #category : #accessing }
SOMObject >> fieldAtIndex: index put: object [

	| realIndex |
	realIndex := self realFieldIndexFor: index.
	realIndex first = #fields ifTrue: [^ fields at: realIndex second put: object].
	realIndex first = #shared ifTrue: [^ self instVarAt: realIndex second put: object].
	self error: ['Unexpected symbol'].
]

{ #category : #accessing }
SOMObject >> fields [
	^ fields
]

{ #category : #accessing }
SOMObject >> fields: anObject [
	fields := anObject
]

{ #category : #accessing }
SOMObject >> gcField [
	^ gcField
]

{ #category : #accessing }
SOMObject >> gcField: anObject [
	gcField := anObject
]

{ #category : #accessing }
SOMObject >> indexOfField: aSOMSymbol [ 
	^ self somClass indexOfInstanceField: aSOMSymbol
]

{ #category : #accessing }
SOMObject >> indexableFields [
	^ indexableFields
]

{ #category : #accessing }
SOMObject >> indexableFields: anObject [
	indexableFields := anObject
]

{ #category : #testing }
SOMObject >> isClass [

	^ false
]

{ #category : #testing }
SOMObject >> isSOMNumber [

	^ false
]

{ #category : #testing }
SOMObject >> isSOMObject [

	^ true
]

{ #category : #testing }
SOMObject >> isSOMSymbol [

	^ false
]

{ #category : #accessing }
SOMObject >> numberOfFields [
	^ self class numberOfSharedFields + fields size
]

{ #category : #accessing }
SOMObject >> numberOfIndexableFields [
	^ self indexableFields size
]

{ #category : #accessing }
SOMObject >> numberOfSharedFields [
	^ self class numberOfSharedFields
]

{ #category : #'message sending' }
SOMObject >> performPrimitive: selector withArguments: arguments [

	^ self perform: selector withArguments: arguments
]

{ #category : #primitives }
SOMObject >> primEqualEqual: otherObject [ 

	^ self universe newBool: self == otherObject
]

{ #category : #primitives }
SOMObject >> primhalt [
	Halt now.
	self universe interpreter showInspection.
]

{ #category : #primitives }
SOMObject >> primhashcode [

	^ universe newNumber: self hash
]

{ #category : #primitives }
SOMObject >> priminspect [
	self inspect.
	Halt now.
]

{ #category : #primitives }
SOMObject >> priminstVarAt: idx [
	^ self fieldAtIndex: idx number.
]

{ #category : #primitives }
SOMObject >> priminstVarAt: idx put: val [
	^ self fieldAtIndex: idx number put: val.
]

{ #category : #primitives }
SOMObject >> priminstVarNamed: aSOMSymbol [
	^ self valueInField: aSOMSymbol
]

{ #category : #primitives }
SOMObject >> primobjectSize [

	"basic object size in SOM++ is: 5 words (vtable, hash, objectSize, numberOfFields, gcField)
	basic object size in AweSOM is: 5 words (universe, hash, objectSize, numberOfFields, gcField)
	additional words are needed for each field
	word is 4 byte and objectSize returns the size in bytes (32-bit aligned)"
	^ self universe newNumber:
		(self class instSize - 1 +
		self numberOfSharedFields +
		self numberOfIndexableFields) * 4
]

{ #category : #primitives }
SOMObject >> primperform: aSOMSymbol [
	self sendMessage: aSOMSymbol symbol
		withArguments: 
			(SOMArray inUniverse: universe size: 0).
	
	^ nil "return nil, to avoid pushing a wrong return value on the stack."
]

{ #category : #primitives }
SOMObject >> primperform: aSOMSymbol inSuperclass: class [
	self
		sendMessage: aSOMSymbol symbol
		withArguments: (SOMArray inUniverse: universe size: 0)
		inClass: class.
	
	^ nil "return nil, to avoid pushing a wrong return value on the stack."
]

{ #category : #primitives }
SOMObject >> primperform: aSOMSymbol withArguments: args [
	self sendMessage: aSOMSymbol symbol
		withArguments: args.
	
	^ nil "return nil, to avoid pushing a wrong return value on the stack."
]

{ #category : #primitives }
SOMObject >> primperform: aSOMSymbol withArguments: args inSuperclass: class [
	self
		sendMessage: aSOMSymbol symbol
		withArguments: args
		inClass: class.
	
	^ nil "return nil, to avoid pushing a wrong return value on the stack."
]

{ #category : #printing }
SOMObject >> printOn: stream [

	"When self is in SOMUniverse globals then print
	symbol of self as found in global dictionary"
	(self universe symbolFor: self) ifNotNilDo: [:sym |
		stream
			nextPutAll: 'SOMGlobal(';
			nextPutAll: sym;
			nextPut: $).
		^ self].
	self somClass ifNil: [
		stream nextPutAll: 'a SOMObject without class'.
		^ self].
	stream
		nextPutAll: 'a SOM';
		nextPutAll: self somClass somName string
]

{ #category : #accessing }
SOMObject >> realFieldIndexFor: index [

	^ self class realFieldIndexFor: index
]

{ #category : #'message sending' }
SOMObject >> sendMessage: message withArguments: args [ 
	self sendMessage: message withArguments: args inClass: self somClass
]

{ #category : #'message sending' }
SOMObject >> sendMessage: message withArguments: args inClass: class [
	| frame invokable |
	frame := self universe interpreter somFrame.
	frame push: self.
	args do: [ :arg | frame push: arg ].
	invokable := class lookupInvokable: message.
	invokable invokeInFrame: frame
]

{ #category : #accessing }
SOMObject >> setDefaultClass [
	| somName |
	somName := self class somName.
	(universe hasGlobalAt: somName) ifTrue: [ self somClass: (universe globalAt: somName) ]
]

{ #category : #accessing }
SOMObject >> somClass [

	self flag: #rkrk. "Hack. Some objects don't have a proper class...'"
	(somClass isKindOf: SOMClass)
		ifFalse: [self setDefaultClass].
	^ somClass
]

{ #category : #accessing }
SOMObject >> somClass: anObject [ 
	somClass := anObject
]

{ #category : #accessing }
SOMObject >> theHash [
	^ theHash
]

{ #category : #accessing }
SOMObject >> theHash: anObject [
	theHash := anObject
]

{ #category : #accessing }
SOMObject >> universe [
	^ universe
]

{ #category : #accessing }
SOMObject >> universe: anObject [
	universe := anObject
]

{ #category : #accessing }
SOMObject >> valueInField: fieldName [

	^ self fieldAtIndex: (self indexOfField: fieldName)
]

{ #category : #accessing }
SOMObject >> valueInField: fieldName put: value [

	self 
		fieldAtIndex: (self indexOfField: fieldName)
		put: value
]

{ #category : #accessing }
SOMObject >> wipe [
	1 to: self numberOfFields do: [ :i | self fieldAtIndex: i put: universe globalNil ]
]
