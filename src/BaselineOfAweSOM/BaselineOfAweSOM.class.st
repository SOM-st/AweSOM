Class {
	#name : #BaselineOfAweSOM,
	#superclass : #BaselineOf,
	#category : #BaselineOfAweSOM
}

{ #category : #baselines }
BaselineOfAweSOM >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec package: 'AweSOM'.
				spec group: 'default' with: #('AweSOM') ]
]
