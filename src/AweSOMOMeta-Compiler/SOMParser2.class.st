Class {
	#name : #SOMParser2,
	#superclass : #OMeta2,
	#instVars : [
		'startInput',
		'universe',
		'cgenc',
		'shouldReadSources'
	],
	#category : #'AweSOMOMeta-Compiler'
}

{ #category : #'instance creation' }
SOMParser2 class >> inUniverse: universe onSource: string [

	^ (self matcherOn: string readStream)
		universe: universe;
		yourself.
]

{ #category : #'instance creation' }
SOMParser2 class >> matcherOn: aReadStream [

	| result |
	result := super matcherOn: aReadStream.
	result startInput: (OM2LazyStream for: aReadStream copy withPos: 1).
	^ result
]

{ #category : #accessing }
SOMParser2 >> cgenc [
	^ cgenc
]

{ #category : #accessing }
SOMParser2 >> cgenc: anObject [
	cgenc := anObject
]

{ #category : #helper }
SOMParser2 >> comment [ =

	$" (char:x ?[x ~= $"])* $"
]

{ #category : #helper }
SOMParser2 >> identifier [ =

	<letter:x (letter | digit | $_)*>
]

{ #category : #initialization }
SOMParser2 >> initialize [

	super initialize.
	shouldReadSources := false.
]

{ #category : #helper }
SOMParser2 >> log [ :msg =

	[Transcript cr; show: msg]
]

{ #category : #helper }
SOMParser2 >> logAndFail [ :msg =

	log(msg) -> [OMeta2Fail signal]
]

{ #category : #helper }
SOMParser2 >> logPosition [

	Transcript cr; show: self printPos.
]

{ #category : #accessing }
SOMParser2 >> methodParser [

	^ SOMMethodParser2 new
		initInput: input;
		universe: self universe;
		shouldReadSources: self shouldReadSources;
		yourself
]

{ #category : #helper }
SOMParser2 >> printPos [

	| maxChars before after string pos |
	maxChars := 20.
	string := input stream contents.
	pos := input pos.
	before := string first: pos.
	before size > maxChars ifTrue: [before := before last: maxChars].
	after := string copyFrom: pos to: string size.
	after size > maxChars ifTrue: [after := after first: maxChars].
	^ before , '<--here-->' , after.
]

{ #category : #accessing }
SOMParser2 >> shouldReadSources [
	^ shouldReadSources
]

{ #category : #accessing }
SOMParser2 >> shouldReadSources: anObject [
	shouldReadSources := anObject
]

{ #category : #helper }
SOMParser2 >> spaces [ =

	(space | comment)*
]

{ #category : #accessing }
SOMParser2 >> startInput [
	^ startInput
]

{ #category : #accessing }
SOMParser2 >> startInput: anObject [
	startInput := anObject
]

{ #category : #accessing }
SOMParser2 >> universe [
	^ universe
]

{ #category : #accessing }
SOMParser2 >> universe: anObject [
	universe := anObject
]
