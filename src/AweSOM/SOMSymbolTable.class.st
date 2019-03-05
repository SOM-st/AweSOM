Class {
	#name : #SOMSymbolTable,
	#superclass : #IdentityDictionary,
	#instVars : [
		'universe'
	],
	#category : #'AweSOM-VM'
}

{ #category : #'as yet unclassified' }
SOMSymbolTable class >> in: universe [

	^ self new
		universe: universe;
		yourself.
]

{ #category : #'as yet unclassified' }
SOMSymbolTable >> somSymbolFor: squeakSymbol [

	^ self
		at: squeakSymbol 
		ifAbsentPut: [SOMSymbol
			inUniverse: self universe
			string: squeakSymbol].
]

{ #category : #accessing }
SOMSymbolTable >> universe [
	^ universe
]

{ #category : #accessing }
SOMSymbolTable >> universe: anObject [
	universe := anObject
]
