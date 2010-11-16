Class {
	#name : #SOMGlobalsTest,
	#superclass : #TestCaseWithUniverse,
	#category : #'AweSOM-VM-Test'
}

{ #category : #tests }
SOMGlobalsTest >> test01Metaclass [
	| clazz metaclazz object nilObject |
	metaclazz := universe globalAt: #Metaclass.
	clazz := universe globalAt: #Class.
	object := universe globalAt: #Object.
	nilObject := universe globalAt: #nil.
	self 
		assert: metaclazz somClass somClass
		equals: metaclazz.
	self 
		assert: object somSuperClass
		equals: nilObject.
	self 
		assert: object somClass somSuperClass
		equals: clazz.
	self 
		assert: object somClass somClass
		equals: metaclazz
]

{ #category : #tests }
SOMGlobalsTest >> test02Subclass [
	| object array |
	object := universe globalAt: #Object.
	array := universe globalAt: #Array.
	self 
		assert: array somSuperClass
		equals: object.
	self 
		assert: array somClass somSuperClass
		equals: object somClass
]

{ #category : #tests }
SOMGlobalsTest >> test03NilClass [
	| nilObject nilClass object |
	nilObject := universe globalAt: #nil.
	nilClass := universe globalAt: #Nil.
	object := universe globalAt: #Object.
	self 
		assert: nilObject somClass
		equals: nilClass.
	self 
		assert: nilObject somClass somSuperClass
		equals: object
]
