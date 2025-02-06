"
retumilo is a general purpose browser for code.
Tags are separating sections that is classed in categories.
"
Class {
	#name : 'RetumiloApp',
	#superclass : 'SpApplication',
	#instVars : [
		'rootDir',
		'files'
	],
	#category : 'Retumilo',
	#package : 'Retumilo'
}

{ #category : 'accessing' }
RetumiloApp >> files [

	^ files
]

{ #category : 'accessing' }
RetumiloApp >> files: anObject [

	files := anObject
]

{ #category : 'parsing' }
RetumiloApp >> loadOPTFiles: fileLocators [

	files := fileLocators collect: [ :flc |
		         | opt |
		         opt := RetumiloFile new.
		         opt fileLocator: flc.
		         opt load.
		         opt ].
	files := files sort: [ :a :b | a name < b name ]
]

{ #category : 'parsing' }
RetumiloApp >> parseFile: fileLocator [
]

{ #category : 'accessing' }
RetumiloApp >> rootDir [

	^ rootDir
]

{ #category : 'accessing' }
RetumiloApp >> rootDir: anObject [
	
	rootDir := RetumiloDirectory new fileLocator: anObject.
	rootDir load
]

{ #category : 'running' }
RetumiloApp >> start [
	(RetumiloPresenter newApplication: self) open
]
