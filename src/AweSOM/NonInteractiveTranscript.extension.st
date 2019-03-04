Extension { #name : #NonInteractiveTranscript }

{ #category : #'*AweSOM' }
NonInteractiveTranscript >> lf [
	"Output a cr on the receiver, buffered and not yet shown"
	
	self newLine
]
