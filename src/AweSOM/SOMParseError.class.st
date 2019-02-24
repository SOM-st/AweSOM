"
I represent an error that occured doing parsing.

I know all the details of where the error occured,
and what the original expectation was that go violated.
I try to provide actionable information to the developer.
"
Class {
	#name : #SOMParseError,
	#superclass : #Error,
	#instVars : [
		'line',
		'column',
		'text',
		'fileName',
		'foundSym',
		'expectedSym'
	],
	#category : #'AweSOM-Compiler'
}

{ #category : #signalling }
SOMParseError class >> signalWith: message expectedSym: aSym and: parser [
	^ self new
		signalWith: message expectedSym: aSym and: parser
]

{ #category : #signalling }
SOMParseError >> signalWith: message expectedSym: aSym and: parser [
	| msg |
	line   := parser currentLineNumber.
	column := parser currentColumn.
	text   := parser rawBuffer.
   fileName := parser fileName.
   foundSym := parser sym.
   expectedSym := aSym.

	msg := ('<3p>:<4p>:<5p>: error: ', message)
					expandMacrosWithArguments: { expectedSym. foundSym. fileName. line. column }.

	^ self signal: msg, text
]
