"
I am starting the execution of AweSOM and pass command-line arguments to the standard SOM execution.
"
Class {
	#name : #SOMCommandLineHandler,
	#superclass : #CommandLineHandler,
	#category : #'AweSOM-VM'
}

{ #category : #accessing }
SOMCommandLineHandler class >> commandName [
	^ 'som'

]

{ #category : #accessing }
SOMCommandLineHandler class >> description [
	^ 'Starts SOM execution'

]

{ #category : #activation }
SOMCommandLineHandler >> activate [
	| universe |
	universe := SOMUniverse new.
	universe outStream: self stdout.
	
	self arguments isEmpty ifTrue: [ 
		universe printUsage.
		self exitSuccess.
		^ self ].
	
	[ 
	self stdout nextPutAll: 'start interpretation'; lf; flush.
	1 halt.
	universe start: self arguments ]
		on: Error
		do: [:ex |
			ex printOn: self stderr.
			self exitFailure ]
	

]
