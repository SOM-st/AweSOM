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
	
	[self symIsIdentifier     or: [
	 sym == #keyword          or: [
	 sym == #operatorSequence or: [
	 self symIn: BinaryOpSyms]]]]
		whileTrue: [
			self foreignParseMethod].
]

{ #category : #patterns }
SOMClassParser >> classStart [
	| superName |
	cgenc theName: self identifier.
	
	self expect: #equal.
	
	superName := sym == #identifier
		ifTrue:  [ self identifier ]
		ifFalse: [ #Object ].
	cgenc superName: superName.
	
	"Load the super class, if it is not nil (to break dependency cycle)"
	superName == #nil ifFalse: [ 
		| superClass |
		superClass := universe loadSOMClass: superName.
		
		superClass ifNil: [
			SOMParseError signalWith: 'Super class "', superName asString, '" could not be loaded'
							 expectedSym: nil and: self ].

		cgenc addInstanceFields: superClass allInstanceFields.
		cgenc addClassFields: superClass somClass allInstanceFields.		
	].
	

		
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
		[self symIsIdentifier] whileTrue: [
			cgenc addField: self variable.
		].
		
		self expect: #or.
	]
]
