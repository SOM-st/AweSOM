Class {
	#name : #SOMClassParser,
	#superclass : #SOMParser,
	#category : #'AweSOM-Compiler'
}

{ #category : #patterns }
SOMClassParser >> classBody [
	self expect: #newTerm.
	
	self classSide.
	
	self classInstanceSwitch ifTrue: [
		cgenc toggleClassSide.
		self classSide.].
	
	self expect: #endTerm.
]

{ #category : #patterns }
SOMClassParser >> classInstanceSwitch [
	^ self accept: #seperator.
]

{ #category : #patterns }
SOMClassParser >> classSide [
	self vars.
	
	[sym == #identifier       or: [
	 sym == #keyword          or: [
	 sym == #operatorSequence or: [
	 self symIn: BinaryOpSyms]]]]
		whileTrue: [
			self foreignParseMethod].
]

{ #category : #patterns }
SOMClassParser >> classStart [
	cgenc theName: self identifier.
	
	self expect: #equal.
	
	sym == #identifier
		ifTrue:  [cgenc superName: self identifier.].
		
]

{ #category : #patterns }
SOMClassParser >> classdef [
	self classStart.
	self classBody.
]

{ #category : #patterns }
SOMClassParser >> foreignParseMethod [
	| parser result |
	parser := self methodParser.
	parser parseState: self parseState.
	
	result := parser apply: #method.
	
	cgenc addMethod: result.
	self parseState: parser parseState.
	^ result
]

{ #category : #'initialize-release' }
SOMClassParser >> initialize [
	super initialize.
	
	self cgenc: SOMClassGenerationContext new.
]

{ #category : #helper }
SOMClassParser >> methodParser [

	^ super methodParser
		cgenc: self cgenc;
		yourself.
]

{ #category : #parsing }
SOMClassParser >> start [
	self classdef.
	^ cgenc
]

{ #category : #patterns }
SOMClassParser >> vars [
	(self accept: #or) ifTrue: [
		[sym == #identifier] whileTrue: [
			cgenc addField: self variable.
		].
		
		self expect: #or.
	]
]
