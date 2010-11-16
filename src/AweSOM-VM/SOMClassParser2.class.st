Class {
	#name : #SOMClassParser2,
	#superclass : #SOMParser2,
	#category : #'AweSOM-Compiler'
}

{ #category : #'class parsing' }
SOMClassParser2 >> class [ =

	spaces classStart spaces classBody
]

{ #category : #'class parsing' }
SOMClassParser2 >> classBody [ =

	token('(') classSide (classInstanceSwitch classSide)* token(')')
]

{ #category : #'class parsing' }
SOMClassParser2 >> classInstanceSwitch [ =

	token('----') ($-)* [cgenc toggleClassSide]
]

{ #category : #'class parsing' }
SOMClassParser2 >> classSide [ =

	(vars | empty) (~token('----') foreignParseMethod)*
]

{ #category : #'class parsing' }
SOMClassParser2 >> classStart [ =

	identifier:n [cgenc theName: n asSymbol] token('=') spaces
	(identifier:sN [cgenc superName: sN] | empty)
]

{ #category : #'class parsing' }
SOMClassParser2 >> foreignParseMethod [

	| parser result |
	parser := self methodParser.
	result := parser apply: #method.
	cgenc addMethod: result.
	input := parser input.
	^ result
]

{ #category : #initialization }
SOMClassParser2 >> initialize [

	super initialize.
	self cgenc: SOMClassGenerationContext new.
]

{ #category : #accessing }
SOMClassParser2 >> methodParser [

	^ super methodParser
		cgenc: self cgenc;
		yourself.
]

{ #category : #initialization }
SOMClassParser2 >> start [

	self apply: #class.
	^ cgenc
]

{ #category : #'class parsing' }
SOMClassParser2 >> vars [ =

	token('|') (spaces identifier)*:vars token('|') [cgenc addFields: vars]
]
