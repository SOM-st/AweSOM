Class {
	#name : #ConfigurationOfAweSOM,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfAweSOM
}

{ #category : #'development support' }
ConfigurationOfAweSOM class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>

]

{ #category : #private }
ConfigurationOfAweSOM class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ].

]

{ #category : #private }
ConfigurationOfAweSOM class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfAweSOM class >> ensureMetacelloBaseConfiguration [

	Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			| repository version |
			repository := MCHttpRepository location: 'http://seaside.gemstone.com/ss/metacello' user: '' password: ''.
			repository
				versionReaderForFileNamed: 'Metacello-Base-DaleHenrichs.2.mcz'
				do: [ :reader | 
					version := reader version.
					version load.
					version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
ConfigurationOfAweSOM class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
ConfigurationOfAweSOM class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
ConfigurationOfAweSOM class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfAweSOM class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #accessing }
ConfigurationOfAweSOM class >> project [

	^self new project
]

{ #category : #'development support' }
ConfigurationOfAweSOM class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((Smalltalk at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) explore
]

{ #category : #baselines }
ConfigurationOfAweSOM >> baseline10: spec [
	<version: '1.0-baseline'>

	spec for: #common do: [
		spec blessing:   #baseline.
		spec repository: 'http://ss3.gemstone.com/ss/AweSOM'.
		spec 
			package: 'AweSOM'.
		spec 
			group: 'default' with: #('Core');
			group: 'Core'    with: #('AweSOM') ].

	spec for: #squeak do: [
			spec package: 'OMeta2-Preload' with: [
				spec repository: 'http://www.squeaksource.com/OMeta'].
			
			spec package: 'OMeta2-Postload' with: [
				spec repository: 'http://www.squeaksource.com/OMeta'.
				spec requires: #('OMeta2-Preload')].
			
			spec package: 'AweSOMOMeta' with: [
					spec requires: #('OMeta2-Postload').].
			spec 
			group: 'default'    with: #('Core OMeta');
			group: 'OMeta'      with: #('AweSOMOMeta');
			group: 'Core OMeta' with: #('Core' 'OMeta'). ].
		
]

{ #category : #'symbolic versions' }
ConfigurationOfAweSOM >> bleedingEdge: spec [
	<symbolicVersion: #bleedingEdge>

	spec for: #common version: '1.0-baseline'

]

{ #category : #'symbolic versions' }
ConfigurationOfAweSOM >> development: spec [
    <symbolicVersion: #development>

    spec for: #common version: '1.0-baseline'
]

{ #category : #accessing }
ConfigurationOfAweSOM >> project [

	^ project ifNil: [ | constructor |
		"Bootstrap Metacello if it is not already loaded"
		(self class baseConfigurationClassIfAbsent: []) ensureMetacello.
		"Construct Metacello project"
		constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self.
		project := constructor project.
		project loadType: #linear. "change to #atomic if desired"
		project ]
]

{ #category : #'symbolic versions' }
ConfigurationOfAweSOM >> stable: spec [
	<symbolicVersion: #stable>

	spec for: #common version: '1.0.0'

]

{ #category : #versions }
ConfigurationOfAweSOM >> version100: spec [
	<version: '1.0.0' imports: #('1.0-baseline')>
	
	spec for: #common do: [
		spec blessing: #release.
		spec description: '1.0.0 (mha.149)
Latest official version by Michael Haupt before Stefan Marr started working on experiments with AweSOM.
This version is considered the stable mainline.'.
		spec author: 'StefanMarr'.
		spec timestamp: '05/26/2012 18:05'.
		
		spec
			package: 'AweSOM' with: 'AweSOM-mha.149'
	].

	spec for: #squeak do: [
		spec
			package: 'OMeta2-Preload'  with: 'OMeta2-Postload-hmm.11';
			package: 'OMeta2-Postload' with: 'OMeta2-Preload-hmm.11'
		]
]
