Class {
	#name : #SOMObjectTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-VM-Test'
}

{ #category : #tests }
SOMObjectTest >> test01CreateSimpleObject [
	| object somFieldCnt |
	somFieldCnt := SOMObject allSharedFields size.
	
	object := SOMObject inUniverse: universe withNumberOfAdditionalFields: 1.
	
	
	"Objects now come with a default class"
	"self 
		assert: (object fieldAtIndex: 1)
		equals: (universe globalAt: #nil)."
	self 
		assert: (object fieldAtIndex: somFieldCnt + 1)
		equals: (universe globalNil).
	self assert: object numberOfFields equals: somFieldCnt + 1.
]

{ #category : #tests }
SOMObjectTest >> test02FieldAccess [
	| object1 object2 |
	object1 := SOMObject inUniverse: universe withNumberOfAdditionalFields: 1.
	object2 := SOMObject inUniverse: universe withNumberOfAdditionalFields: 0.
	object1 
		fieldAtIndex: 1
		put: object2.
	self 
		assert: (object1 fieldAtIndex: 1)
		equals: object2
]

{ #category : #tests }
SOMObjectTest >> test03aSharedFields [
	| clazz object somFieldCnt |
	somFieldCnt := SOMObject allSharedFields size.
	
	clazz := SOMObject inUniverse: universe.
	object := SOMObject 
		inUniverse: universe
		withNumberOfAdditionalFields: 0.
	object somClass: clazz.
	
	self 
		assert: object somClass
		equals: (object fieldAtIndex: 1).
	object somClass: nil.
	object 
		fieldAtIndex: 1
		put: clazz.
	self 
		assert: object somClass
		equals: (object fieldAtIndex: 1).
	self 
		should: [ object fieldAtIndex: 1 + somFieldCnt ]
		raise: Error.
	self 
		should: 
			[ object 
				fieldAtIndex: 1 + somFieldCnt
				put: 42 ]
		raise: Error
]

{ #category : #tests }
SOMObjectTest >> test03bSharedFields [
	| clazz1 clazz2 somFieldCnt clsIdx |
	somFieldCnt := SOMObject allSharedFields size.
	clsIdx := somFieldCnt + 1.
	
	clazz1 := universe classClass inUniverse: universe.
	clazz2 := universe classClass inUniverse: universe.
	clazz1 somSuperClass: clazz2.
	self 
		assert: clazz2
		equals: clazz1 somSuperClass.
	self 
		assert: clazz2
		equals: (clazz1 fieldAtIndex: clsIdx ).
	clazz1 somSuperClass: nil.
	self 
		assert: nil
		equals: clazz1 somSuperClass.
	self 
		assert: nil
		equals: (clazz1 fieldAtIndex: clsIdx).
	clazz1 
		fieldAtIndex: clsIdx
		put: clazz2.
	self 
		assert: clazz2
		equals: clazz1 somSuperClass.
	self 
		assert: clazz2
		equals: (clazz1 fieldAtIndex: clsIdx)
]

{ #category : #tests }
SOMObjectTest >> test04Array [

	| array |
	array := SOMArray inUniverse: universe size: 2.
	array at: 1 put: 42.
	array at: 2 put: 23.
	self assert: (array at: 1) equals: 42.
	self assert: (array at: 2) equals: 23
]

{ #category : #tests }
SOMObjectTest >> test04bArray [
	| array |
	self loadClazzes: {  #Object. #Array  }.
	array := SOMArray 
		inUniverse: universe
		withSomClass: (universe globalAt: #Array)
		numIndexable: 3.
	array 
		at: 3
		put: 42.
	self 
		assert: (array at: 3)
		equals: 42.
	self 
		should: [ array at: 4 ]
		raise: Error
]

{ #category : #tests }
SOMObjectTest >> test05UniverseAccess [

	| array |
	array := SOMArray inUniverse: universe withNumberOfAdditionalFields: 2.
	self assert: array universe globalNil equals: universe globalNil.
]
