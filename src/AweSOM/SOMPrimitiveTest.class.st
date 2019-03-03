Class {
	#name : #SOMPrimitiveTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-VM-Test'
}

{ #category : #tests }
SOMPrimitiveTest >> test01AddIntegers [
	| a b c |
	a := universe newNumber: 5.
	b := universe newNumber: 7.
	c := a primPlus: b.
	self 
		assert: c number
		equals: 12.
	self 
		assert: c somClass
		equals: (universe globalAt: #Integer).
	a := SOMInteger 
		inUniverse: universe
		new: 5.
	b := SOMDouble 
		inUniverse: universe
		new: 7.5.
	c := a primPlus: b.
	self 
		assert: c number
		equals: 12.5.
	self 
		assert: c somClass
		equals: (universe globalAt: #Double)
]

{ #category : #tests }
SOMPrimitiveTest >> test02AsString [
	| a s |
	a := SOMInteger 
		inUniverse: universe
		new: 5678.
	s := a primasString.
	self 
		assert: s string
		equals: '5678'.
	self 
		assert: s somClass
		equals: (universe globalAt: #String)
]

{ #category : #tests }
SOMPrimitiveTest >> test03PrimitiveNames [
	| primitive |
	primitive := SOMPrimitive inUniverse: universe.
	primitive somSignature: (SOMSymbol 
			inUniverse: universe
			string: '-').
	self 
		assert: primitive realSignature string
		equals: #primMinus:.
	primitive somSignature: (SOMSymbol 
			inUniverse: universe
			string: '//').
	self 
		assert: primitive realSignature string
		equals: #primSlashSlash:.
	primitive somSignature: (SOMSymbol 
			inUniverse: universe
			string: 'key:word:').
	self 
		assert: primitive realSignature string
		equals: #primkey:word:.
	primitive somSignature: (SOMSymbol 
			inUniverse: universe
			string: 'unary').
	self 
		assert: primitive realSignature string
		equals: #primunary
]

{ #category : #tests }
SOMPrimitiveTest >> test04PrimitiveNew [
	| clazz instance primLength |
	self loadClazzes: #(#Object #Array).
	clazz := universe globalAt: #Array.
	instance := clazz primnew.
	self 
		assert: instance somClass
		equals: clazz.
	instance := clazz 
		performPrimitive: #primnew:
		withArguments: {  (universe newNumber: 5)  }.
	self 
		assert: instance somClass
		equals: clazz.
	primLength := instance 
		performPrimitive: #primlength
		withArguments: {   }.
	self 
		assert: primLength number
		equals: 5
]

{ #category : #tests }
SOMPrimitiveTest >> test05PrimitiveComparison [

	| symbol1 symbol2 string1 |
	symbol1 := universe newSymbol: 'banana'.
	symbol2 := universe newSymbol: 'banana'.
	string1 := universe newString: 'banana'.
	self assert: (symbol1 primEqualEqual: symbol2) equals: (universe newBool: true).
	
	self assert: (symbol1 primEqual: string1) equals: (universe newBool: true).
]
