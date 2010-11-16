Extension { #name : #SequenceableCollection }

{ #category : #'*AweSOM' }
SequenceableCollection >> zip: otherCollection [
	"Zips together (think of the zip on a pair of trousers) 2+ sequences, providing an array of tuples. Each tuple contains one value per original sequence. Tuples can be converted to something else by applying the optional iterator on them."

	| dictionary |
	dictionary := Dictionary new.
	self withIndexDo: [ :element :index |
		dictionary at: element put: (otherCollection at: index)
	].
	^ dictionary
]
