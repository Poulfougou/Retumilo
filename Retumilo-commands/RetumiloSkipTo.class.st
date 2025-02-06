"
Command for skiping to the section containing the line given by the dialog prompt
"
Class {
	#name : 'RetumiloSkipTo',
	#superclass : 'RetumiloCommand',
	#category : 'Retumilo-commands',
	#package : 'Retumilo-commands'
}

{ #category : 'converting' }
RetumiloSkipTo >> asSpecCommand [ 
	^super asSpecCommand
             iconName: #skipTo;
             shortcutKey: $l meta;
             yourself
]

{ #category : 'executing' }
RetumiloSkipTo >> execute [

	self presenter skipTo
]

{ #category : 'initialization' }
RetumiloSkipTo >> initialize [
   super initialize.
    self
       name: 'SkipTo';
       description: 'SkipTo'
]
