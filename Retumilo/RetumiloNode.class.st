"
Class common behaviour of file node
"
Class {
	#name : 'RetumiloNode',
	#superclass : 'Object',
	#instVars : [
		'fileLocator',
		'tag'
	],
	#category : 'Retumilo',
	#package : 'Retumilo'
}

{ #category : 'accessing' }
RetumiloNode >> fileLocator [

	^ fileLocator
]

{ #category : 'accessing' }
RetumiloNode >> fileLocator: aFilelocator [

	fileLocator := aFilelocator
]

{ #category : 'accessing' }
RetumiloNode >> icon [

	^ #smallDoIt
]

{ #category : 'initialization' }
RetumiloNode >> initialize [

	tag := false
]

{ #category : 'loading and saving' }
RetumiloNode >> load [
	self subclassResponsibility 
]

{ #category : 'accessing' }
RetumiloNode >> name [

	^ fileLocator basename
]

{ #category : 'printing' }
RetumiloNode >> printOn: aStream [

	aStream nextPutAll: self name
]

{ #category : 'searching' }
RetumiloNode >> tagIfFound: aString [

	self subclassResponsibility
]
