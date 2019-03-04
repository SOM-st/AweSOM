Class {
	#name : #SOMClassGenerationContext,
	#superclass : #Object,
	#instVars : [
		'superName',
		'isClassSide',
		'instanceFields',
		'instanceMethods',
		'classFields',
		'classMethods',
		'theName'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #adding }
SOMClassGenerationContext >> addClassField: fieldName [

	classFields add: fieldName.
]

{ #category : #adding }
SOMClassGenerationContext >> addClassFields: fields [
	classFields addAll: fields.
]

{ #category : #adding }
SOMClassGenerationContext >> addField: field [
	self isClassSide
		ifTrue:  [classFields add: field]
		ifFalse: [instanceFields add: field].
]

{ #category : #adding }
SOMClassGenerationContext >> addFields: fieldNames [

	^ self isClassSide
		ifTrue: [classFields addAll: fieldNames]
		ifFalse: [instanceFields addAll: fieldNames]
]

{ #category : #adding }
SOMClassGenerationContext >> addInstanceField: field [
	instanceFields add: field.
]

{ #category : #adding }
SOMClassGenerationContext >> addInstanceFields: fields [
	instanceFields addAll: fields.
]

{ #category : #adding }
SOMClassGenerationContext >> addMethod: methodGenContext [

	^ self isClassSide
		ifFalse: [self instanceMethods add: methodGenContext]
		ifTrue: [
			methodGenContext onClassSide: true.
			self classMethods add: methodGenContext]
]

{ #category : #assembling }
SOMClassGenerationContext >> assembleIn: universe [

	^ self
		assembleIn: universe
		stub: (self createEmptyClassIn: universe).
]

{ #category : #assembling }
SOMClassGenerationContext >> assembleIn: universe stub: classStub [

	self
		initInstanceSideOf: classStub in: universe;
		initClassSideOf: classStub in: universe;
		initFieldsOf: classStub in: universe.
	^ classStub
]

{ #category : #accessing }
SOMClassGenerationContext >> classFields [
	^ classFields
]

{ #category : #accessing }
SOMClassGenerationContext >> classMethods [
	^ classMethods
]

{ #category : #assembling }
SOMClassGenerationContext >> createEmptyClassIn: universe [

	| superclass |
	superclass := universe
		globalAt: self superName
		ifAbsent: [universe loadSOMClass: self superName].
	^ SOMClass
		inUniverse: universe
		withSomSuperClass: superclass.
]

{ #category : #adding }
SOMClassGenerationContext >> fieldIndex: fieldName [
	^ self isClassSide
		ifTrue:  [classFields indexOf: fieldName]
		ifFalse: [instanceFields indexOf: fieldName].
]

{ #category : #testing }
SOMClassGenerationContext >> hasField: fieldName [

	^ self isClassSide
		ifTrue: [self classFields includes: fieldName]
		ifFalse: [self instanceFields includes: fieldName]
]

{ #category : #assembling }
SOMClassGenerationContext >> initClassSideOf: somClass in: universe [

	| fields methods |
	self flag: #rkrk. "Duplication with #initInstanceSideOf:in:"
	somClass somClass somName: (universe newSymbol: self theName , ' class').
	fields := self classFields collect: [:each | universe newSymbol: each].
	somClass somClass somInstanceFields: (universe newArrayWithAll: fields).
	methods := self classMethods collect: [:each | each assembleIn: universe].
	somClass somClass somInstanceInvokables: (universe newArrayWithAll: methods).
]

{ #category : #assembling }
SOMClassGenerationContext >> initFieldsOf: somClass in: universe [

	| nAdditionalFields nilObject |
	nAdditionalFields := somClass somClass somInstanceFields size.
	nilObject := universe globalNil.
	somClass fields: (Array new: nAdditionalFields).
	somClass numberOfFields - nAdditionalFields + 1
		to: somClass numberOfFields
		do: [:i | somClass fieldAtIndex: i put: nilObject].
]

{ #category : #assembling }
SOMClassGenerationContext >> initInstanceSideOf: somClass in: universe [

	| fields methods |
	somClass somName: (universe newSymbol: self theName).
	fields := self instanceFields collect: [:each | universe newSymbol: each].
	somClass somInstanceFields: (universe newArrayWithAll: fields).
	methods := self instanceMethods collect: [:each | each assembleIn: universe].
	somClass somInstanceInvokables: (universe newArrayWithAll: methods).
]

{ #category : #initialization }
SOMClassGenerationContext >> initialize [

	super initialize.
	
	isClassSide := false.
	superName := #nil.
	instanceFields := OrderedCollection new.
	classFields := OrderedCollection new.
	instanceMethods := OrderedCollection new.
	classMethods := OrderedCollection new.
	theName := ''.
]

{ #category : #accessing }
SOMClassGenerationContext >> instanceFields [
	^ instanceFields
]

{ #category : #accessing }
SOMClassGenerationContext >> instanceFields: anObject [
	instanceFields := anObject
]

{ #category : #accessing }
SOMClassGenerationContext >> instanceMethods [
	^ instanceMethods
]

{ #category : #accessing }
SOMClassGenerationContext >> isClassSide [
	^ isClassSide
]

{ #category : #accessing }
SOMClassGenerationContext >> isClassSide: anObject [
	isClassSide := anObject
]

{ #category : #accessing }
SOMClassGenerationContext >> superName [
	^ superName
]

{ #category : #accessing }
SOMClassGenerationContext >> superName: anObject [
	superName := anObject
]

{ #category : #accessing }
SOMClassGenerationContext >> theName [
	^ theName
]

{ #category : #accessing }
SOMClassGenerationContext >> theName: string [
	^ theName := string
]

{ #category : #accessing }
SOMClassGenerationContext >> toggleClassSide [
	self isClassSide: self isClassSide not
]
