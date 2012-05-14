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
SOMCompiler >> compileSOMClassSource: source stub: classStubOrNil [

	| cgenc |
	cgenc := (universe classParser inUniverse: universe onSource: source) start.
	^ classStubOrNil
		ifNil: [cgenc assembleIn: universe]
		ifNotNil: [cgenc assembleIn: universe stub: classStubOrNil].
]

{ #category : #loading }
SOMCompiler >> loadAndCompileSOMClass: className stub: classStubOrNil [

	| source |
	source := self sourceOfClassFile: className.
	source ifNil: [^ nil].
	^ self compileSOMClassSource: source stub: classStubOrNil.
]

{ #category : #'file access' }
SOMCompiler >> sourceOfClassFile: className [

	| classFile theDir source |
	classFile := className , self classFileExtension.
	theDir := (self classPaths
		collect: [:path |FileDirectory on: path])
		detect: [:dir | dir fileExists: classFile]
		ifNone: [^ nil].
	"theDir ifNil: [self error: 'Cannot find class in classPath']."
	FileStream
		fileNamed: (theDir fullPathFor: classFile)
		do: [:s | source := s contents].
	^ source
]

{ #category : #accessing }
SOMCompiler >> universe [
	^ universe
]

{ #category : #accessing }
SOMCompiler >> universe: anObject [
	universe := anObject
]
