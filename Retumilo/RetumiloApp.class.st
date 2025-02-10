"
retumilo is a general purpose browser for code.
Tags are separating sections that is classed in categories.
"
Class {
	#name : 'RetumiloApp',
	#superclass : 'SpApplication',
	#category : 'Retumilo',
	#package : 'Retumilo'
}

{ #category : 'parsing' }
RetumiloApp >> parseFile: fileLocator [
]

{ #category : 'running' }
RetumiloApp >> start [

	| dialog presenter rooDirStr rootDir|
	dialog := FileDialogWindow new
		          title: 'root dir definition';
		          answerDirectory.

	rooDirStr := dialog openModal answer.
	rooDirStr ifNil: [ ^ self ].
	rootDir := RetumiloDirectory new fileLocator:
		           rooDirStr asFileLocatorOrReference.
	rootDir load.
	presenter := RetumiloPresenter newApplication: self model: rootDir.
	presenter open
]
