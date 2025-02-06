"
Command for accepting the modified text
"
Class {
	#name : 'RetumiloAcceptSection',
	#superclass : 'RetumiloCommand',
	#category : 'Retumilo-commands',
	#package : 'Retumilo-commands'
}

{ #category : 'converting' }
RetumiloAcceptSection >> asSpecCommand [ 
	^super asSpecCommand
             iconName: #accept;
             shortcutKey: $s meta;
             yourself
]

{ #category : 'testing' }
RetumiloAcceptSection >> canBeExecuted [
	^self presenter inEdition
]

{ #category : 'executing' }
RetumiloAcceptSection >> execute [

	self presenter acceptEdition: self presenter text text
]

{ #category : 'initialization' }
RetumiloAcceptSection >> initialize [
   super initialize.
    self
       name: 'Accept';
       description: 'Accept the modification'
]
