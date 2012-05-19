Class {
	#name : #SOMInterpreter,
	#superclass : #Object,
	#instVars : [
		'frame',
		'universe',
		'currentBytecode',
		'stoppedFrame',
		'stopped'
	],
	#category : #'AweSOM-Interpreter'
}

{ #category : #'instance creation' }
SOMInterpreter class >> inUniverse: universe [

	^ self new
		universe: universe;
		yourself.
]

{ #category : #accessing }
SOMInterpreter >> currentBytecode [

	^ currentBytecode
]

{ #category : #accessing }
SOMInterpreter >> currentBytecode: anObject [ 

	currentBytecode := anObject
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doDup [
	"duplicate the topmost element of the stack"
	
	self somFrame 
		push: (self somFrame stackElementAtIndex: 1)
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doHalt [

	stopped := true
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPop [
	"pops the topmost element of the stack"
	
	self somFrame pop
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPopArgument [
	"pops the topmost stack element into the argument which is identified by the slot index and context level in the bytecode"
	
	self somFrame 
		argumentAtIndex: (self currentBytecode index)
		contextLevel: (self currentBytecode contextIndex)
		put: (self somFrame pop)
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPopField [
	"pops the topmost stack element into the field which is identified by field index in the bytecode"
	
	self somCurrentObject
		fieldAtIndex: (self currentBytecode fieldIndex)
		put: self somFrame pop
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPopLocal [
	| localSlot contextLevel |
	localSlot := self currentBytecode index.
	contextLevel := self currentBytecode contextIndex.
	self somFrame 
			localAtIndex: localSlot
			contextLevel: contextLevel
			put: (self somFrame pop)
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPushArgument [
	"pushes the argument onto the stack which is identified by the slot index and context level in the next two bytes of the bytecode"
	| slot contextLevel |
	slot := self currentBytecode index.
	contextLevel := self currentBytecode contextIndex.
	self somFrame push: (self somFrame 
			argumentAtIndex: slot
			contextLevel: contextLevel)
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPushBlock [
	| blockMethod block |
	blockMethod := self currentBytecode literalValue.
	block := (SOMBlock inUniverse: self universe)
		somClass: (self universe globalAt: #Block);
		somBlockMethod: blockMethod;
		somContext: self somFrame.
	self somFrame push: block
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPushConstant [
	self somFrame push: (self currentBytecode literalValue)
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPushField [

	self somFrame push:
		(self somCurrentObject fieldAtIndex: 
			(self currentBytecode fieldIndex)).
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPushGlobal [

	| global |
	global := 
		self universe 
			globalAt: (self currentBytecode literalValue)
			ifAbsent: [
				self sendUnknownGlobal: 
					self currentBytecode literalValue.
				^ self].
	self somFrame push: global
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doPushLocal [
	| localSlot contextLevel |
	localSlot := self currentBytecode index.
	contextLevel := self currentBytecode contextIndex.
	self somFrame push: (self somFrame 
			localAtIndex: localSlot
			contextLevel: contextLevel)
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doReturnLocal [
	"pops the topmost element of the stack and treats it as the return value"
	self popFrameAndPushResult: self somFrame pop
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doReturnNonLocal [
	"pops the topmost element of the stack and treats it as the return value"
	| result context |
	result := self somFrame pop.
	context := self somFrame outerContext.
	
	self flag: #arv.
	"implement escaped block case"
	
	[self somFrame ~= context] whileTrue: [self popFrame].
	self popFrameAndPushResult: result
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doSend [

	| methodName receiver |
	methodName := self currentBytecode selector.
	receiver := self somFrame stackElementAtIndex: methodName numArgs + 1.
	^ self 
		send: methodName
		toClazz: receiver somClass
]

{ #category : #debugging }
SOMInterpreter >> doStep [

	| bytecodeIndex originalBytecode |
	(self currentBytecode owningFrames includes: self somFrame)
		ifFalse: [
			"if we are not in the right frame; execute the normal bytecode"
			^ self perform: (self instructionSelectors at: 
				self currentBytecode originalBytecode class)].
			
	"uninstall step bytecode if necessary and reinstall original bytecode"
	originalBytecode := self currentBytecode originalBytecode.
	self currentBytecode owningFrames remove: self somFrame.
	self currentBytecode owningFrames ifEmpty: [ 
		bytecodeIndex := self somFrame bytecodeIndex.
		self somMethod bytecodeAt: bytecodeIndex - 1 put: originalBytecode].
	
	"display inspection view again"
	self showInspection.
	
	"execute the normal bytecode"
	self currentBytecode: originalBytecode.
	self perform: (self instructionSelectors at: 
		self currentBytecode class)
	
]

{ #category : #'bytecode processing' }
SOMInterpreter >> doSuperSend [
	| methodName superClazz |
	methodName := self currentBytecode selector.
	superClazz := self somFrame outerContext somMethod somHolder somSuperClass.
	self 
		send: methodName
		toClazz: superClazz
]

{ #category : #accessing }
SOMInterpreter >> instructionSelectors [
	^ SOMBytecode instructionSelectorDict 
]

{ #category : #'frame manipulation' }
SOMInterpreter >> popFrame [
	| currentFrame |
	currentFrame := self somFrame.
	self somFrame: currentFrame somPreviousFrame.
	^ currentFrame
		clearPreviousFrame;
		yourself
]

{ #category : #'frame manipulation' }
SOMInterpreter >> popFrameAndPushResult: result [ 

	| poppedMethod |
	poppedMethod := self somFrame somMethod.
	self popFrame.
	self somFrame removeN: poppedMethod numberOfArguments.
	self somFrame push: result
]

{ #category : #printing }
SOMInterpreter >> printBytecodes [
	
	self printBytecodesOn: Transcript.
	Transcript endEntry
]

{ #category : #printing }
SOMInterpreter >> printBytecodesOn: stream [
	| currentFrame |
	
	currentFrame := frame.
	[currentFrame = universe globalNil] whileFalse: 
		[
			currentFrame printBytecodesOn: stream.
			currentFrame := currentFrame somPreviousFrame
		]
]

{ #category : #printing }
SOMInterpreter >> printFullStacks [
	
	self printFullStacksOn: Transcript.
	Transcript endEntry
]

{ #category : #printing }
SOMInterpreter >> printFullStacksOn: stream [
	| currentFrame |
	
	currentFrame := stoppedFrame ifNotNil: [stoppedFrame] ifNil: [frame].
	[currentFrame = universe globalNil] 
		whileFalse: [
			currentFrame printStackOn: stream.
			currentFrame := currentFrame somPreviousFrame
		]
]

{ #category : #printing }
SOMInterpreter >> printStack [
	
	self printStackOn: Transcript.
	Transcript endEntry
]

{ #category : #printing }
SOMInterpreter >> printStackOn: stream [
	| currentFrame |
	
	currentFrame := self somFrame.
	[currentFrame = universe globalNil] 
		whileFalse: [
			stream nextPutAll: currentFrame somMethod asString.
			
			currentFrame somCurrentObject ~= self universe globalNil
				ifTrue: [stream nextPutAll: ' in '; nextPutAll: currentFrame somCurrentObject somClass asString].
				
			currentFrame arguments ~= self universe globalNil
				ifTrue: [stream nextPutAll: ' ('; nextPutAll: currentFrame arguments asString; nextPutAll: ') '].
				
			stream cr.
			currentFrame := currentFrame somPreviousFrame.
		]
]

{ #category : #'frame manipulation' }
SOMInterpreter >> pushNewFrameWithMethod: method [ 

	"creates a new frame encapsulating the given method
	and sets the needed length of its stack"
	| frameLength |
	frameLength := method numberOfArguments
		+ method numberOfLocals
		+ method maxStackDepth.
	^ frame := (universe frameClass 
		inUniverse: self universe
		size: frameLength)
		somMethod: method;
		somPreviousFrame: (frame ifNil: [universe globalNil]);
		resetStackPointer;
		bytecodeIndex: 1;
		yourself
]

{ #category : #'message dispatch' }
SOMInterpreter >> send: signature toClazz: clazz [
	"sends the method to the given class or invokes do not understand"
	(clazz lookupInvokable: signature) 
		ifNotNilDo: [:invokable | invokable invokeInFrame: self somFrame]
		ifNil: [self sendDoesNotUnderstand: signature]
]

{ #category : #'message dispatch' }
SOMInterpreter >> sendDoesNotUnderstand: signature [
	| arguments receiver |
	"for debugging: in test suite DNU shouldn't be used"
	"self halt."
	
	"assemble and send DO NOT UNDERSTAND"
	arguments := SOMArray inUniverse: universe 
		withAll: (self somFrame popN: signature numArgs).
	"remove receiver from stack"
	receiver := self somFrame pop.
	
	"check if current frame is big enough for this unplanned Send"
	"doesNotUnderstand: needs 3 slots, one for this, one for method name, one for args"
	self somFrame remainingStackSize < 3
		ifTrue: [self somFrame resize: (self somFrame size + 3)].
		
	receiver 
		sendMessage: #doesNotUnderstand:arguments:
		withArguments: 
			(SOMArray inUniverse: universe withAll: 
				{universe newSymbol: signature. arguments})	
]

{ #category : #'as yet unclassified' }
SOMInterpreter >> sendUnknownGlobal: globalName [ 

	"check if current frame is big enough for this unplanned Send"
	"unknownGlobal: needs 2 slots, one for this and one for globalName"
	self somFrame remainingStackSize < 2
		ifTrue: [self somFrame resize: (self somFrame size + 2)].
		
	self somCurrentObject 
		sendMessage: #unknownGlobal:
		withArguments: 
			(SOMArray inUniverse: universe withAll: 
				{universe newSymbol: globalName})
]

{ #category : #debugging }
SOMInterpreter >> showInspection [

	| stackTrace bytecodes fullStackTrace stackContents stackPointer topElement realBytecode |
	stackTrace := String streamContents: [:s | self printStackOn: s].	
	stackContents := String streamContents: [:s | self somFrame printStackOn: s].
	realBytecode := self somMethod bytecodeAt: (self somFrame bytecodeIndex - 1).
	bytecodes := String streamContents: [:s | self somFrame printBytecodesOn: s].
	
	stackPointer := self somFrame stackPointer.
	topElement := self somFrame at: stackPointer.
	
	fullStackTrace := String streamContents: [:s | self printFullStacksOn: s].
	
	"inspect local variables or use following commands:"
	"self step"
	"self stepBytecode"
	
	"self halt."
	
	"locals are used by programmers to debug SOM"
	"however for Squeak they are unused"
	"the following lines avoid the annoying unused message of Squeak"
	{stackTrace. bytecodes. fullStackTrace. stackContents. stackPointer. topElement. realBytecode} size.
]

{ #category : #accessing }
SOMInterpreter >> somCurrentObject [
	^ (self somFrame outerContext) somCurrentObject
]

{ #category : #accessing }
SOMInterpreter >> somFrame [
	^ frame
]

{ #category : #accessing }
SOMInterpreter >> somFrame: anFrame [ 
	frame := anFrame
]

{ #category : #accessing }
SOMInterpreter >> somMethod [
	^ self somFrame somMethod
]

{ #category : #initialization }
SOMInterpreter >> start [

	stopped := false.
	[stopped] whileFalse: [| bytecode bytecodeIndex |
		bytecodeIndex := self somFrame bytecodeIndex.
		bytecode := self somMethod bytecodeAt: bytecodeIndex.
		self currentBytecode: bytecode.
		"increase bytecode index here because frame might change
		while dispatching current bytecode"
		self somFrame bytecodeIndex: bytecodeIndex + 1.
		self perform: (self instructionSelectors at: bytecode class).
	]
]

{ #category : #debugging }
SOMInterpreter >> step [

	self somFrame installStep
]

{ #category : #debugging }
SOMInterpreter >> stepBytecode [

	self somFrame installStepBytecode
]

{ #category : #initialization }
SOMInterpreter >> stop [
	"rolls back to the first frame which contains the halt command; saves current frame for debug purposes"
	
	| |
	self halt.
	stopped := true
]

{ #category : #accessing }
SOMInterpreter >> universe [
	^ universe
]

{ #category : #accessing }
SOMInterpreter >> universe: anObject [
	universe := anObject
]
