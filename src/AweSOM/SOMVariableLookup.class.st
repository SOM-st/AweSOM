Class {
	#name : #SOMVariableLookup,
	#superclass : #Object,
	#instVars : [
		'varName',
		'mgenc',
		'universe',
		'isArgument',
		'isLocal',
		'isGlobal',
		'isField',
		'index',
		'contextIndex'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #'instance creation' }
SOMVariableLookup class >> lookupVar: varName inMethodContext: mgenc inUniverse: universe [

	^ self new
		varName: varName;
		mgenc: mgenc;
		universe: universe;
		lookup;
		yourself.
]

{ #category : #accessing }
SOMVariableLookup >> contextIndex [
	^ contextIndex
]

{ #category : #accessing }
SOMVariableLookup >> contextIndex: anObject [
	contextIndex := anObject
]

{ #category : #testing }
SOMVariableLookup >> found [

	^ self isArgument or: [
	  self isLocal    or: [
	  self isField    or: [
	  self isGlobal]]]
]

{ #category : #accessing }
SOMVariableLookup >> index [
	^ index
]

{ #category : #accessing }
SOMVariableLookup >> index: anObject [
	index := anObject
]

{ #category : #initialization }
SOMVariableLookup >> initialize [

	isGlobal := isLocal := isField := isArgument := false.
	
]

{ #category : #accessing }
SOMVariableLookup >> isArgument [
	^ isArgument
]

{ #category : #accessing }
SOMVariableLookup >> isArgument: anObject [
	isArgument := anObject
]

{ #category : #accessing }
SOMVariableLookup >> isField [
	^ isField
]

{ #category : #accessing }
SOMVariableLookup >> isField: anObject [
	isField := anObject
]

{ #category : #accessing }
SOMVariableLookup >> isGlobal [
	^ isGlobal
]

{ #category : #accessing }
SOMVariableLookup >> isGlobal: anObject [
	isGlobal := anObject
]

{ #category : #accessing }
SOMVariableLookup >> isLocal [
	^ isLocal
]

{ #category : #accessing }
SOMVariableLookup >> isLocal: anObject [
	isLocal := anObject
]

{ #category : #lookup }
SOMVariableLookup >> lookup [

	#(#lookupArgument #lookupLocal #lookupField #lookupGlobal) do: [:sel |
		self perform: sel.
		self found ifTrue: [^ self]].
]

{ #category : #lookup }
SOMVariableLookup >> lookupArgument [

	| currentContext ctxIdx idx |
	currentContext := mgenc.
	ctxIdx := 0.
	idx := 0.
	[idx := currentContext arguments indexOf: varName.
	ctxIdx := ctxIdx + 1.
	currentContext := currentContext outer.
	] doWhileTrue: [idx isZero and: [currentContext notNil]].
	idx isZero ifTrue: [^ self].
	self
		isArgument: true;
		index: idx;
		contextIndex: ctxIdx.
]

{ #category : #lookup }
SOMVariableLookup >> lookupField [

	| fields cgenc |
	cgenc := mgenc somHolder.
	cgenc ifNil: [self error: 'mgenc has no holder!!!'].
	"(self varName = 'class' and: [self mgenc holder theName = #ClassA]) ifTrue: [self halt]."
	fields := cgenc isClassSide
		ifFalse: [cgenc allInstanceFieldsIn: self universe]
		ifTrue: [cgenc allClassFieldsIn: self universe].
	(fields includes: varName) ifTrue: [self isField: true]
]

{ #category : #lookup }
SOMVariableLookup >> lookupGlobal [

	"if it's nothing else then it's a global"
	self isGlobal: true.
	"issue a warning if the global dict doesn't contain the reference'"
	(self universe hasGlobalAt: self varName asSymbol) ifTrue: [^ self].
	"Transcript
		cr;
		show: 'WARNING: Recognized variable named ';
		show: self varName;
		show: ' in ';
		show: self mgenc holder theName;
		show: '>>';
		show: self mgenc signature;
		show: ' as global but variable doesn''t appear in global dict!'."
]

{ #category : #lookup }
SOMVariableLookup >> lookupLocal [

	| currentContext ctxIdx idx |
	currentContext := mgenc.
	ctxIdx := 0.
	idx := 0.
	[idx := currentContext locals indexOf: varName.
	ctxIdx := ctxIdx + 1.
	currentContext := currentContext outer.
	] doWhileTrue: [idx isZero and: [currentContext notNil]].
	idx isZero ifTrue: [^ self].
	self
		isLocal: true;
		index: idx;
		contextIndex: ctxIdx.
]

{ #category : #accessing }
SOMVariableLookup >> mgenc [
	^ mgenc
]

{ #category : #accessing }
SOMVariableLookup >> mgenc: anObject [
	mgenc := anObject
]

{ #category : #accessing }
SOMVariableLookup >> universe [
	^ universe
]

{ #category : #accessing }
SOMVariableLookup >> universe: anObject [
	universe := anObject
]

{ #category : #accessing }
SOMVariableLookup >> varName [
	^ varName
]

{ #category : #accessing }
SOMVariableLookup >> varName: anObject [
	varName := anObject
]
