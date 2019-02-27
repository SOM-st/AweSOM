Class {
	#name : #SOMLexer,
	#superclass : #Object,
	#instVars : [
		'stream',
		'text',
		'nextText',
		'lineNumber',
		'peekDone',
		'sym',
		'nextSym',
		'symChr',
		'nextSymChr',
		'buf',
		'bufP'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #'instance creation' }
SOMLexer class >> on: aReadStream [
	| lexer |
	[aReadStream isKindOf: PositionableStream ] assert.
	
	lexer := self new.
	lexer stream: aReadStream.
	^ lexer
]

{ #category : #private }
SOMLexer >> bufchar: p [
	^ p > buf size
		ifTrue:  [nil]
		ifFalse: [buf at: p]
]

{ #category : #private }
SOMLexer >> currentChar [
	^ self bufchar: bufP
]

{ #category : #accessing }
SOMLexer >> currentLineNumber [
	^ lineNumber
]

{ #category : #private }
SOMLexer >> endOfBuffer [
	^ bufP > (buf size)
]

{ #category : #accessing }
SOMLexer >> fillBuffer [
	stream atEnd ifTrue: [^ -1].
	
	buf := stream nextLine.
	buf ifNil: [^ -1].
	
	lineNumber := lineNumber + 1.
	
	bufP := 1.
	^ buf size.
]

{ #category : #private }
SOMLexer >> hasMoreInput [
	self readBufferIfEmpty: [^ false].
	
	^ true
]

{ #category : #'initialize-release' }
SOMLexer >> initialize [
	lineNumber := 0.
	peekDone := false.
	text := RWBinaryOrTextStream on: String new.
	buf := ''.
	bufP := 1.
]

{ #category : #helper }
SOMLexer >> isOperator: char [
	^ char == $~ or: [
	  char == $& or: [
	  char == $| or: [
	  char == $* or: [
	  char == $/ or: [
	  char == $\ or: [
	  char == $+ or: [
	  char == $= or: [
	  char == $> or: [
	  char == $< or: [
	  char == $, or: [
	  char == $@ or: [
	  char == $% or: [
	  char == $- ]]]]]]]]]]]]].
]

{ #category : #lexing }
SOMLexer >> match: aSymbol [
	sym := aSymbol.
	symChr := self currentChar.
	text := RWBinaryOrTextStream with: symChr asString.
	self readNext.
	^ sym.
]

{ #category : #lexing }
SOMLexer >> matchColonOrAssignment [
	(self bufchar: bufP + 1) == $= ifTrue: [
		sym := #assign.
		bufP := bufP + 2.
		symChr := nil.
		text := RWBinaryOrTextStream with: ':='.
		^ sym
	].

	^ self match: #colon.
]

{ #category : #lexing }
SOMLexer >> matchDigit [
	| sawDecimalMark |
	sym    := #integer.
	symChr := nil.
	text   := RWBinaryOrTextStream on: String new.
	
	sawDecimalMark := false.

	[ text nextPut: self currentChar.
	  self readNext.
	
	  (sawDecimalMark not and: [
		  $. == self currentChar and: [
			self nextChar notNil and: [ 
				self nextChar isDigit ] ] ]) ifTrue: [
				sym := #double.
				text nextPut: self currentChar.
				self readNext ].
	  
	] doWhileTrue: [self currentChar notNil and: [ self currentChar isDigit ]].

	^ sym
]

{ #category : #lexing }
SOMLexer >> matchEscapeChar [
	| cur |
	cur := self currentChar.
	
	cur == $t ifTrue: [ 
		text nextPut: Character tab ].
	cur == $b ifTrue: [
		text nextPut: Character backspace ].
	cur == $n ifTrue: [
		text nextPut: Character lf ].
	cur == $r ifTrue: [
		text nextPut: Character cr ].
	cur == $f ifTrue: [
		text nextPut: Character newPage ].
	cur == $' ifTrue: [
		text nextPut: $' ].
	cur == $\ ifTrue: [
		text nextPut: $\ ].
	
	Error signal: 'Found unsupported escape sequence. Current character: ', cur asString.	
	
	"self readNext is done by caller to simplify the smalltalk code"
]

{ #category : #lexing }
SOMLexer >> matchLetter [
	symChr := nil.
	text := RWBinaryOrTextStream on: String new.
	
	[self currentChar notNil and: [
		 self currentChar isLetter or: [
		 self currentChar isDigit  or: [
		 self currentChar == $_]]]]
		whileTrue: [
			text nextPut: self currentChar.
			self readNext.
		].
	
	sym := #identifier.
	
	self currentChar == $: ifTrue: [
		sym := #keyword.
		self readNext.
		text nextPut: $:.
		
		(self currentChar notNil and: [self currentChar isLetter]) ifTrue: [
			sym := #keywordSequence.
			[self currentChar isLetter or: [self currentChar == $:]]
				whileTrue: [
					text nextPut: self currentChar.
					self readNext.
				]
		]
	].

	^ sym
]

{ #category : #lexing }
SOMLexer >> matchMinusOrSeparator [
	(self nextInBufIs: self seperator) ifTrue: [
		text := RWBinaryOrTextStream on: String new.
		[self currentChar == $-] whileTrue: [
			text nextPut: $-.
			self readNext.
		].
		sym := #seperator.
		^ sym.
	].

	^ self matchOperator

]

{ #category : #lexing }
SOMLexer >> matchOperator [
	| cur |
	(self isOperator: (self bufchar: bufP + 1)) ifTrue: [
		sym := #operatorSequence.
		symChr := nil.
		text := RWBinaryOrTextStream on: String new.
		
		[self isOperator: self currentChar] whileTrue: [
			text nextPut: self currentChar.
			self readNext.
		].
		^ sym.
	].

	cur := self currentChar.
	cur == $~ ifTrue: [ ^ self match: #not ].
	cur == $& ifTrue: [ ^ self match: #and ].
	cur == $| ifTrue: [ ^ self match: #or  ].
	cur == $* ifTrue: [ ^ self match: #star].
	cur == $/ ifTrue: [ ^ self match: #div ].
	cur == $\ ifTrue: [ ^ self match: #mod ].
	cur == $+ ifTrue: [ ^ self match: #plus].
	cur == $= ifTrue: [ ^ self match: #equal].
	cur == $> ifTrue: [ ^ self match: #more].
	cur == $< ifTrue: [ ^ self match: #less].
	cur == $, ifTrue: [ ^ self match: #comma].
	cur == $@ ifTrue: [ ^ self match: #at  ].
	cur == $% ifTrue: [ ^ self match: #per ].
	cur == $- ifTrue: [ ^ self match: #minus ].
	
	Error signal: 'STEFAN: this is unexpected, I think...'.
]

{ #category : #lexing }
SOMLexer >> matchPrimitive [
	bufP := bufP + self primitive size.
	sym := #primitive.
	symChr := nil.
	text := RWBinaryOrTextStream with: self primitive.
	^ sym
	
]

{ #category : #lexing }
SOMLexer >> matchString [
	sym := #STString.
	symChr := nil.
	text := RWBinaryOrTextStream on: String new.
	
	self readNext. "skip start $' "
	[ self currentChar == $' ]
		whileFalse: [
			self matchStringChar.
			self readBufferIfEmpty: [ ^ sym ]
		].
	
	self readNext. "skip the ending $'"
	
	^ sym
]

{ #category : #lexing }
SOMLexer >> matchStringChar [
	| cur |
	cur := self currentChar.
	$\ == cur
		ifTrue: [
			self readNext.
			self matchEscapeChar.
			self readNext ]
		ifFalse: [
			text nextPut: cur.
			self readNext ]

]

{ #category : #private }
SOMLexer >> nextChar [
	^ self bufchar: bufP + 1
]

{ #category : #helper }
SOMLexer >> nextInBufIs: aString [
	| p |
	p := buf findString: aString startingAt: bufP.
	^ p == bufP
]

{ #category : #accessing }
SOMLexer >> nextText [
	^ nextText asString
]

{ #category : #helper }
SOMLexer >> nextWordInBufIs: aString [
   (self nextInBufIs: aString) ifTrue: [
     | nextPos nextChar |
      nextPos := bufP + aString size.
       
      nextPos > buf size ifTrue: [^true].
       
      nextChar := buf at: nextPos.
      ^ (nextChar isLetter or: [nextChar isDigit]) not.
	].

	^ false.
]

{ #category : #lexing }
SOMLexer >> peek [
	| oldSym oldSymChr oldText |
	peekDone
		ifTrue: [ Error signal: 'SOM Lexer: cannot peek twice!' ].
	
	oldSym    := sym.
	oldSymChr := symChr.
	oldText   := RWBinaryOrTextStream with: text contents.
	
	nextSym   := self symbol.
	nextSymChr:= symChr.
	nextText  := text.
	
	sym   := oldSym.
	symChr:= oldSymChr.
	text  := oldText.
	
	peekDone := true.
	
	^ nextSym.
]

{ #category : #lexing }
SOMLexer >> peekDone [
	^ peekDone

]

{ #category : #constant }
SOMLexer >> primitive [
	^ 'primitive'
]

{ #category : #accessing }
SOMLexer >> rawBuffer [
	^ buf
]

{ #category : #helper }
SOMLexer >> readBufferIfEmpty: aBlock [
	[self endOfBuffer] whileTrue: [
		self fillBuffer == -1
			ifTrue: aBlock]
]

{ #category : #private }
SOMLexer >> readNext [
	bufP := bufP + 1
]

{ #category : #constant }
SOMLexer >> seperator [
	^ '----'
]

{ #category : #helper }
SOMLexer >> skipComment [
	self currentChar == $" ifTrue: [
		[
			self readNext.
			self readBufferIfEmpty: [^ self].
		] doWhileTrue: [self currentChar ~= $"].
		self readNext.
	].

]

{ #category : #helper }
SOMLexer >> skipWhitespace [
	[self currentChar isSeparator]
		whileTrue: [
			self readNext.
			self readBufferIfEmpty: [^ self]]
]

{ #category : #helper }
SOMLexer >> skipWhitespaceAndCommentsOrEnd: atEndBlock [
	[	self hasMoreInput ifFalse: atEndBlock.
		self skipWhitespace.
		self skipComment.
	] doWhileTrue: [
		self endOfBuffer 				or: [
		self currentChar isSeparator 	or: [
		self currentChar == $" ]]].
]

{ #category : #accessing }
SOMLexer >> stream: aReadStream [
	stream := aReadStream.
]

{ #category : #lexing }
SOMLexer >> symbol [
	| currentChar |
	peekDone ifTrue: [^ self symbolAfterPeek].
	
	self skipWhitespaceAndCommentsOrEnd: [
		sym := #none.
		symChr := nil.
		text := RWBinaryOrTextStream on: String new.
		^ sym
	].

	currentChar := self currentChar.
	
	currentChar == $' ifTrue: [ ^ self matchString ].
	currentChar == $[ ifTrue: [ ^ self match: #newBlock ].
	currentChar == $] ifTrue: [ ^ self match: #endBlock ].
	currentChar == $: ifTrue: [ ^ self matchColonOrAssignment ].
	currentChar == $( ifTrue: [ ^ self match: #newTerm ].
	currentChar == $) ifTrue: [ ^ self match: #endTerm ].
	currentChar == $# ifTrue: [ ^ self match: #pound   ].
	currentChar == $^ ifTrue: [ ^ self match: #exit    ].
	currentChar == $. ifTrue: [ ^ self match: #period  ].
	currentChar == $- ifTrue: [ ^ self matchMinusOrSeparator ].
	(self isOperator: currentChar) ifTrue: [ ^ self matchOperator ].

	(self nextWordInBufIs: self primitive) ifTrue: [ ^ self matchPrimitive ].
	
	currentChar isLetter ifTrue: [ ^ self matchLetter ].
	currentChar isDigit  ifTrue: [ ^ self matchDigit  ].
	
	"else"
	sym    := #none.
	symChr := currentChar.
	text   := RWBinaryOrTextStream with: currentChar asString.
	
	^ sym
]

{ #category : #lexing }
SOMLexer >> symbolAfterPeek [
	peekDone := false.
	sym      := nextSym.
	symChr   := nextSymChr.
	text     := nextText.
	^ sym
]

{ #category : #accessing }
SOMLexer >> text [
	^ text contents
]
