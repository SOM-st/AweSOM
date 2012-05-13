Class {
	#name : #CompileSOMClassTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-Compiler-Test'
}

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> assertSuperClassOf: className is: superClassName [

	self
		assert: (universe globalAt: superClassName)
		equals: (universe globalAt: className) somSuperClass.
]

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> compileSource: source [
	
	^ universe loadAndStoreFromSource: source
]

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> createCgencFromSource: source [
	
	| parser |
	parser := SOMClassParser inUniverse: universe onSource: source.
	parser start.
	^ parser cgenc.
]

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> test01SimpleClassCreation [

	| cgenc clazz |
	cgenc := SOMClassGenerationContext new.
	cgenc theName: 'Robert'.
	cgenc instanceFields: {  'alter'. 'adresse'  }.
	clazz := cgenc assembleIn: universe.
	self assert: (clazz isKindOf: SOMClass).
	self assert: clazz somName symbol equals: #Robert.
	self assert: clazz somClass somName symbol equals: #'Robert class'.
	self assert: clazz somSuperClass equals: (universe globalAt: #Object).
	self assert: clazz somInstanceFields size equals: 2.
	self assert: (clazz somInstanceFields at: 1) string equals: 'alter'
]

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> test02CompileClass [
	| cgenc clazz |
	cgenc := SOMClassGenerationContext new.
	cgenc classFields: {  'alter'  }.
	clazz := cgenc assembleIn: universe.
	self 
		assert: (clazz somClass somInstanceFields at: 1) string
		equals: 'alter'
]

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> test03CompileClassWithMethod [
	| cgenc clazz |
	cgenc := self createCgencFromSource: 'Bla = Array (method1 = (^ 42) method2 = primitive ---- classMethod = ())'.
	clazz := cgenc assembleIn: universe.
	self 
		assert: clazz somInstanceInvokables size
		equals: 2.
	self assert: ((clazz somInstanceInvokables at: 1) isKindOf: SOMMethod).
	self assert: ((clazz somInstanceInvokables at: 2) isKindOf: SOMPrimitive).
	self 
		assert: clazz somClass somInstanceInvokables size
		equals: 1
]

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> test04CompileClassWithSuperclass [
	| cgenc clazz |
	cgenc := self createCgencFromSource: 'Bla = Array (method1 = (^ 42) method2 = primitive)'.
	clazz := cgenc assembleIn: universe.
	self 
		assert: clazz somSuperClass
		equals: (universe globalAt: #Array)
	"self assert: clazz superClazz theName symbol equals: #Array."
]

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> test05UnsharedFieldInMethodSubClass [
	| cgenc somClass instance privateInstVarNames |
	
	"Instance fields declared in SOM might not map properly to the field 'fields', if on the VM-side instance fields are added to subclasses of SOMObject that are not supposed to be visible from SOM, e.g. Method's field 'bytecodes'."
	
	self loadClazzes: {  #Object. #Method  }.
	cgenc := self createCgencFromSource: 
	  'MethodSubClass = Method(	| thisMightCollideWithBytecodes |
	   setField = (thisMightCollideWithBytecodes := 42.))'.
	somClass := cgenc assembleIn: universe.
	instance := somClass primnew.
	universe 
		bootstrapWithEntryPoint: (somClass somInstanceInvokables at: 1)
		withArguments: instance.
	privateInstVarNames := instance class instVarNames select: [ :each | (each beginsWith: 'som') not ].
	privateInstVarNames do: 
		[ :each | 
		self 
			assert: ((universe newNumber: 42) primEqual: (instance instVarNamed: each))
			equals: (universe globalAt: #false) ]
]

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> test06AssembleNormalClass [

	| class |
	class := self compileSource: 'Test = (| a b| m1=(1+2))'.
	self assert: class somInstanceFields elements second string equals: 'b'.
	self assert: class somInstanceInvokables size equals: 1.
]

{ #category : #'as yet unclassified' }
CompileSOMClassTest >> xtest07InternalClassHierarchyEqualsSomClassHierarchy [

	"This test is currently deactivated. It tests if the class
	hierarchy of system classes is the same as in SOM. Currently
	it isn't but there could be problems in the future because of this'"
	universe := SOMUniverse new.
	universe initializeRealGlobals.
	"self assertSuperClassOf: #Object is: #nil."
	self assertSuperClassOf: #Class is: #Object.
	self assertSuperClassOf: #Metaclass is: #Class.
	self assertSuperClassOf: #Nil is: #Object.
	self assertSuperClassOf: #Array is: #Object.
	self assertSuperClassOf: #Method is: #Array.
	self assertSuperClassOf: #Symbol is: #Object.
	self assertSuperClassOf: #Integer is: #Object.
	self assertSuperClassOf: #BigInteger is: #Object.
	self assertSuperClassOf: #Frame is: #Array.
	self assertSuperClassOf: #Primitive is: #Object.
	self assertSuperClassOf: #String is: #Object.
	self assertSuperClassOf: #Double is: #Object.
]
