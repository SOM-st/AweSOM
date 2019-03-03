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
SOMClassGenerationContext >> addField: field [
	self isClassSide
		ifTrue:  [classFields add: field]
		ifFalse: [instanceFields add: field].
]

{ #category : #adding }
SOMClassGenerationContext >> addFields: fieldNames [

	^ self isClassSide
		ifTrue: [self classFields: fieldNames]
		ifFalse: [self instanceFields: fieldNames]
]

{ #category : #adding }
SOMClassGenerationContext >> addInstanceField: field [
	instanceFields add: field.
]

{ #category : #adding }
SOMClassGenerationContext >> addMethod: methodGenContext [

	^ self isClassSide
		ifFalse: [self instanceMethods add: methodGenContext]
		ifTrue: [
			methodGenContext onClassSide: true.
			self classMethods add: methodGenContext]
]

{ #category : #variables }
SOMClassGenerationContext >> allClassFieldsIn: universe [

	| superClass |
	self superName = 'nil' ifTrue: [^ self classFields].
	superClass := universe
		globalAt: self superName asSymbol
		ifAbsent: ["self error: 'Field lookup: Cannot find my superclass ' , self superName , '!'"
			"Transcript
				cr;
				show: 'Field lookup: Cannot find my superclass ' , self superName , '!'."
			^ self classFields].
	^ superClass somClass allInstanceFields , self classFields.
]

{ #category : #variables }
SOMClassGenerationContext >> allInstanceFieldsIn: universe [

	| superClass |
	self superName = 'nil' ifTrue: [^ self instanceFields].
	superClass := universe
		globalAt: self superName asSymbol
		ifAbsent: ["self error: 'Field lookup: Cannot find my superclass ' , self superName , '!'"
			"Transcript
				cr;
				show: 'Field lookup: Cannot find my superclass ' , self superName , '!'."
			^ self instanceFields].
	^ superClass allInstanceFields , self instanceFields.
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
SOMClassGenerationContext >> classFields: anObject [
	classFields := anObject
]

{ #category : #accessing }
SOMClassGenerationContext >> classMethods [
	^ classMethods
]

{ #category : #accessing }
SOMClassGenerationContext >> classMethods: anObject [
	classMethods := anObject
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

{ #category : #initialization }
SOMClassGenerationContext >> defaultSuperClassName [

	^ #Object
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
	self
		isClassSide: false;
		superName: self defaultSuperClassName;
		instanceFields: OrderedCollection new;
		classFields: OrderedCollection new;
		instanceMethods: OrderedCollection new;
		classMethods: OrderedCollection new;
		theName: ''.
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
SOMClassGenerationContext >> instanceMethods: anObject [
	instanceMethods := anObject
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
