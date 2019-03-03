Class {
	#name : #SOMDouble,
	#superclass : #SOMNumber,
	#category : #'AweSOM-CoreObjects'
}

{ #category : #accessing }
SOMDouble >> setDefaultClass [
	somClass := universe globalDoubleClass
]
