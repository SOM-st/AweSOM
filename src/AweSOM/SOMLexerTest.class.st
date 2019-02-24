Class {
	#name : #SOMLexerTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-Compiler-Test'
}

{ #category : #tests }
SOMLexerTest >> testIsOperator [
	| lexer |
	lexer := SOMLexer new.

	'~&|*/\+=><,@%' asCharacterSet do: [:c |
		self assert: (lexer isOperator: c).
	]
	
]
