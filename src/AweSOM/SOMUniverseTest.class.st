Class {
	#name : #SOMUniverseTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-VM-Test'
}

{ #category : #tests }
SOMUniverseTest >> test01GlobalAccess [
	self assert: universe globalNil equals: (universe globalAt: #nil).
]

{ #category : #tests }
SOMUniverseTest >> testHandleArguments [
	| args |
	args := universe handleArguments: { 'Test.som'. '1'. '2'. '3' }.
	self assert: args equals: { 'Test'. '1'. '2'. '3' }.
]
