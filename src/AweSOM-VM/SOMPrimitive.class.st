Class {
	#name : #SOMPrimitive,
	#superclass : #SOMInvokable,
	#instVars : [
		'realSignature'
	],
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'primitve selectors' }
SOMPrimitive class >> selectorMapping [

	^ Dictionary newFrom: {		
		$~ -> #Tilde.
		$& -> #And.
		$| -> #Bar.
		$* -> #Star.
		$/ -> #Slash.
		$@ -> #At.
		$+ -> #Plus.
		$- -> #Minus.
		$= -> #Equal.
		$> -> #GreaterThan.
		$< -> #LowerThan.
		$, -> #Comma.
		$% -> #Percent.
		$\ -> #Backslash}
]

{ #category : #'as yet unclassified' }
SOMPrimitive >> invokeInFrame: frame [

	| theSelf arguments result |	
	"without self, self is first argument"
	arguments := frame popN: (self numberOfArguments - 1).
	theSelf := frame pop.
	result := theSelf
		performPrimitive: self realSignature symbol
		withArguments: arguments.
	frame push: result.
]

{ #category : #accessing }
SOMPrimitive >> realSignature [
	^ realSignature
]

{ #category : #accessing }
SOMPrimitive >> realSignature: anObject [
	realSignature := anObject
]

{ #category : #accessing }
SOMPrimitive >> somSignature: anObject [ 

	super somSignature: anObject.
	self realSignature: (self translateSignature: self somSignature string)
]

{ #category : #'as yet unclassified' }
SOMPrimitive >> translateSignature: sqSignature [

	"#abc: --> #primabc: #~~ --> #primTildeTilde"
	| transformedSignature isBinary part |
	isBinary := true.
	transformedSignature := sqSignature
		inject: ''
		into: [:acc :each |
			part := self class selectorMapping
				at: each
				ifAbsent: [isBinary := false. each asString].
			acc , part].
	isBinary ifTrue: [transformedSignature := transformedSignature , ':'].
	^ SOMSymbol
		inUniverse: universe
		string: 'prim' , transformedSignature.
]
