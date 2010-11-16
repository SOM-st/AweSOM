Class {
	#name : #SOMTools,
	#superclass : #Object,
	#category : #'AweSOM-Meta'
}

{ #category : #fileout }
SOMTools class >> fileout [

	| cs pi |
	cs := ChangeSet newChangeSet.
	pi := PackageInfo named: 'AweSOM'.
	pi classes do: [:ea | cs addClass: ea].
	pi methods do: [:ea |
		cs
			noteNewMethod: ea compiledMethod
			forClass: ea actualClass
			selector: ea methodSymbol
			priorMethod: nil].
	cs fileOut.
]

{ #category : #linting }
SOMTools class >> lintOnClasses: classes [

	| env |
	env := ClassEnvironment
		onEnvironment: BrowserEnvironment new
		classes: classes.
	ORLintBrowser
		openRule: RBCompositeLintRule allRules
		environment: env.
]

{ #category : #'as yet unclassified' }
SOMTools class >> loc [

	| pi |
	pi := PackageInfo named: 'AweSOM'.
	^ pi classes inject: 0 into: [:sum :class | sum + class linesOfCode].

]

{ #category : #'as yet unclassified' }
SOMTools class >> locWithoutTests [

	| pi |
	pi := PackageInfo named: 'AweSOM'.
	^ (pi classes
		reject: [:class | class inheritsFrom: TestCase])
		inject: 0 into: [:sum :class | sum + class linesOfCode].

]

{ #category : #'as yet unclassified' }
SOMTools class >> parseBenchmarkString: string [

	"Extracts the numbers from the output"
	^ (string
		regex: 'RESULT\: [0-9]+ ms|All tests completed \([0-9]+ ms\)'
		matchesCollect: [:m | (m allRegexMatches: '[0-9]+') first])
		inject: ''
		into: [:all :ea | all , String cr , ea].
	
]

{ #category : #recompiling }
SOMTools class >> recompile [

	"SOMTools recompile"
	(PackageInfo named: 'AweSOM') classes
		do: [:class | class compileAll]
		displayingProgress: 'Recompiling AweSOM'.
]

{ #category : #'class path' }
SOMTools class >> setClassPathBase: basePath [

	"SOMTools setClassPathBase: SmalltalkImage current imagePath , '/SOM'"
	| standard examples dir |
	standard := {basePath , '/Smalltalk'. basePath , '/TestSuite'}.
	dir := FileDirectory on: basePath , '/Examples'.
	examples := dir directoryNames
		select: [:ea | (ea startsWith: '.') not]
		thenCollect: [:ea | dir fullPathFor: ea].
	^ SOMUniverse classPaths: standard , examples.
]

{ #category : #'as yet unclassified' }
SOMTools class >> usefulStuff [

"
SOMUniverse new start: {'TestHarness'}.
SOMUniverse new start: {'MoreBenchmarks'}.
SOMUniverse new start: {'Hello'}.
SOMUniverse new start: {'Echo'. '123'}.
SOMUniverse new start: {'StringTest'}.
SOMUniverse new start: {'All'}.
u := SOMUniverse new.
u eval: '(1 + 2) asString println'.
[u loadAndStoreFromSource: SOMBenchmarkRunner tinyBenchmarkClass] timeToRun.

"
]
