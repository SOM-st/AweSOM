Class {
	#name : #SOMObjectTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-VM-Test'
}

{ #category : #tests }
SOMObjectTest >> test01CreateSimpleObject [
	| object |
	object := SOMObject inUniverse: universe withNumberOfAdditionalFields: 1.
	
	
	"Objects now come with a default class"
	"self 
		assert: (object fieldAtIndex: 1)
		equals: (universe globalAt: #nil)."
	self 
		assert: (object fieldAtIndex: 1)
		equals: (universe globalNil).
	self assert: object numberOfFields equals: 1.
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
SOMObjectTest >> test04Array [

	| array |
	array := universe newArray: 2.
	array at: 1 put: 42.
	array at: 2 put: 23.
	self assert: (array at: 1) equals: 42.
	self assert: (array at: 2) equals: 23
]

{ #category : #tests }
SOMObjectTest >> test04bArray [
	| array |
	self loadClazzes: #(#Object #Array).
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
