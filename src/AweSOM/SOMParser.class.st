Class {
	#name : #SOMParser,
	#superclass : #Object,
	#instVars : [
		'universe',
		'cgenc',
		'sym',
		'text',
		'lexer',
		'nextSym',
		'shouldReadSources',
		'fileName'
	],
	#classVars : [
		'BinaryOpSyms',
		'KeywordSelectorSyms',
		'SingleOpSyms'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #'instance creation' }
SOMParser class >> inUniverse: universe onSource: string from: aFileName [
	| readStream parser |
	readStream := string asString readStream.
	
	parser := self new.
	parser stream: readStream.
	parser universe: universe.
	parser fileName: aFileName.
	
	^ parser
]

{ #category : #'class initialization' }
SOMParser class >> initialize [
	"self initialize"
	SingleOpSyms := #(                     not and or star div mod plus equal more less comma at per none).
	BinaryOpSyms := #(or comma minus equal not and or star div mod plus equal more less comma at per none).
	KeywordSelectorSyms := #(keyword keywordSequence).
	
]

{ #category : #'accept and expect' }
SOMParser >> accept: aSymbol [
	sym == aSymbol ifTrue: [
		self getSym.
		^ true ].

	^ false
]

{ #category : #compatibility }
SOMParser >> apply: aSymbol [
	"For compatibilty with OMeta"
	^ self perform: aSymbol
]

{ #category : #accessing }
SOMParser >> cgenc [
	^ cgenc
]

{ #category : #accessing }
SOMParser >> cgenc: anObject [
	cgenc := anObject
]

{ #category : #accessing }
SOMParser >> currentColumn [
	^ -1
]

{ #category : #accessing }
SOMParser >> currentLineNumber [
	^ lexer currentLineNumber
]

{ #category : #'accept and expect' }
SOMParser >> expect: aSymbol [
	(self accept: aSymbol) ifTrue: [ ^ true ].
		
	SOMParseError signalWith: 'Expected symbol <1p>, but found <2p>.'
				    expectedSym: aSymbol and: self
]

{ #category : #accessing }
SOMParser >> fileName [
	^ fileName
]

{ #category : #accessing }
SOMParser >> fileName: aString [
	fileName := aString asString
]

{ #category : #private }
SOMParser >> getSym [
	sym  := lexer symbol.
	text := lexer text.
]

{ #category : #patterns }
SOMParser >> identifier [
	| s | 
	s := text asSymbol.
	
	(self accept: #primitive) ifFalse: [
		self expect: #identifier]. 
	
	^ s
]

{ #category : #'initialize-release' }
SOMParser >> initialize [
	super initialize.
	sym := #none.
	nextSym := #none.
	shouldReadSources := false.
]

{ #category : #helper }
SOMParser >> methodParser [
	^ universe methodParser new
			universe: self universe;
			fileName: fileName;
			shouldReadSources: self shouldReadSources;
			yourself
]

{ #category : #accessing }
SOMParser >> parseState [
	^ {sym. text. lexer. nextSym.}
]

{ #category : #accessing }
SOMParser >> parseState: state [
	sym    := state first.
	text   := state second.
	lexer  := state third.
	nextSym:= state fourth.
]

{ #category : #private }
SOMParser >> peek [
	nextSym := lexer peek.
]

{ #category : #private }
SOMParser >> printableSymbol [
	^ sym == #integer         or: [
	  sym == #STString        or: [
	  self symIsIdentifier    or: [
	  sym == #keyword         or: [
	  sym == #keywordSequence or: [
	  sym == #operatorSequence    ]]]]]
]

{ #category : #accessing }
SOMParser >> rawBuffer [
	^ lexer rawBuffer
]

{ #category : #accessing }
SOMParser >> shouldReadSources [
	^ shouldReadSources
]

{ #category : #accessing }
SOMParser >> shouldReadSources: aBool [
	shouldReadSources := aBool
]

{ #category : #accessing }
SOMParser >> stream: aReadStream [
	lexer := SOMLexer on: aReadStream.
	self getSym.
]

{ #category : #accessing }
SOMParser >> sym [
	^ sym
]

{ #category : #helper }
SOMParser >> symIn: symbols [
	^ symbols includes: sym 
]

{ #category : #helper }
SOMParser >> symIsIdentifier [
	^ sym == #identifier or: [sym == #primitive]
]

{ #category : #accessing }
SOMParser >> text [
	^ text
]

{ #category : #accessing }
SOMParser >> universe [
	^ universe
]

{ #category : #accessing }
SOMParser >> universe: anObject [
	universe := anObject
]

{ #category : #patterns }
SOMParser >> variable [
	^ self identifier
]
