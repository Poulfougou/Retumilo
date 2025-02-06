"
Class supporting directory organisation
"
Class {
	#name : 'RetumiloDirectory',
	#superclass : 'RetumiloNode',
	#instVars : [
		'directories',
		'files'
	],
	#category : 'Retumilo',
	#package : 'Retumilo'
}

{ #category : 'accessing' }
RetumiloDirectory >> directories [

	^ directories
]

{ #category : 'accessing' }
RetumiloDirectory >> directories: anObject [

	directories := anObject
]

{ #category : 'accessing' }
RetumiloDirectory >> files [

	^ files
]

{ #category : 'accessing' }
RetumiloDirectory >> files: anObject [

	files := anObject
]

{ #category : 'loading and saving' }
RetumiloDirectory >> load [

	| fileLocators directoriesLocators |
	fileLocators := fileLocator children reject: [ :chld |
		                chld isDirectory ].
	directoriesLocators := fileLocator children select: [ :chld |
		                       chld isDirectory ].
	files := fileLocators collect: [ :flc |
		         | opt |
		         opt := RetumiloFile new.
		         opt fileLocator: flc.
		         opt load.
		         opt ].
	files := files sort: [ :a :b | a name < b name ].
	directories := directoriesLocators collect: [ :flc |
		               | opt |
		               opt := self class new.
		               opt fileLocator: flc.
		               opt load.
		               opt ].
	directories := directories sort: [ :a :b | a name < b name ]
]

{ #category : 'searching' }
RetumiloDirectory >> tagIfFound: aString [

	tag := false.
	files do: [ :file |
		(file tagIfFound: aString) ifTrue: [ tag := true ] ].
	directories do: [ :dir |
		(dir tagIfFound: aString) ifTrue: [ tag := true ] ].
	^ tag
]
