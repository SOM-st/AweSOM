Class {
	#name : #SOMClassTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-VM-Test'
}

{ #category : #tests }
SOMClassTest >> test01ObjectCreation [

	| clazz instance |
	self loadClazzes: {#Object}.
	clazz := universe loadSOMClass: #TestHarness.
	instance := clazz primnew.
	self assert: clazz equals: instance somClass
]

{ #category : #tests }
SOMClassTest >> test02Subclassing [
	| somArray newClass newInstance |
	self loadClazzes: #(#Array #Object).
	somArray := universe globalAt: #Array.
	newClass := SOMClass
		inUniverse: universe
		withSomSuperClass: somArray.
	self 
		assert: newClass squeakClass
		equals: SOMArray.
	newInstance := newClass primnew.
	self 
		assert: newInstance somClass
		equals: newClass
]

{ #category : #tests }
SOMClassTest >> test03LookupOfFields [

	| source class method pushBc field |
	self loadClazzes: {#Object}.
	source := 'ClassA = ( | x | m=(x) )'.
	class := universe loadAndStoreFromSource: source.
	method := class somInstanceInvokables at: 1.
	pushBc := method bytecodes first.
	self shouldnt: [field := class allInstanceFields at: pushBc fieldIndex] raise: Error.
	self assert: field string equals: 'x'.
]

{ #category : #tests }
SOMClassTest >> test04LookupOfFieldDefinedInSuperclass [

	| sourceSuper sourceSub
	  class method pushBc field |
	self loadClazzes: {#Object}.
	sourceSuper := 'ClassA = ( | aField | )'.
	sourceSub   := 'ClassB = ClassA ( m=(aField) )'.
	
	universe loadAndStoreFromSource: sourceSuper.
	class := universe loadAndStoreFromSource: sourceSub.
	
	method := class somInstanceInvokables at: 1.
	pushBc := method bytecodes first.
	self shouldnt: [field := class allInstanceFields at: pushBc fieldIndex] raise: Error.
	self assert: field string equals: 'aField'.

]

{ #category : #tests }
SOMClassTest >> test05ClassDoesNotRegisterInUniverseAfterCompiling [

	universe loadAndStoreFromSource: 'ClassA = ()'.
	self assert: (universe hasGlobalAt: #ClassA).
]

{ #category : #tests }
SOMClassTest >> test06ClassClassHasCorrectInstanceFields [

	| classClass |
	self loadClazzes: #(#Object #Class).
	classClass := universe globalAt: #Class.
	self
		assert: classClass allInstanceFields
		equals: #()
		"Note: in previous versions of SOM we did have the following fields:
		       'class' 'superClass' 'name' 'instanceFields' 'instanceInvokables'"

]

{ #category : #tests }
SOMClassTest >> test07MetaClassHasInstanceFields [

	| class field method pushFieldBc |
	self loadClazzes: #(#Object #Class).
	class := universe loadAndStoreFromSource: 'ClassA = (---- | x | m = (x))'.
	self assert: class somClass somInstanceFields size equals: 1.
	method := class somClass somInstanceInvokables at: 1.
	pushFieldBc := method bytecodes first.
	self shouldnt: [field := class fieldAtIndex: pushFieldBc fieldIndex] raise: Error.
	self assert: universe globalNil equals: field.
]
