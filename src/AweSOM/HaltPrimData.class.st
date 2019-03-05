Class {
	#name : #HaltPrimData,
	#superclass : #Object,
	#classInstVars : [
		'doBreak'
	],
	#category : #'AweSOM-VM'
}

{ #category : #initialization }
HaltPrimData class >> break [
	^ doBreak
]

{ #category : #initialization }
HaltPrimData class >> resetBreak [
	" HaltPrimData resetBreak "
	doBreak := false.
]

{ #category : #initialization }
HaltPrimData class >> setBreak [
	doBreak := true
]
