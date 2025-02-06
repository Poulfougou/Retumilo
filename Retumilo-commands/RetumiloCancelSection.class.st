"
Command for canceling edition
"
Class {
	#name : 'RetumiloCancelSection',
	#superclass : 'RetumiloCommand',
	#category : 'Retumilo-commands',
	#package : 'Retumilo-commands'
}

{ #category : 'converting' }
RetumiloCancelSection >> asSpecCommand [ 
	^super asSpecCommand
             iconName: #cancel;
             shortcutKey: $l meta;
             yourself
]

{ #category : 'testing' }
RetumiloCancelSection >> canBeExecuted [
	^self presenter inEdition
]

{ #category : 'executing' }
RetumiloCancelSection >> execute [

	self presenter cancelEdition
]

{ #category : 'initialization' }
RetumiloCancelSection >> initialize [
   super initialize.
    self
       name: 'Cancel';
       description: 'Cancel the modification'
]
