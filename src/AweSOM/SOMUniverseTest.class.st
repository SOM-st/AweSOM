Class {
	#name : #SOMUniverseTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-VM-Test'
}

{ #category : #tests }
SOMUniverseTest >> test01GlobalAccess [
	self assert: universe globalNil equals: (universe globalAt: #nil).
]
