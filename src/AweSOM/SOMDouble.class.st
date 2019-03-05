Class {
	#name : #SOMDouble,
	#superclass : #SOMNumber,
	#category : #'AweSOM-CoreObjects'
}

{ #category : #primitives }
SOMDouble >> primasInteger [
	^ universe newNumber: self number asInteger
]

{ #category : #primitives }
SOMDouble >> primcos [
	^ universe newNumber: self number cos
]

{ #category : #primitives }
SOMDouble >> primround [
	^ universe newNumber: (self number round: 0)
]

{ #category : #primitives }
SOMDouble >> primsin [
	^ universe newNumber: self number sin
]

{ #category : #accessing }
SOMDouble >> setDefaultClass [
	somClass := universe globalDoubleClass
]
