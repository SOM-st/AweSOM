Extension { #name : #SortedCollection }

{ #category : #'*AweSOM-Squeak-compatibility' }
SortedCollection >> should: a precede: b [

	^ sortBlock ifNil: [a <= b] ifNotNil: [sortBlock value: a value: b]
]

{ #category : #'*AweSOM-Squeak-compatibility' }
SortedCollection >> sortTopologically [
	"Plenty of room for increased efficiency in this one."

	| remaining result pick |
	remaining := self asOrderedCollection.
	result := OrderedCollection new.
	[remaining isEmpty] whileFalse: [
		pick := remaining select: [:item |
			remaining allSatisfy: [:anotherItem |
				item == anotherItem or: [self should: item precede: anotherItem]]].
		pick isEmpty ifTrue: [self error: 'bad topological ordering'].
		result addAll: pick.
		remaining removeAll: pick].
	^self copySameFrom: result
]
