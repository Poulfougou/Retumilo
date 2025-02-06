"
Class supporting category organisation
"
Class {
	#name : 'RetumiloCategory',
	#superclass : 'Object',
	#instVars : [
		'name',
		'optFile',
		'sections',
		'tag'
	],
	#category : 'Retumilo',
	#package : 'Retumilo'
}

{ #category : 'adding item' }
RetumiloCategory >> addSection: aSection [

	sections addLast: aSection.
	aSection category: self
]

{ #category : 'adding item' }
RetumiloCategory >> addSection: str startPosition: startPosition stopPosition: stopPosition [

	| section |
	section := RetumiloSection new
		           category: self
		           contents: str
		           startPosition: startPosition
		           stopPosition: stopPosition.
	sections add: section
]

{ #category : 'adding item' }
RetumiloCategory >> addSectionBefore: aSection [

	| section |
	section := RetumiloSection new category: self contents: 'new section' startPosition: -1 stopPosition: -1.
	aSection
		ifNil: [ sections addLast: section ]
		ifNotNil: [ sections add: section before: aSection ]
]

{ #category : 'accessing' }
RetumiloCategory >> contentsSize [
	 
	^sections sum: [ :sct | sct contents size + 1]
]

{ #category : 'actions - sections' }
RetumiloCategory >> deleteSection: aSection [

	sections remove: aSection.
]

{ #category : 'initialization' }
RetumiloCategory >> initialize [
	sections := OrderedCollection new.
]

{ #category : 'loading and saving' }
RetumiloCategory >> loadSectionOn: aReadStream separator: aSeparator startPosition: anIndex [

	| str |
	aReadStream upTo: Character lf.
	str := aReadStream upToAll: aSeparator , optFile class magicSequence.
	self
		addSection: str
		startPosition: anIndex
		stopPosition: aReadStream position
]

{ #category : 'actions - sections' }
RetumiloCategory >> moveSectionDown: aSection [

	| index |
	index := sections indexOf: aSection.
	index == sections size ifTrue: [ ^ self ].
	(sections at: index + 1) category = aSection category ifTrue: [
		sections swap: index with: index + 1 ]
]

{ #category : 'actions - sections' }
RetumiloCategory >> moveSectionUp: aSection [

	| index |
	index := sections indexOf: aSection.
	index == 1 ifTrue: [ ^ self ].
	((sections at: index - 1) category = aSection category)
		ifTrue: [ sections swap: index with: index - 1 ].
]

{ #category : 'accessing' }
RetumiloCategory >> name [

	^ name
]

{ #category : 'accessing' }
RetumiloCategory >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
RetumiloCategory >> numberOfLines [
	 
	^sections sum: [ :sct | sct numberOfLines + 1]
]

{ #category : 'metrics' }
RetumiloCategory >> numberOfLinesOfCode [

	| numberOfLinesOfCode |
	numberOfLinesOfCode := 0.
	sections do: [ :cat |
		numberOfLinesOfCode := numberOfLinesOfCode + cat numberOfLinesOfCode ].
	^ numberOfLinesOfCode
]

{ #category : 'accessing' }
RetumiloCategory >> optFile [

	^ optFile
]

{ #category : 'accessing' }
RetumiloCategory >> optFile: anObject [

	optFile := anObject
]

{ #category : 'accessing' }
RetumiloCategory >> positionOfLine: anInteger [

	| numLines section resultAssociation |
	numLines := anInteger.
	resultAssociation := nil -> (anInteger -> -1).
	section := sections
		            detect: [ :sct |
			            resultAssociation := sct positionOfLine: numLines - 1.
			            numLines := numLines - sct numberOfLines.
			            resultAssociation key notNil ]
		            ifNone: [ ^ nil -> (anInteger -> -1) ].
	^ resultAssociation
]

{ #category : 'printing' }
RetumiloCategory >> printOn: aStream [
	aStream nextPutAll: self name
]

{ #category : 'adding item' }
RetumiloCategory >> removeSection: aSection [

	sections remove: aSection.
	aSection category: nil
]

{ #category : 'loading and saving' }
RetumiloCategory >> saveOn: aWriteStream [

	sections do: [ :sct | sct saveOn: aWriteStream ]
]

{ #category : 'accessing' }
RetumiloCategory >> sections [

	^ sections
]

{ #category : 'searching' }
RetumiloCategory >> tagIfFound: aString [

	tag := false.
	sections do: [ :sct |
		(sct tagIfFound: aString) ifTrue: [ tag := true ] ].
	^tag
]
