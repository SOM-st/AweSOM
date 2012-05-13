Class {
	#name : #SOMClassParser,
	#superclass : #SOMParser,
	#category : #'AweSOM-Compiler'
}

{ #category : #'as yet unclassified' }
SOMClassParser >> classBody [
	self expect: #newTerm.
	
	self classSide.
	
	self classInstanceSwitch ifTrue: [
		cgenc toggleClassSide.
		self classSide.].
	
	self expect: #endTerm.
]

{ #category : #'as yet unclassified' }
SOMClassParser >> classInstanceSwitch [
	^ self accept: #seperator.
]

{ #category : #'as yet unclassified' }
SOMClassParser >> classSide [
	self vars.
	
	[sym == #identifier       or: [
	 sym == #keyword          or: [
	 sym == #operatorSequence or: [
	 self symIn: BinaryOpSyms]]]]
		whileTrue: [
			self foreignParseMethod].
]

{ #category : #'as yet unclassified' }
SOMClassParser >> classStart [
	cgenc theName: text asSymbol.
	self expect: #identifier.
	
	self expect: #equal.
	
	sym == #identifier
		ifTrue:  [cgenc superName: text.
					self accept: #identifier.].
		
]

{ #category : #'as yet unclassified' }
SOMClassParser >> classdef [
	self classStart.
	self classBody.
]

{ #category : #'as yet unclassified' }
SOMClassParser >> foreignParseMethod [
	| parser result |
	parser := self methodParser.
	parser parseState: self parseState.
	
	result := parser apply: #method.
	
	cgenc addMethod: result.
	self parseState: parser parseState.
	^ result
]

{ #category : #'as yet unclassified' }
SOMClassParser >> initialize [
	super initialize.
	
	self cgenc: SOMClassGenerationContext new.
]

{ #category : #'as yet unclassified' }
SOMClassParser >> methodParser [

	^ super methodParser
		cgenc: self cgenc;
		yourself.
]

{ #category : #'as yet unclassified' }
SOMClassParser >> start [
	self classdef.
	^ cgenc
]

{ #category : #'as yet unclassified' }
SOMClassParser >> vars [
	(self accept: #or) ifTrue: [
		[sym == #identifier] whileTrue: [
			cgenc addField: self variable.
		].
		
		self expect: #or.
	]
]
