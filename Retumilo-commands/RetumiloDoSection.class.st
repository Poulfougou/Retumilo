"
Command for adding a new tag and then create a section in the text
"
Class {
	#name : 'RetumiloDoSection',
	#superclass : 'RetumiloCommand',
	#category : 'Retumilo-commands',
	#package : 'Retumilo-commands'
}

{ #category : 'converting' }
RetumiloDoSection >> asSpecCommand [ 
	^super asSpecCommand
             iconName: #do;
             shortcutKey: $a meta;
             yourself
]

{ #category : 'executing' }
RetumiloDoSection >> execute [

	self presenter doSection
]

{ #category : 'initialization' }
RetumiloDoSection >> initialize [
   super initialize.
    self
       name: 'Section';
       description: 'Add a section'
]
