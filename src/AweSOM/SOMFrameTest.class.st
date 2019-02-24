Class {
	#name : #SOMFrameTest,
	#superclass : #TestCaseWithUniverse,
	#instVars : [
		'frame',
		'frame2'
	],
	#category : #'AweSOM-VM-Test'
}

{ #category : #running }
SOMFrameTest >> setUp [

	super setUp.
	frame := (SOMFrame 
		inUniverse: universe
		size: 10)
		somMethod: (SOMMethod 
				inUniverse: universe
				withNumberOfAdditionalFields: 0);
		yourself.
	frame2 := (SOMFrame 
		inUniverse: universe
		size: 10)
		somMethod: (SOMMethod 
				inUniverse: universe
				withNumberOfAdditionalFields: 0);
		yourself
]

{ #category : #tests }
SOMFrameTest >> test01Push [
	self assert: frame stackPointer equals: 0.
	frame push: 'A'.
	self assert: frame stackPointer equals: 1
]

{ #category : #tests }
SOMFrameTest >> test02Pop [
	frame push: 'A'.
	self assert: 'A' equals: (frame pop).
	
	frame push: 'A'.
	frame push: 'B'.
	self assert: 'B' equals: (frame pop);
		assert: 'A' equals: (frame pop).
]

{ #category : #tests }
SOMFrameTest >> test03Context [
	self 
		assert: universe globalNil
		equals: frame somContext.
	self assert: frame = (frame frameAtContextLevel: 1).
	self 
		assert: frame somContext
		equals: (frame frameAtContextLevel: 2).
	frame2 somContext: frame.
	self 
		assert: frame
		equals: frame2 somContext.
	self 
		assert: frame2
		equals: (frame2 frameAtContextLevel: 1).
	self 
		assert: frame2 somContext
		equals: (frame2 frameAtContextLevel: 2).
	self 
		assert: frame2 somContext somContext
		equals: (frame2 frameAtContextLevel: 3)
]

{ #category : #tests }
SOMFrameTest >> test04StackSize [
	self assert: 10 equals: frame remainingStackSize.
	
	9 to: 0 by: -1 do: [ :expectedRemainingSize |
		frame push: 'A'.
		self assert: expectedRemainingSize equals: frame remainingStackSize.
	].
]

{ #category : #tests }
SOMFrameTest >> test05CallPrimitive [
	| theSelf theOther method |
	theSelf := SOMInteger 
		inUniverse: universe
		new: 50.
	theOther := SOMInteger 
		inUniverse: universe
		new: 8.
	frame
		push: theSelf;
		push: theOther.
	method := SOMPrimitive inUniverse: universe.
	method
		numberOfArguments: 2;
		somSignature: (SOMSymbol 
				inUniverse: universe
				string: '-');
		invokeInFrame: frame.
	self 
		assert: frame pop number
		equals: 42
]
