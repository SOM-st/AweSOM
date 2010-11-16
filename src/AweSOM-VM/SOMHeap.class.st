Class {
	#name : #SOMHeap,
	#superclass : #Object,
	#instVars : [
		'universe',
		'objects',
		'maxSize'
	],
	#category : #'AweSOM-GarbageCollector'
}

{ #category : #'as yet unclassified' }
SOMHeap class >> in: universe [

	^ self new
		universe: universe;
		yourself.
]

{ #category : #allocating }
SOMHeap >> allocateFor: object [

	(object isSOMNumber or: [object isSOMSymbol]) ifTrue: [^ self].
	object gcField: false.
	self basicAllocateFor: object.
	self objects size > self maxSize ifTrue: [
		self collectGarbage].
]

{ #category : #allocating }
SOMHeap >> basicAllocateFor: object [

	self objects add: object
]

{ #category : #'garbage collection' }
SOMHeap >> collectGarbage [

	self
		mark;
		sweep.
	self objects size > self maxSize ifTrue: [
		self error: 'Couldn''t free enough space from heap'].
]

{ #category : #default }
SOMHeap >> defaultMaxObjects [

	^ 5000
]

{ #category : #initialization }
SOMHeap >> initialize [

	super initialize.
	objects := OrderedCollection new.
	maxSize := self defaultMaxObjects.
]

{ #category : #'garbage collection' }
SOMHeap >> mark [

	self rootObjects do: [:ea | self markObject: ea].
]

{ #category : #'garbage collection' }
SOMHeap >> markObject: somObject [

	somObject isSOMObject ifFalse: [^ self].
	somObject gcField ifNil: [^ self].
	somObject gcField ifTrue: [^ self].
	somObject gcField: true.
	somObject allMyReferences do: [:ea | self markObject: ea].
]

{ #category : #accessing }
SOMHeap >> maxSize [
	^ maxSize
]

{ #category : #accessing }
SOMHeap >> maxSize: anObject [
	maxSize := anObject
]

{ #category : #accessing }
SOMHeap >> objects [
	^ objects
]

{ #category : #accessing }
SOMHeap >> objects: anObject [
	objects := anObject
]

{ #category : #accessing }
SOMHeap >> rootObjects [

	^ self universe globals values , self universe symbolTable values
]

{ #category : #'garbage collection' }
SOMHeap >> sweep [

	"remove marked objects from heap
	reset unmarked objects at the same time"
	| remove |
	self objects removeAllSuchThat: [:ea |
		remove := ea gcField = false.
		ea gcField: false.
		remove].
]

{ #category : #accessing }
SOMHeap >> universe [
	^ universe
]

{ #category : #accessing }
SOMHeap >> universe: anObject [
	universe := anObject
]
