Class {
	#name : #SOMFakeObjectTest,
	#superclass : #SOMObjectTest,
	#category : #'AweSOM-VM-Test'
}

{ #category : #'as yet unclassified' }
SOMFakeObjectTest class >> shouldInheritSelectors [
	^ false "reset to true in order to execute fake object tests"
]

{ #category : #running }
SOMFakeObjectTest >> setUp [

	"These should be set automatically when loading SOM classes"
	| objectClass instanceFields |
	super setUp.
	objectClass := universe globalAt: #Object.
	instanceFields := SOMArray inUniverse: universe size: 1.
	instanceFields at: 1 put: (universe newSymbol: 'class').
	objectClass instanceFields: instanceFields.
]
