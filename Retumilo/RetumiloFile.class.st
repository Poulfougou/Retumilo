"
Class supporting file organisation
"
Class {
	#name : 'RetumiloFile',
	#superclass : 'RetumiloNode',
	#instVars : [
		'categories'
	],
	#classInstVars : [
		'types'
	],
	#category : 'Retumilo',
	#package : 'Retumilo'
}

{ #category : 'class initialization' }
RetumiloFile class >> initialize [
	"self initialize"
	
	types := Dictionary new.
	types at: 'c' asSymbol put: #('/*' '*/').
	types at: 'h' asSymbol put: #('/*' '*/').
	types at: 'cpp' asSymbol put: #('//' '').
	types at: 'hpp' asSymbol put: #('//' '').
	types at: 'cc' asSymbol put: #('//' '').
	types at: 'hh' asSymbol put: #('//' '').
	types at: 'F' asSymbol put: #('!---' '---').
	types at: 'F90' asSymbol put: #('!---' '---').

]

{ #category : 'accessing' }
RetumiloFile class >> magicSequence [

	^ '``'
]

{ #category : 'accessing' }
RetumiloFile class >> separatorsForSuffix: aString [
	aString crTrace.
	^ types at: aString asSymbol ifAbsent: [ #('/*' 'check suffix */')  ]
]

{ #category : 'editing - categories' }
RetumiloFile >> addCategoryName: aString before: anOther [

	| category |
	category := RetumiloCategory new
		            name: aString;
		            optFile: self.
	anOther
		ifNil: [ self categories addLast: category ]
		ifNotNil: [ self categories add: category before: anOther ].
	^ category
]

{ #category : 'accessing' }
RetumiloFile >> backupFileLocator [

	^ (fileLocator fullPath , '~') asFileLocatorOrReference
]

{ #category : 'accessing' }
RetumiloFile >> categories [

	categories ifNil: [ categories := OrderedCollection new ].
	^ categories
]

{ #category : 'loading  and saving' }
RetumiloFile >> createSingletonSectionWith: str [

	| category |
	category := RetumiloCategory new optFile: self.
	category addSection: str startPosition: 0 stopPosition: -1.
	self categories add: category
]

{ #category : 'file management' }
RetumiloFile >> delete [

	fileLocator delete
]

{ #category : 'editing - categories' }
RetumiloFile >> deleteCategory: aCategory [

	self categories remove: aCategory.
	self save
]

{ #category : 'editing - sections' }
RetumiloFile >> deleteSection: aSection [

	aSection category deleteSection: aSection.
	self save.
]

{ #category : 'loading  and saving' }
RetumiloFile >> initializeLoadingOn: readStream [

	| str |
	str := nil.
	[ str := readStream upToAll: self class magicSequence ]
		on: Exception
		do: [
			self createSingletonSectionWith: 'not UTF8 file'.
			readStream close ].
	^ str
]

{ #category : 'testing' }
RetumiloFile >> isOPTFile [
	^(self categories size ~= 1 or: [ self categories first name notNil]) 
]

{ #category : 'accessing' }
RetumiloFile >> lastSeparator [

	^ (self class separatorsForSuffix: (self suffix)) last 
]

{ #category : 'loading and saving' }
RetumiloFile >> load [

	| readStream str startPosition separator currentCategory categoryName |
	fileLocator exists ifFalse: [ ^ self ].
	readStream := fileLocator readStream.
	startPosition := 0.
	(str := self initializeLoadingOn: readStream) ifNil: [ ^ self ].
	currentCategory := nil.
	readStream atEnd
		ifTrue: [ self createSingletonSectionWith: str ]
		ifFalse: [
			separator := str.
			[ readStream atEnd ] whileFalse: [
				categoryName := readStream upToAll: self class magicSequence.
				(currentCategory isNil or: [ categoryName ~= currentCategory name ])
					ifTrue: [
					currentCategory := self addCategoryName: categoryName before: nil ].
				currentCategory
					loadSectionOn: readStream
					separator: separator
					startPosition: startPosition.
				startPosition := readStream position ] ].
	readStream close
]

{ #category : 'loading  and saving' }
RetumiloFile >> makeBackup [

	| fileRef path |
	fileRef := self backupFileLocator.
	path := fileLocator fullPath.
	fileRef asFileReference deleteIfAbsent: [  ].
	fileLocator asFileReference moveTo: fileRef.
	fileLocator := path asFileLocatorOrReference.
]

{ #category : 'editing - categories' }
RetumiloFile >> moveCategoryDown: aCategory [

	| index |
	index := self categories indexOf: aCategory.
	index == self categories size ifTrue: [ ^ self ].
	self categories swap: index with: index + 1.
	self save
]

{ #category : 'editing - categories' }
RetumiloFile >> moveCategoryUp: aCategory [

	| index |
	index := self categories indexOf: aCategory.
	index == 1 ifTrue: [ ^ self ].
	self categories swap: index with: index - 1.
	self save
]

{ #category : 'editing - sections' }
RetumiloFile >> moveSection: aSection toCategoryNamed: aCategoryName [

	| category |
	category := self categories
		            detect: [ :cat | cat name = aCategoryName ]
		            ifNone: [
		            self addCategoryName: aCategoryName before: nil ].
	aSection category removeSection: aSection.
	category addSection: aSection
]

{ #category : 'editing - sections' }
RetumiloFile >> moveSectionDown: aSection [

	aSection category moveSectionDown: aSection.
	self save.
]

{ #category : 'editing - sections' }
RetumiloFile >> moveSectionUp: aSection [

	aSection category moveSectionUp: aSection.
	self save.
]

{ #category : 'metrics' }
RetumiloFile >> numberOfLinesOfCode [

	| numberOfLinesOfCode |
	numberOfLinesOfCode := 0.
	self categories do: [ :cat |
		numberOfLinesOfCode := numberOfLinesOfCode + cat numberOfLinesOfCode ].
	^ numberOfLinesOfCode
]

{ #category : 'file management' }
RetumiloFile >> positionOfLine: anInteger [

	| numLines category resultAssociation |
	numLines := anInteger.
	resultAssociation := nil -> (anInteger -> -1).
	category := self categories
		            detect: [ :cat |
			            resultAssociation := cat positionOfLine: numLines.
			            numLines := numLines - cat numberOfLines.
			            resultAssociation key notNil ]
		            ifNone: [ ^ nil -> (anInteger -> -1) ].
	^ resultAssociation
]

{ #category : 'file management' }
RetumiloFile >> protect [

	fileLocator permissions:
		(FileSystemPermission posixPermissions: 8r444)
]

{ #category : 'editing - categories' }
RetumiloFile >> renameCategory: aCategory name: aCategoryName [

	aCategory name: aCategoryName.
	self save
]

{ #category : 'file management' }
RetumiloFile >> renameTo: aString [

	fileLocator renameTo: aString
]

{ #category : 'loading  and saving' }
RetumiloFile >> save [

	| writeStream |
	fileLocator exists ifTrue: [ self makeBackup ].
	writeStream := fileLocator writeStream.
	self isOPTFile
		ifFalse: [
		writeStream nextPutAll: self categories first sections first contents ]
		ifTrue: [ self categories do: [ :cat | cat saveOn: writeStream ] ].
	writeStream close
]

{ #category : 'accessing' }
RetumiloFile >> sectionLine: aCategoryName [

	^ self startSeparator , self class magicSequence
	  , aCategoryName , self class magicSequence
	  , self lastSeparator
]

{ #category : 'accessing' }
RetumiloFile >> startSeparator [

	^ (self class separatorsForSuffix: self suffix) first 
]

{ #category : 'accessing' }
RetumiloFile >> suffix [

	| basename stream |
	basename := fileLocator basename.
	stream := basename readStream.
	stream upToAll: '.'.
	^ stream upToEnd asSymbol
]

{ #category : 'searching' }
RetumiloFile >> tagIfFound: aString [
	tag := false.
	categories do: [ :cat | (cat tagIfFound: aString) ifTrue: [tag := true]]
]

{ #category : 'file management' }
RetumiloFile >> unprotect [

	fileLocator permissions:
		(FileSystemPermission posixPermissions: 8r644)
]
