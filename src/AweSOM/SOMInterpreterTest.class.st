Class {
	#name : #SOMInterpreterTest,
	#superclass : #TestCaseWithUniverse,
	#instVars : [
		'interpreter'
	],
	#classInstVars : [
		'mgec',
		'callerFrame'
	],
	#category : #'AweSOM-VM-Test'
}

{ #category : #helper }
SOMInterpreterTest >> assembleMethod: name withArguments: args withByteCodes: byteCodeGenerator [ 
	^ self assembleMethod: name withArguments: args withLocals: {} withByteCodes: byteCodeGenerator
]

{ #category : #helper }
SOMInterpreterTest >> assembleMethod: name withArguments: args withLocals: locals withByteCodes: byteCodeGenerator [

	| testMgenc |
	testMgenc := universe methodGenClass named: name.
	byteCodeGenerator value: testMgenc.
	testMgenc arguments
		add: 'self';
		addAll: args.
	testMgenc locals addAll: locals.
	^ testMgenc assembleIn: universe.
]

{ #category : #helper }
SOMInterpreterTest >> assembleMethod: name withByteCodes: byteCodeGenerator [ 
	^ self assembleMethod: name withArguments: {} withLocals: {} withByteCodes: byteCodeGenerator
]

{ #category : #helper }
SOMInterpreterTest >> assembleMethod: name withLocals: locals withByteCodes: byteCodeGenerator [ 
	^ self assembleMethod: name withArguments: {} withLocals: locals withByteCodes: byteCodeGenerator
]

{ #category : #running }
SOMInterpreterTest >> compileMethod: source [ 

	| parser mgenc |
	parser := universe methodParser inUniverse: universe onSource: source from: 'test'.
	mgenc := parser apply: #method.
	^ mgenc assembleIn: universe.
]

{ #category : #running }
SOMInterpreterTest >> setUp [

	super setUp.
	interpreter := universe interpreter.
]

{ #category : #helper }
SOMInterpreterTest >> startInterpreterWith: method [ 
	self startInterpreterWith: method withLocals: {} withArguments: {}
]

{ #category : #helper }
SOMInterpreterTest >> startInterpreterWith: method withArguments: args [
	self startInterpreterWith: method withLocals: {} withArguments: args
]

{ #category : #helper }
SOMInterpreterTest >> startInterpreterWith: method withLocals: locals [
	self startInterpreterWith: method withLocals: locals withArguments: {}
]

{ #category : #helper }
SOMInterpreterTest >> startInterpreterWith: method withLocals: locals withArguments: args [
	| frame |
	frame := interpreter pushNewFrameWithMethod: method.
	locals withIndexDo: [:each :index | 
		frame localAtIndex: index contextLevel: 1 put: each].
	args withIndexDo: [:each :index | 
		frame argumentAtIndex: index contextLevel: 1 put: each].
	interpreter start.
]

{ #category : #tests }
SOMInterpreterTest >> test01Bootstrap [
	universe bootstrapWithArguments: {}
]

{ #category : #tests }
SOMInterpreterTest >> test02PushConstant [
	self startInterpreterWith: 
		(self assembleMethod: 'test' withByteCodes: [:mgenc | 
			mgenc 
				bcPushConstant: (universe newNumber: 42); 
				bcHalt
		]).
	
	self 
		assert: 42
		equals: interpreter somFrame pop number.
	self 
		should: [ interpreter somFrame pop ]
		raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test03Dup [
	"Duplicates the constant 42 on the stack and checks if there are exactly
	2 matching items on the stack"
	self startInterpreterWith: 
		(self assembleMethod: 'test' 
			withByteCodes: [:mgenc | 
				mgenc 
					bcPushConstant: (universe newNumber: 42); 
					bcDup;
					bcHalt
			]).
	
	self 
		assert: 42
		equals: interpreter somFrame pop number.
	self 
		assert: 42
		equals: interpreter somFrame pop number.
	self 
		should: [ interpreter somFrame pop ]
		raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test04PushGlobal [
	self startInterpreterWith: 
		(self assembleMethod: 'test' 
			withByteCodes: [:mgenc | 
				mgenc 
					bcPushGlobal: #nil;
					bcHalt
			]).
			
	self assert: universe globalNil = interpreter somFrame pop.
	self 
		should: [ interpreter somFrame pop ]
		raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test05PushLocal [
	self startInterpreterWith: 
		(self assembleMethod: 'test' 
			withLocals: {'a'. 'b'} 
			withByteCodes: [:mgenc | 
				mgenc 
					bcPushLocalIndex: 2 ctxIndex: 1;
					bcHalt
			])
		withLocals: {universe newNumber: 41. universe newNumber: 42}.
	
	self assert: 42 equals: interpreter somFrame pop number.
	self should: [interpreter somFrame pop] raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test06PushArguments [
	self startInterpreterWith: 
		(self assembleMethod: 'test' 
			withArguments: {'a'. 'b'} 
			withByteCodes: [:mgenc | 
				mgenc 
					bcPushArgumentIdx: 2 ctxIdx: 1;
					bcHalt
			])
		withArguments: {universe newNumber: 41. universe newNumber: 42}.
	
	self assert: 42 equals: interpreter somFrame pop number.
	self should: [interpreter somFrame pop] raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test07Pop [
	self startInterpreterWith: 
		(self assembleMethod: 'test' 
			withByteCodes: [:mgenc | 
				mgenc 
					bcPushConstant: (universe newNumber: 42); 
					bcDup;
					bcPop;
					bcHalt
			]).
	
	self assert: 42 equals: interpreter somFrame pop number.
	self should: [interpreter somFrame pop] raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test08PopLocal [
	"Pushes constant 42 to stack and pops it into local variable"
	self startInterpreterWith: 
		(self assembleMethod: 'test' 
			withLocals: {'a'. 'b'} 
			withByteCodes: [:mgenc | 
				mgenc 
					bcPushConstant: (universe newNumber: 42);
					bcPopLocalIndex: 2 ctxIndex: 1;
					bcHalt
			])
		withLocals: {universe newNumber: 41. nil}.
		
	self assert: 42 equals: (interpreter somFrame localAtIndex: 2 contextLevel: 1) number.
	self should: [interpreter somFrame pop] raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test09PopArgument [
	"Pushes constant 42 to stack and pops it into argument"
	self startInterpreterWith: 
		(self assembleMethod: 'test' 
			withArguments: {'a'. 'b'} 
			withByteCodes: [:mgenc | 
				mgenc 
					bcPushConstant: (universe newNumber: 42);
					bcPopArgumentIndex: 2 ctxIdx: 1;
					bcHalt
			])
		withArguments: {universe newNumber: 41. nil}.
	
	self assert: 42 equals: (interpreter somFrame argumentAtIndex: 2 contextLevel: 1) number.
	self should: [interpreter somFrame pop] raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test10ReturnLocal [

	| callerFrame calleeFrame method |
	method := self
		assembleMethod: 'main' 
		withByteCodes: [:mgenc | mgenc bcHalt].
	method maxStackDepth: 2.
	callerFrame := interpreter pushNewFrameWithMethod: method.
	callerFrame push: (universe newSymbol: #self).
	
	method := self compileMethod: 'subroutine = (^ 42)'.
	calleeFrame := interpreter pushNewFrameWithMethod: method.
	calleeFrame somPreviousFrame: callerFrame.

	
	interpreter start.
	
	self should: [calleeFrame pop] raise: Error.
	self assert: 42 equals: callerFrame pop number.
	self should: [callerFrame pop] raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test11Send [
	| testClazz testMethod testInstance |
	testClazz := universe classClass inUniverse: universe.
	testMethod := self 
		assembleMethod: 'testMessage:p2:'
		withArguments: {  'a'. 'b'  }
		withByteCodes: 
			[ :mgenc | 
			mgenc
				bcPushArgumentIdx: 2
					ctxIdx: 1;
				bcReturnLocal ].
	testClazz somInstanceInvokables: (SOMArray 
			inUniverse: universe
			withAll: {  testMethod  }).
	testClazz somInstanceFields: (SOMArray 
			inUniverse: universe
			withAll: {  (universe newSymbol: 'class')  }).
	testInstance := SOMObject 
		inUniverse: universe
		withSomClass: testClazz.
	self startInterpreterWith: (self 
			assembleMethod: 'main'
			withByteCodes: 
				[ :mgenc | 
				mgenc
					bcPushConstant: testInstance;
					bcPushConstant: #param1;
					bcPushConstant: #param2;
					bcSend: #testMessage:p2:;
					bcHalt ]).
	self 
		assert: #param1
		equals: interpreter somFrame pop.
	self 
		should: [ interpreter somFrame pop ]
		raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test12DNU [
	| testClazz testMethod testInstance params result |
	self loadClazzes: {  #Array. #Object  }.
	testClazz := universe classClass inUniverse: universe.
	params := SOMArray 
		inUniverse: universe
		size: 5.
	testMethod := self 
		assembleMethod: 'doesNotUnderstand:arguments:'
		withArguments: {  'message'. 'arguments'  }
		withByteCodes: 
			[ :mgenc | 
			1 
				to: 3
				do: 
					[ :paramIndex | 
					mgenc
						bcPushConstant: params;
						bcPushConstant: (universe newNumber: paramIndex);
						bcPushArgumentIdx: paramIndex
							ctxIdx: 1;
						bcSend: #at:put: ].
			mgenc bcReturnLocal ].
	testClazz somInstanceInvokables: (SOMArray 
			inUniverse: universe
			withAll: {  testMethod  }).
	testClazz somInstanceFields: (SOMArray 
			inUniverse: universe
			withAll: {  (universe newSymbol: 'class')  }).
	testInstance := SOMObject 
		inUniverse: universe
		withSomClass: testClazz.
	self startInterpreterWith: (self 
			assembleMethod: 'main'
			withByteCodes: 
				[ :mgenc | 
				mgenc
					bcPushConstant: testInstance;
					bcPushConstant: #param1;
					bcPushConstant: #param2;
					bcPushConstant: #param3;
					bcSend: #unknownMethod:p2:p3:;
					bcHalt ]).
	result := interpreter somFrame pop.
	self 
		should: [ interpreter somFrame pop ]
		raise: Error.
	self 
		assert: testInstance
		equals: (params at: 1).
	self 
		assert: #unknownMethod:p2:p3:
		equals: (params at: 2) symbol.
	self 
		assert: {  #param1. #param2. #param3  }
		equals: (params at: 3) elements
]

{ #category : #tests }
SOMInterpreterTest >> test13Block [
	| testMethod |
	self loadClazzes: {  #Object. #Block  }.
	testMethod := self 
		assembleMethod: 'testMessage:p2:'
		withArguments: {  'a'. 'b'  }
		withByteCodes: 
			[ :mgenc | 
			mgenc
				bcPushArgumentIdx: 2
					ctxIdx: 1;
				bcReturnLocal	"pushes the second REAL param" ].
	testMethod numberOfArguments: 2.	"no self"
	self startInterpreterWith: (self 
			assembleMethod: 'main'
			withByteCodes: 
				[ :mgenc | 
				mgenc
					bcPushBlock: testMethod;
					bcPushConstant: #param1;
					bcPushConstant: #param2;
					bcSend: #value:with:;
					bcHalt ]).
	self 
		assert: #param2
		equals: interpreter somFrame pop.
	self 
		should: [ interpreter somFrame pop ]
		raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test14ReturnNonLocal [

	| callerFrame calleeFrame method |
	method := self 
		assembleMethod: 'main'
		withByteCodes: [:mgenc | mgenc bcHalt].
	method maxStackDepth: 2.
	callerFrame := interpreter pushNewFrameWithMethod: method.
	callerFrame push: (universe newSymbol: #self).
	
	method := self compileMethod: 'subroutine = ([^42] value. ^24)'.
	calleeFrame := interpreter pushNewFrameWithMethod: method.
	calleeFrame somPreviousFrame: callerFrame.
	
	interpreter start.
	self 
		assert: 42
		equals: callerFrame pop number.
	self 
		should: [callerFrame pop]
		raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test15SuperSend [
	| testClazz testMethod superClazz superMethod testInstance |
	superClazz := universe classClass inUniverse: universe.
	superMethod := self 
		assembleMethod: 'test'
		withByteCodes: 
			[ :mgenc | 
			mgenc
				bcPushConstant: (universe newNumber: 42);
				bcReturnLocal ].
	superMethod somHolder: superClazz.
	superClazz somInstanceInvokables: (SOMArray 
			inUniverse: universe
			withAll: {  superMethod  }).
	superClazz somInstanceFields: (SOMArray 
			inUniverse: universe
			withAll: {  (universe newSymbol: 'class')  }).
	testClazz := universe classClass 
		inUniverse: universe
		withSomSuperClass: superClazz.
	testMethod := self 
		assembleMethod: 'test'
		withByteCodes: 
			[ :mgenc | 
			mgenc
				bcPushArgumentIdx: 1
					ctxIdx: 1;
				bcSuperSend: 'test';
				bcReturnLocal ].
	testMethod somHolder: testClazz.
	testClazz somInstanceInvokables: (SOMArray 
			inUniverse: universe
			withAll: {  testMethod  }).
	testClazz somInstanceFields: (SOMArray 
			inUniverse: universe
			withAll: {  (universe newString: 'class')  }).
	testInstance := SOMObject 
		inUniverse: universe
		withSomClass: testClazz.
	self startInterpreterWith: (self 
			assembleMethod: 'main'
			withByteCodes: 
				[ :mgenc | 
				mgenc
					bcPushConstant: testInstance;
					bcSend: #test;
					bcHalt ]).
	self 
		assert: 42
		equals: interpreter somFrame pop number.
	self 
		should: [ interpreter somFrame pop ]
		raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test16PushField [
	| testClazz testMethod testInstance testFieldName |
	testFieldName := universe newSymbol: 'testField'.
	testClazz := universe classClass inUniverse: universe.
	testMethod := self 
		assembleMethod: 'testMessage'
		withByteCodes: 
			[ :mgenc | 
			mgenc
				bcPushField: testFieldName string;
				bcReturnLocal ].
	testClazz somInstanceInvokables: (SOMArray 
			inUniverse: universe
			withAll: {  testMethod  }).
	testClazz somInstanceFields: (SOMArray 
			inUniverse: universe
			withAll: {  (universe newString: 'class'). testFieldName  }).
	testInstance := SOMObject 
		inUniverse: universe
		withSomClass: testClazz.
	testInstance 
		valueInField: testFieldName
		put: (universe newNumber: 42).
	self startInterpreterWith: (self 
			assembleMethod: 'main'
			withByteCodes: 
				[ :mgenc | 
				mgenc
					bcPushConstant: testInstance;
					bcSend: #testMessage;
					bcHalt ]).
	self 
		assert: 42
		equals: interpreter somFrame pop number.
	self 
		should: [ interpreter somFrame pop ]
		raise: Error
]

{ #category : #tests }
SOMInterpreterTest >> test17PopField [
	| testClazz testMethod testInstance testFieldName |
	testFieldName := universe newSymbol: 'testField'.
	testClazz := universe classClass inUniverse: universe.
	testMethod := self 
		assembleMethod: 'testMessage'
		withByteCodes: 
			[ :mgenc | 
			mgenc
				bcPushConstant: (universe newNumber: 42);
				bcPopField: testFieldName string;
				bcPushArgumentIdx: 1
					ctxIdx: 1;
				bcReturnLocal ].
	testClazz somInstanceInvokables: (SOMArray 
			inUniverse: universe
			withAll: {  testMethod  }).
	testClazz somInstanceFields: (SOMArray 
			inUniverse: universe
			withAll: {  (universe newString: 'class'). testFieldName  }).
	testInstance := SOMObject 
		inUniverse: universe
		withSomClass: testClazz.
	self startInterpreterWith: (self 
			assembleMethod: 'main'
			withByteCodes: 
				[ :mgenc | 
				mgenc
					bcPushConstant: testInstance;
					bcSend: #testMessage;
					bcHalt ]).
	self 
		assert: 42
		equals: (testInstance valueInField: testFieldName) number.
	self 
		assert: testInstance
		equals: interpreter somFrame pop.
	self 
		should: [ interpreter somFrame pop ]
		raise: Error
]
