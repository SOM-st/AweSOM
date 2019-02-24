Class {
	#name : #SOMBytecode,
	#superclass : #Object,
	#instVars : [
		'mgenc'
	],
	#classVars : [
		'InstructionSelectorDict'
	],
	#classInstVars : [
		'instructionName'
	],
	#category : #'AweSOM-Interpreter'
}

{ #category : #'instance creation' }
SOMBytecode class >> in: methodGenerationContext [

	^ self new
		mgenc: methodGenerationContext;
		yourself.
]

{ #category : #constant }
SOMBytecode class >> instructionSelectorDict [

	^ InstructionSelectorDict ifNil: [
		InstructionSelectorDict := Dictionary new
			at: SOMBCReturnNonLocal put: #doReturnNonLocal;
			at: SOMBCDup put: #doDup;
			at: SOMBCPop put: #doPop;
			at: SOMBCHalt put: #doHalt;
			at: SOMBCPushField put: #doPushField;
			at: SOMBCPopLocal put: #doPopLocal;
			at: SOMBCSuperSend put: #doSuperSend;
			at: SOMBCPushArgument put: #doPushArgument;
			at: SOMBCPushGlobal put: #doPushGlobal;
			at: SOMBCSend put: #doSend;
			at: SOMBCStep put: #doStep;
			at: SOMBCPushBlock put: #doPushBlock;
			at: SOMBCPopArgument put: #doPopArgument;
			at: SOMBCReturnLocal put: #doReturnLocal;
			at: SOMBCPushConstant put: #doPushConstant;
			at: SOMBCPushLocal put: #doPushLocal;
			at: SOMBCPopField put: #doPopField;
			yourself]
]

{ #category : #accessing }
SOMBytecode >> isPushBlock [
	^ false
]

{ #category : #constant }
SOMBytecode >> length [

	^ 1
]

{ #category : #accessing }
SOMBytecode >> mgenc [
	^ mgenc
]

{ #category : #accessing }
SOMBytecode >> mgenc: anObject [
	mgenc := anObject
]

{ #category : #printing }
SOMBytecode >> printName [

	"'SOMBC' size = 6, SOMBCDup --> DUP"
	| name |
	name := self class name.
	^ (name copyFrom: 6 to: name size) asUppercase
]

{ #category : #printing }
SOMBytecode >> printOn: stream [

	stream
		nextPut: $<;
		nextPutAll: self printName;
		nextPut: $>.
]

{ #category : #accessing }
SOMBytecode >> stackDepth [

	^ 0
]
