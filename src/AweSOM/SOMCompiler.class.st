Class {
	#name : #SOMCompiler,
	#superclass : #Object,
	#instVars : [
		'universe',
		'classPaths'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #'as yet unclassified' }
SOMCompiler class >> inUniverse: universe on: classPaths [

	^ self new
		classPaths: classPaths;
		universe: universe;
		yourself.
]

{ #category : #'file access' }
SOMCompiler >> classFileExtension [

	^ '.som'
]

{ #category : #accessing }
SOMCompiler >> classPaths [
	^ classPaths
]

{ #category : #accessing }
SOMCompiler >> classPaths: anObject [
	classPaths := anObject
]

{ #category : #compiling }
SOMCompiler >> compileSOMClassSource: source stub: classStubOrNil from: aFileName [

	| cgenc |
	cgenc := (universe classParser inUniverse: universe onSource: source from: aFileName) start.
	^ classStubOrNil
		ifNil: [cgenc assembleIn: universe]
		ifNotNil: [cgenc assembleIn: universe stub: classStubOrNil].
]

{ #category : #loading }
SOMCompiler >> loadAndCompileSOMClass: className stub: classStubOrNil [

	| sourceAndFile |
	sourceAndFile := self sourceOfClassFile: className.
	sourceAndFile ifNil: [^ nil].
	^ self compileSOMClassSource: (sourceAndFile at: 1) stub: classStubOrNil from: (sourceAndFile at: 2).
]

{ #category : #'file access' }
SOMCompiler >> sourceOfClassFile: className [

	| classFile theDir source stream |
	classFile := className , self classFileExtension.
	theDir := (self classPaths
		collect: [:path | path asFileReference ])
		detect: [:dir | (dir resolveString: classFile) exists ]
		ifNone: [^ nil].
	"theDir ifNil: [self error: 'Cannot find class in classPath']."
	stream := (theDir resolveString: classFile) readStream.
	source := stream contents.
	stream close.
	^ {source. classFile}
]

{ #category : #accessing }
SOMCompiler >> universe [
	^ universe
]

{ #category : #accessing }
SOMCompiler >> universe: anObject [
	universe := anObject
]
