"
Class supporting section organisation
"
Class {
	#name : 'RetumiloSection',
	#superclass : 'Object',
	#instVars : [
		'category',
		'contents',
		'tag'
	],
	#category : 'Retumilo',
	#package : 'Retumilo'
}

{ #category : 'accessing' }
RetumiloSection >> category [

	^ category
]

{ #category : 'accessing' }
RetumiloSection >> category: anObject [

	category := anObject
]

{ #category : 'accessing' }
RetumiloSection >> category: aCategory contents: aString [
	category := aCategory.
	contents := aString withoutTrailingNewlines
]

{ #category : 'accessing' }
RetumiloSection >> contents [

	^ contents
]

{ #category : 'accessing' }
RetumiloSection >> contents: anObject [

	contents := anObject
]

{ #category : 'accessing' }
RetumiloSection >> contentsSize [
	^contents size
]

{ #category : 'accessing' }
RetumiloSection >> icon [

	^ tag
		  ifTrue: [ #smallDoIt ]
		  ifFalse: [ #empty ]
]

{ #category : 'initialization' }
RetumiloSection >> initialize [

	tag := false
]

{ #category : 'testing' }
RetumiloSection >> isTagged [

	^ tag
]

{ #category : 'accessing' }
RetumiloSection >> name [
	^ contents readStream  upTo: Character lf
]

{ #category : 'metrics' }
RetumiloSection >> numberOfLinesOfCode [

	^ contents count: [ :c | c == Character lf ]
]

{ #category : 'accessing' }
RetumiloSection >> positionOfLine: anInteger [

	| countLf countChar position |
	countChar := 0.
	countLf := 0.
	position := -1.
	contents do: [ :c |
		countChar := countChar + 1.
		c == Character lf ifTrue: [ countLf := countLf + 1 ].
		countLf == anInteger ifTrue: [ position := countChar ] ].
	position == -1
		ifTrue: [ ^ nil -> (anInteger -> -1) ]
		ifFalse: [ ^ self -> (anInteger -> position) ]
]

{ #category : 'printing' }
RetumiloSection >> printOn: aStream [
	aStream nextPutAll: self name
]

{ #category : 'loading and saving' }
RetumiloSection >> saveOn: aWriteStream [
	aWriteStream nextPutAll: category optFile startSeparator.
	aWriteStream nextPutAll: category optFile class magicSequence.
	aWriteStream nextPutAll: category name.
	aWriteStream nextPutAll: category optFile class magicSequence.
	aWriteStream nextPutAll: category optFile lastSeparator;lf.	
	aWriteStream nextPutAll: contents;lf.
	
	
]

{ #category : 'searching' }
RetumiloSection >> tagIfFound: aString [

	tag := (contents findString: aString startingAt: 1) > 0.
	^ tag
]
