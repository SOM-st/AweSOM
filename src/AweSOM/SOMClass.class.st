Class {
	#name : #SOMClass,
	#superclass : #SOMObject,
	#instVars : [
		'somSuperClass',
		'somName',
		'somInstanceFields',
		'somInstanceInvokables'
	],
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'instance creation' }
SOMClass class >> inUniverse: universe withSomSuperClass: superClazz [

	| metaclass superMeta |
	"metaclass"
	superMeta := superClazz isClass
		ifTrue: [superClazz somClass]
		ifFalse: [universe globalClassClass].
	metaclass := (self inUniverse: universe)
		somClass: (universe globalMetaclassClass);
		somSuperClass: superMeta;
		yourself.
	"class"
	^ (self inUniverse: universe)
		somSuperClass: superClazz;
		somClass: metaclass;
		yourself.
]

{ #category : #accessing }
SOMClass >> allInstanceFields [

	| instFields |
	instFields := self somInstanceFields elements collect: [:ea | ea string].
	^ self somSuperClass isClass
		ifTrue: [self somSuperClass allInstanceFields , instFields]
		ifFalse: [instFields].
]

{ #category : #testing }
SOMClass >> hasSuperClass [

	^ somSuperClass isClass
]

{ #category : #accessing }
SOMClass >> indexOfInstanceField: aSOMSymbol [ 

	| index |
	index := self somInstanceFields indexOf: aSOMSymbol.
	^ (index = 0 and: [self hasSuperClass])
		ifTrue: [self somSuperClass indexOfInstanceField: aSOMSymbol]
		ifFalse: [self numberOfSuperInstanceFields + index].
]

{ #category : #initialization }
SOMClass >> initialize [
	super initialize.
	somSuperClass := universe globalNil.
	somName  := universe globalNil.
	somInstanceFields  := universe globalNil.
	somInstanceInvokables  := universe globalNil.
	self
		somInstanceFields: (SOMArray inUniverse: universe);
		somInstanceInvokables: (SOMArray inUniverse: universe);
		somName: (universe newString: '')
]

{ #category : #testing }
SOMClass >> isClass [

	^ true
]

{ #category : #'as yet unclassified' }
SOMClass >> lookupInvokable: signature [
	
	^ self somInstanceInvokables elements 
		detect: [:invokable | invokable somSignature symbol == signature]
		ifNone: [self hasSuperClass
			ifTrue: [self somSuperClass lookupInvokable: signature]
			ifFalse: [nil]]
]

{ #category : #accessing }
SOMClass >> numberOfInstanceFields [
	^ self somInstanceFields size + self numberOfSuperInstanceFields
]

{ #category : #accessing }
SOMClass >> numberOfSuperInstanceFields [
	^ somSuperClass isClass
		ifTrue: [somSuperClass numberOfInstanceFields]
		ifFalse: [0]
]

{ #category : #'as yet unclassified' }
SOMClass >> performPrimitive: selector withArguments: arguments [

	"If self is of kind SOMClass, primitives might either be instance primitives of SOMClass or class side primitives of the corresponding class. This dispatch is currently made during invocation.
	This is extremely unsexy code. Class primitives might need access to the universe or the class. Currently class primitives are implemented on the class side of SOMObject subclasses. As class methods do not have access to the universe this / the SOMClass object has to be passed in."
	| class classSelector |
	class := self squeakClass.
	classSelector := (selector, #inSomClass:) asSymbol.
	^ (class respondsTo: classSelector)
		ifTrue: [class perform: classSelector withArguments: arguments, {self}.]
		ifFalse:[self perform: selector withArguments: arguments].
]

{ #category : #primitives }
SOMClass >> primfromString: aSOMString [
	| str |
	str := aSOMString string.

	(universe globalIntegerClass) = self ifTrue: [
		^ SOMInteger inUniverse: universe
						 new: (Integer readFrom: str) ].
	
	self assert: (universe globalDoubleClass) = self.
	^ SOMDouble inUniverse: universe new: (Float readFrom: str)
]

{ #category : #primitives }
SOMClass >> primmethods [
	^ somInstanceInvokables
]

{ #category : #primitives }
SOMClass >> primname [
	^ somName
]

{ #category : #primitives }
SOMClass >> primnew [
	^ self squeakClass 
		inUniverse: universe
		withSomClass: self
]

{ #category : #primitives }
SOMClass >> primsuperclass [
	^ somSuperClass
]

{ #category : #accessing }
SOMClass >> somInstanceFields [
	^ somInstanceFields
]

{ #category : #accessing }
SOMClass >> somInstanceFields: anObject [ 
	somInstanceFields := anObject.
	somInstanceInvokables ~= universe globalNil
		ifTrue: [somInstanceInvokables do: [ :invokable | 
			(invokable isKindOf: SOMMethod)
				ifTrue: [invokable inferFieldIndexesFrom: self]]]
]

{ #category : #accessing }
SOMClass >> somInstanceInvokables [
	^ somInstanceInvokables
]

{ #category : #accessing }
SOMClass >> somInstanceInvokables: anObject [ 
	somInstanceInvokables := anObject.
	somInstanceInvokables do: [ :invokable | invokable somHolder: self ]
]

{ #category : #accessing }
SOMClass >> somName [
	^ somName
]

{ #category : #accessing }
SOMClass >> somName: anObject [ 
	somName := anObject
]

{ #category : #accessing }
SOMClass >> somSuperClass [
	^ somSuperClass
]

{ #category : #accessing }
SOMClass >> somSuperClass: anObject [ 
	somSuperClass := anObject
]

{ #category : #accessing }
SOMClass >> squeakClass [
	"We currently look up the required squeak class at runtime. This could be optimized by
	storing it in an instance field. Implementing this has been deferred, as it is currently not possible to add instance fields to SOMObject subclasses that are not automatically mapped to SOM fields."
	^ Smalltalk 
		at: ('SOM' , self somName string) asSymbol
		ifAbsent: [ self somSuperClass squeakClass ]
]
