Class {
	#name : #SOMArray,
	#superclass : #SOMObject,
	#category : #'AweSOM-CoreObjects'
}

{ #category : #'as yet unclassified' }
SOMArray class >> inUniverse: universe size: size [

	^ self
		inUniverse: universe
		withNumberOfAdditionalFields: 0
		withNumberOfIndexableFields: size
]

{ #category : #'as yet unclassified' }
SOMArray class >> inUniverse: universe withAll: squeakColl [

	| result |
	result := self inUniverse: universe size: squeakColl size.
	squeakColl withIndexDo: [:each :i | result at: i put: each].
	^ result
]

{ #category : #primitives }
SOMArray class >> primnew: size inSomClass: somClass [
	^ self 
		inUniverse: somClass universe
		size: size number
]

{ #category : #adding }
SOMArray >> add: item [
	
	self resize: self size + 1.
	self at: self size put: item
]

{ #category : #accessing }
SOMArray >> at: index [
	^ self indexableFields at: index
]

{ #category : #accessing }
SOMArray >> at: index put: object [
	^ self indexableFields at: index put: object
]

{ #category : #copying }
SOMArray >> copyFrom: fromIndex to: toIndex [

	^ self indexableFields copyFrom: fromIndex to: toIndex
]

{ #category : #enumerating }
SOMArray >> do: block [

	self indexableFields do: block
]

{ #category : #accessing }
SOMArray >> elements [
	^ self indexableFields
]

{ #category : #accessing }
SOMArray >> indexOf: element [ 
	^ self indexableFields indexOf: element
]

{ #category : #primitives }
SOMArray >> primat: index [

	^ self at: index number.
]

{ #category : #primitives }
SOMArray >> primat: index put: object [

	^ self at: index number put: object.
]

{ #category : #primitives }
SOMArray >> primlength [

	^ universe newNumber: self size
]

{ #category : #printing }
SOMArray >> printOn: stream [

	stream nextPutAll: 'SOMArray'.
	self elements printAsSelfEvaluatingFormOn: stream.
]

{ #category : #resizing }
SOMArray >> resize: newSize [
	newSize < self size
		ifTrue: [self indexableFields: (self indexableFields copyFrom: 1 to: newSize)]
		ifFalse: [self indexableFields: (self indexableFields, (Array new: newSize - self size))]
]

{ #category : #accessing }
SOMArray >> size [
	^ self indexableFields size
]

{ #category : #accessing }
SOMArray >> wipeIndexableFields [
	1 to: self elements size do: [ :i | self at: i put: universe globalNil ]
]

{ #category : #enumerating }
SOMArray >> withIndexDo: block [
	indexableFields withIndexDo: block
]
