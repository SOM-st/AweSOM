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
		'shouldReadSources'
	],
	#classVars : [
		'BinaryOpSyms',
		'KeywordSelectorSyms',
		'SingleOpSyms'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #'instance creation' }
SOMParser class >> inUniverse: universe onSource: string [
	| readStream parser |
	readStream := string asString readStream.
	
	parser := self new.
	parser stream: readStream.
	parser universe: universe.
	
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

{ #category : #'accept and expect' }
SOMParser >> expect: aSymbol [
	| msg |
	(self accept: aSymbol) ifTrue: [ ^ true ].
	
	msg := RWBinaryOrTextStream on: String new.
	msg nextPutAll: 'unexpected symbol in line '.
	msg nextPutAll: lexer currentLineNumber asString.
	msg nextPutAll: '. Expected '.
	msg nextPutAll: aSymbol asString.
	msg nextPutAll: ', but found '.
	msg nextPutAll: sym asString.
	
	self printableSymbol ifTrue: [
		msg nextPutAll: ' (', text contents, ')'.].
	
	msg nextPutAll: ': '.
	msg nextPutAll: lexer rawBuffer.
	
	Error signal: msg contents.
]

{ #category : #'as yet unclassified' }
SOMParser >> getSym [
	sym  := lexer symbol.
	text := lexer text.
]

{ #category : #'as yet unclassified' }
SOMParser >> identifier [
	| s | 
	s := text.
	
	(self accept: #primitive) ifFalse: [
		self expect: #identifier]. 
	
	^ s
]

{ #category : #'as yet unclassified' }
SOMParser >> initialize [
	super initialize.
	sym := #none.
	nextSym := #none.
	shouldReadSources := false.
]

{ #category : #'as yet unclassified' }
SOMParser >> methodParser [
	^ SOMMethodParser new
			universe: self universe;
			shouldReadSources: self shouldReadSources;
			yourself
]

{ #category : #'as yet unclassified' }
SOMParser >> parseState [
	^ {sym. text. lexer. nextSym.}
]

{ #category : #'as yet unclassified' }
SOMParser >> parseState: state [
	sym    := state first.
	text   := state second.
	lexer  := state third.
	nextSym:= state fourth.
]

{ #category : #'as yet unclassified' }
SOMParser >> peek [
	nextSym := lexer peek.
]

{ #category : #'as yet unclassified' }
SOMParser >> printableSymbol [
	^ sym == #integer         or: [
	  sym == #STString        or: [
	  sym == #identifier      or: [
	  sym == #keyword         or: [
	  sym == #keywordSequence or: [
	  sym == #operatorSequence    ]]]]]
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

{ #category : #helper }
SOMParser >> symIn: symbols [
	^ symbols includes: sym 
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
