Class {
	#name : #SOMGCTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-GarbageCollector-Test'
}

{ #category : #'as yet unclassified' }
SOMGCTest >> setUp [

	universe := SOMUniverse new.
	universe globalAt: #nil put: nil.
]

{ #category : #'as yet unclassified' }
SOMGCTest >> test01ObjectCollectionExists [

	universe initializeFakeGlobals.
	self assert: universe heap objects notEmpty.
]

{ #category : #'as yet unclassified' }
SOMGCTest >> test02CollectUnreferencedObjects [

	| object |
	self assert: universe heap objects isEmpty.
	object := SOMObject inUniverse: universe.
	self assert: universe heap objects size equals: 1.
	universe heap collectGarbage.
	self assert: universe heap objects isEmpty.
]

{ #category : #'as yet unclassified' }
SOMGCTest >> test03DontCollectGlobalObjects [

	| object |
	object := SOMObject inUniverse: universe.
	universe globalAt: #test put: object.
	self assert: universe heap objects size equals: 1.
	universe heap collectGarbage.
	self assert: universe heap objects size equals: 1.
]

{ #category : #'as yet unclassified' }
SOMGCTest >> test04DontCollectObjectsReferencedFromGlobals [

	| arr object |
	arr := SOMArray inUniverse: universe size: 1.
	universe globalAt: #test put: arr.
	object := SOMObject inUniverse: universe.
	arr at: 1 put: object.
	self assert: universe heap objects size equals: 2.
	universe heap collectGarbage.
	self assert: universe heap objects size equals: 2.
]

{ #category : #'as yet unclassified' }
SOMGCTest >> test05CollectObjectsNotReferencedAnymore [

	| arr object2 |
	arr := SOMArray inUniverse: universe size: 1.
	universe globalAt: #test put: arr.
	object2 := SOMObject inUniverse: universe.
	arr at: 1 put: object2.
	self assert: universe heap objects size equals: 2.
	universe heap collectGarbage.
	self assert: universe heap objects size equals: 2.
	arr at: 1 put: nil.
	universe heap collectGarbage.
	self assert: universe heap objects size equals: 1.
]
