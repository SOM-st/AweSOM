Class {
	#name : #TestCaseWithUniverse,
	#superclass : #TestCase,
	#instVars : [
		'universe'
	],
	#category : #'AweSOM-Test'
}

{ #category : #'as yet unclassified' }
TestCaseWithUniverse >> loadClazzes: classes [ 

	classes do: [:class | universe loadSystemClass: class]
]

{ #category : #'as yet unclassified' }
TestCaseWithUniverse >> setUp [
	super setUp.
	universe := SOMUniverse new.
	universe initializeFakeGlobals.
]
