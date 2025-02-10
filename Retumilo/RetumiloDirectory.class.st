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

{ #category : 'edition' }
RetumiloDirectory >> createFileNamed: fileName [

	| file flc |
	flc := fileLocator / fileName.
	flc writeStream close.
	file := RetumiloFile new.
	file fileLocator: flc.
	file load.
	files add: file.
	^ file
]

{ #category : 'edition' }
RetumiloDirectory >> deleteFile: aFile [
	aFile delete.
	files remove: aFile.
	
]

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

{ #category : 'accessing' }
RetumiloDirectory >> icon [

	^ tag
		  ifTrue: [ super icon ]
		  ifFalse: [ #open ]
]

{ #category : 'loading and saving' }
RetumiloDirectory >> load [

	| fileLocators directoriesLocators |
	fileLocators := fileLocator children reject: [ :chld |
		                chld isDirectory ].
	directoriesLocators := fileLocator children select: [ :chld |
		                       chld isDirectory ].
	files := fileLocators asOrderedCollection collect: [ :flc |
		         | opt |
		         opt := RetumiloFile new.
		         opt fileLocator: flc.
		         opt load.
		         opt ].
	directories := directoriesLocators asOrderedCollection collect: [
		               :flc |
		               | opt |
		               opt := self class new.
		               opt fileLocator: flc.
		               opt load.
		               opt ]
]

{ #category : 'metrics' }
RetumiloDirectory >> numberOfLinesOfCode [

	| numberOfLinesOfCode |
	numberOfLinesOfCode := 0.
	self directories do: [ :dir |
		numberOfLinesOfCode := numberOfLinesOfCode + dir numberOfLinesOfCode ].
	self files do: [ :file |
		numberOfLinesOfCode := numberOfLinesOfCode
		                       + file numberOfLinesOfCode ].
	^ numberOfLinesOfCode
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
