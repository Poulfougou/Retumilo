"
Main class for Presenter
"
Class {
	#name : 'RetumiloPresenter',
	#superclass : 'SpPresenterWithModel',
	#instVars : [
		'directoriesTree',
		'filesList',
		'categoriesList',
		'sectionsList',
		'text',
		'menuBar',
		'toolBar',
		'statusBar',
		'inEdition',
		'patternField',
		'searchField'
	],
	#category : 'Retumilo',
	#package : 'Retumilo'
}

{ #category : 'commands' }
RetumiloPresenter class >> buildCommandsGroupWith: presenter forRoot: rootCommandGroup [

	rootCommandGroup register: (self buildEditionMenuWith: presenter)
]

{ #category : 'commands' }
RetumiloPresenter class >> buildEditionMenuWith: presenter [

	^ (CmCommandGroup named: 'TextMenu') asSpecGroup
		  beRoot;
		  register: (RetumiloAcceptSection forSpec context: presenter);
		  register: (RetumiloCancelSection forSpec context: presenter);
		  register: (RetumiloDoSection forSpec context: presenter);
		  register: (RetumiloSkipTo forSpec context: presenter);
		  yourself
]

{ #category : 'action - edition' }
RetumiloPresenter >> acceptEdition: aText [

	| sct optFile acceptedText |
	optFile := filesList selectedItem.
	acceptedText := aText withUnixLineEndings.
	acceptedText last == Character lf ifFalse: [
		acceptedText := acceptedText , (String with: Character lf) ].
	optFile isOPTFile
		ifTrue: [
			sct := sectionsList selectedItem.
			sct ifNotNil: [ sct contents: acceptedText ] ]
		ifFalse: [ " case of unformated file text"
			optFile categories first sections first contents:
				acceptedText ].
	optFile save.
	self updateSectionsList. 
	inEdition := false
]

{ #category : 'action - categories' }
RetumiloPresenter >> addCategory [

	| categoryName |
	categoryName := (TextEntryDialogWindow new
		 title: 'Adding a category';
		 text: 'category name ?';
		 entryText: '') openModal entryText.
	self model addCategoryName: categoryName before: categoriesList selectedItem.
	self updateCategoriesList
]

{ #category : 'action - sections' }
RetumiloPresenter >> addSection [

	| section |
	section := sectionsList selectedItem.
	categoriesList selectedItem
		addSectionBefore: section.
	self updateSectionsList
]

{ #category : 'action - edition' }
RetumiloPresenter >> cancelEdition [

	| sct optFile |
	optFile := filesList selectedItem.
	optFile ifNotNil: [
		optFile isOPTFile
			ifTrue: [
				sct := sectionsList selectedItem.
				sct ifNotNil: [ text text: sct contents ] ]
			ifFalse: [ text text: optFile category first sections first contents ] ].

	inEdition := false
]

{ #category : 'accessing' }
RetumiloPresenter >> categoriesList [

	^ categoriesList
]

{ #category : 'accessing' }
RetumiloPresenter >> categoriesList: anObject [

	categoriesList := anObject
]

{ #category : 'menus' }
RetumiloPresenter >> categoriesListMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Create';
				  action: [ self addCategory ] ];
		  addItem: [ :item |
			  item
				  name: 'Rename';
				  action: [ self renameCategory ] ];
		  addItem: [ :item |
			  item
				  name: 'Move up';
				  action: [ self moveCategoryUp ] ];
		  addItem: [ :item |
			  item
				  name: 'Move down';
				  action: [ self moveCategoryDown ] ];
		  addItem: [ :item |
			  item
				  name: 'Delete';
				  action: [ self deleteCategory ] ];
		  yourself
]

{ #category : 'action - files' }
RetumiloPresenter >> computeElocFile [
]

{ #category : 'connexion' }
RetumiloPresenter >> connectCategoriesList [

	categoriesList contextMenu: [ self categoriesListMenu ].
	categoriesList whenSelectionChangedDo: [ :selection |
		selection selectedItem
			ifNotNil: [
				statusBar pushMessage:
					selection selectedItem numberOfLinesOfCode asString ]
			ifNil: [
				filesList selectedItem
					ifNil: [ statusBar popMessage ]
					ifNotNil: [
						statusBar pushMessage:
							filesList selectedItem numberOfLinesOfCode asString ] ].
		self updateSectionsList ]
]

{ #category : 'connexion' }
RetumiloPresenter >> connectFilesList [

	filesList contextMenu: [ self filesListMenu ].
	filesList whenSelectionChangedDo: [ :selection |
		selection selectedItem
			ifNotNil: [
			statusBar pushMessage: selection selectedItem numberOfLinesOfCode asString ]
			ifNil: [ statusBar popMessage ].
		self updateCategoriesList ]
]

{ #category : 'initialization' }
RetumiloPresenter >> connectPresenters [

	self connectTree.
	self connectFilesList.
	self connectCategoriesList.
	self connectSectionsList
]

{ #category : 'connexion' }
RetumiloPresenter >> connectSectionsList [

	sectionsList contextMenu: [ self sectionsListMenu ].
	sectionsList whenSelectionChangedDo: [ :selection |
		selection selectedItem
			ifNotNil: [
				text text: selection selectedItem contents.
				statusBar pushMessage:
					selection selectedItem numberOfLinesOfCode asString.
				inEdition := false ]
			ifNil: [
				text text: ''.
				categoriesList selectedItem
					ifNil: [ statusBar popMessage ]
					ifNotNil: [
						statusBar pushMessage:
							categoriesList selectedItem numberOfLinesOfCode asString.
						inEdition := false ] ] ]
]

{ #category : 'connexion' }
RetumiloPresenter >> connectTree [

	directoriesTree contextMenu: [ self treeMenu ].
	directoriesTree whenSelectionChangedDo: [ :selection |
		self updateFilesList ]
]

{ #category : 'action - files' }
RetumiloPresenter >> createFile [

	| fileName directory |
	fileName := (TextEntryDialogWindow new
		             title: 'Create a file';
		             text: 'file name ?';
		             entryText: '') openModal entryText.
	directory := directoriesTree selectedItem.
	(fileName isNil or: [ directory isNil ]) ifTrue: [ ^ self ].
	(directory fileReference / fileName) writeStream close.
	self updateFilesList
]

{ #category : 'layout' }
RetumiloPresenter >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  positionOfSlider: 40 percent;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 5;
				   add: (SpBoxLayout newTopToBottom
						    spacing: 2;
						    add: directoriesTree;
						    add: searchField expand: false;
						    yourself);
				   add: (SpBoxLayout newTopToBottom
						    spacing: 2;
						    add: filesList;
						    add: patternField expand: false;
						    yourself);
				   add: categoriesList;
				   add: sectionsList;
				   yourself);
		  add: text;
		  yourself
]

{ #category : 'action - menu bar' }
RetumiloPresenter >> defineRootDir [

	| dialog rootDir |
	dialog := FileDialogWindow new
		          title: 'root dir definition';
		          answerDirectory.

	rootDir := dialog openModal answer.
	rootDir ifNil: [ ^ self ].
	application rootDir: rootDir.
	statusBar pushMessage: 'Files loaded.'.
	directoriesTree roots: { application rootDir }
]

{ #category : 'action - categories' }
RetumiloPresenter >> deleteCategory [

	self model deleteCategory: categoriesList selectedItem.
	self updateCategoriesList
]

{ #category : 'action - files' }
RetumiloPresenter >> deleteFile [

	filesList selectedItem delete.
	self updateFilesList
]

{ #category : 'action - sections' }
RetumiloPresenter >> deleteSection [
	
	| section |
	section := sectionsList selectedItem.
	self model deleteSection: section.
	self updateSectionsList
]

{ #category : 'accessing' }
RetumiloPresenter >> directoriesTree [

	^ directoriesTree
]

{ #category : 'accessing' }
RetumiloPresenter >> directoriesTree: anObject [

	directoriesTree := anObject
]

{ #category : 'action - edition' }
RetumiloPresenter >> doSection [

	| currentCategory name |
	currentCategory := categoriesList selectedItem.
	name := currentCategory
		        ifNil: [ 'new category' ]
		        ifNotNil: [ currentCategory name ].
	Clipboard clipboardText:
		(filesList selectedItem sectionLine: name) , String lf.
	text withAdapterDo: [ :anAdapter | anAdapter pasteText ].

	inEdition := true
]

{ #category : 'action - files' }
RetumiloPresenter >> editFile [
]

{ #category : 'menus' }
RetumiloPresenter >> editMenu [
		^ self newMenu
		  addItem: [ :item | item name: 'Copy' ];
		  addItem: [ :item | item name: 'Paste' ];
		  addItem: [ :item | item name: 'Cut' ];
		  yourself
]

{ #category : 'menus' }
RetumiloPresenter >> fileMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'rooDir';
				  action: [ self defineRootDir ] ];
		  addItem: [ :item |
			  item
				  name: 'setup';
				  action: [ self setupLanguage ] ];
		  yourself
]

{ #category : 'accessing' }
RetumiloPresenter >> filesList [

	^ filesList
]

{ #category : 'accessing' }
RetumiloPresenter >> filesList: anObject [

	filesList := anObject
]

{ #category : 'menus' }
RetumiloPresenter >> filesListMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Create';
				  action: [ self createFile ] ];
		  addItem: [ :item |
			  item
				  name: 'Rename';
				  action: [ self renameFile ] ];
		  addItem: [ :item |
			  item
				  name: 'Protect';
				  action: [ self protectFile ] ];
		  addItem: [ :item |
			  item
				  name: 'Unprotect';
				  action: [ self unprotectFile ] ];
		  addItem: [ :item |
			  item
				  name: 'Delete';
				  action: [ self deleteFile ] ];
		  addItem: [ :item |
			  item
				  name: 'Edit';
				  action: [ self editFile ] ];
		  addItem: [ :item |
			  item
				  name: 'Compute eLoc';
				  action: [ self computeElocFile ] ];
		  yourself
]

{ #category : 'action - files' }
RetumiloPresenter >> filterFilesList [
	self updateFilesList

	
]

{ #category : 'accessing' }
RetumiloPresenter >> inEdition [

	^ inEdition
]

{ #category : 'initialization' }
RetumiloPresenter >> initializeListPresenters [
	directoriesTree := SpTreePresenter new
		                   roots: { application rootDir };
		                   children: [ :dir |
			                   dir directories ];
		                   displayIcon: [ :dir |
			                   self iconNamed: dir systemIconName ];
		                   display: [ :dir | dir name ];
		                   expandPath: #( 1 1 3 ).
	filesList := SpListPresenter new display: [ :item | item name ].
	categoriesList := self newList.
	sectionsList := self newList.
]

{ #category : 'initialization' }
RetumiloPresenter >> initializeMenuBar [

	menuBar := self newMenuBar
		           addItem: [ :item |
			           item
				           name: 'File';
				           subMenu: self fileMenu;
				           yourself ];
		           addItem: [ :item |
			           item
				           name: 'Edit';
				           subMenu: self editMenu;
				           yourself ];
		           addItem: [ :item |
			           item
				           name: 'Operation';
				           subMenu: self operationMenu;
				           yourself ];
		           yourself
]

{ #category : 'initialization' }
RetumiloPresenter >> initializePresenters [

	inEdition := false.
	self initializeListPresenters.
	patternField := self newTextInput.
	patternField placeholder: 'Filter...';
		whenTextChangedDo: [ self filterFilesList ].
	searchField := self newTextInput.
	searchField placeholder: 'Search...';
		whenTextChangedDo: [ self searchInFiles ].
	text := self instantiate: SpTextPresenter.
	text beEditable.
	text whenSubmitDo: [ :txt | self acceptEdition: txt ].
	text whenTextChangedDo: [ inEdition := true ].
	text contextMenu: [ self textMenu ].

	self initializeMenuBar.
	self initializeToolBar.
	statusBar := self newStatusBar
]

{ #category : 'initialization' }
RetumiloPresenter >> initializeToolBar [

	| newButton saveButton |
	newButton := self newToolbarButton
		             label: 'New';
		             icon: (self iconNamed: #smallNew);
		             help: 'New email';
		             action: [  ];
		             yourself.
	saveButton := self newToolbarButton
		              label: 'Save';
		              icon: (self iconNamed: #smallSave);
		              help: 'Save email';
		              action: [  ];
		              yourself.
	toolBar := self newToolbar
		           addItem: newButton;
		           addItemRight: saveButton
]

{ #category : 'initialization' }
RetumiloPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Retumilo';
		menu: menuBar;
		toolbar: toolBar;
		statusBar: statusBar;
		initialExtent: 800 @ 500.
	menuBar addKeybindingsTo: aWindowPresenter
]

{ #category : 'action - categories' }
RetumiloPresenter >> moveCategoryDown [

	self model moveCategoryDown: categoriesList selectedItem.
	self updateCategoriesList. 

]

{ #category : 'action - categories' }
RetumiloPresenter >> moveCategoryUp [

	self model moveCategoryUp: categoriesList selectedItem.
	self updateCategoriesList. 

]

{ #category : 'action - sections' }
RetumiloPresenter >> moveSectionDown [

	self model moveSectionDown: sectionsList selectedItem.
	self updateSectionsList. 

]

{ #category : 'action - sections' }
RetumiloPresenter >> moveSectionTo [

	| categoryName section |
	categoryName := (TextEntryDialogWindow new
		                 title: 'Move section to category';
		                 text: 'category name ?';
		                 entryText: '') openModal entryText.
	categoryName ifNil: [ ^ self ].
	section := sectionsList selectedItem.
	sectionsList unselectAll.
	self model
		moveSection: section
		toCategoryNamed: categoryName.
	self updateCategoriesList
]

{ #category : 'action - sections' }
RetumiloPresenter >> moveSectionUp [

	self model moveSectionUp: sectionsList selectedItem.
	self updateSectionsList. 

	
]

{ #category : 'menus' }
RetumiloPresenter >> operationMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Parsing';
				  shortcut: $p meta;
				  enabled: [ filesList selection selectedItem notNil ];
				  action: [
					  application parseFile: filesList selection selectedItem ] ];
		  addItem: [ :item | item name: 'Syntaxic colors' ];
		  yourself
]

{ #category : 'action - files' }
RetumiloPresenter >> protectFile [

	filesList selectedItem protect
]

{ #category : 'action - categories' }
RetumiloPresenter >> renameCategory [
	| categoryName |
	categoryName := (TextEntryDialogWindow new
		 title: 'Renaming a category';
		 text: 'category name ?';
		 entryText: categoriesList selectedItem name) openModal entryText.
	self model renameCategory: categoriesList selectedItem name: categoryName.
	self updateCategoriesList
]

{ #category : 'action - files' }
RetumiloPresenter >> renameFile [

	| fileName currentFileName |
	currentFileName := filesList selectedItem.
	fileName := (TextEntryDialogWindow new
		             title: 'Rename a file';
		             text: 'file name ?';
		             entryText: currentFileName) openModal entryText.
	currentFileName renameTo: fileName.
	self updateFilesList
]

{ #category : 'action - files' }
RetumiloPresenter >> searchInFiles [
]

{ #category : 'accessing' }
RetumiloPresenter >> sectionsList [

	^ sectionsList
]

{ #category : 'accessing' }
RetumiloPresenter >> sectionsList: anObject [

	sectionsList := anObject
]

{ #category : 'menus' }
RetumiloPresenter >> sectionsListMenu [

	^ self newMenu
		  addItem: [ :item |
			  item
				  name: 'Create';
				  action: [ self addSection ] ];
		  addItem: [ :item |
			  item
				  name: 'Move to category ...';
				  enabled: [ sectionsList selection selectedItem notNil ];
				  action: [ self moveSectionTo ] ];
		  addItem: [ :item |
			  item
				  name: 'Move up';
				  enabled: [ sectionsList selection selectedItem notNil ];
				  action: [ self moveSectionUp ] ];
		  addItem: [ :item |
			  item
				  name: 'Move down';
				  enabled: [ sectionsList selection selectedItem notNil ];
				  action: [ self moveSectionDown ] ];
		  addItem: [ :item |
			  item
				  name: 'Delete';
				  enabled: [ sectionsList selection selectedItem notNil ];
				  action: [ self deleteSection ] ];
		  yourself
]

{ #category : 'action - menu bar' }
RetumiloPresenter >> setupLanguage [
]

{ #category : 'action - edition' }
RetumiloPresenter >> skipTo [

	| numLine entryText resultAssociation |
	entryText := (TextEntryDialogWindow new
		              title: 'Skip to';
		              text: 'num line ?';
		              entryText: '') openModal entryText.
	entryText ifNil: [ ^ self ].
	numLine := entryText asNumber.
	resultAssociation := filesList selectedItem positionOfLine: numLine.
	resultAssociation ifNil: [
		text unselectAll.
		^ self ].
	categoriesList selectItem: resultAssociation key category.
	sectionsList selectItem: resultAssociation key.

	text cursorPositionIndex: resultAssociation value value.
	text selectLine.
	text scrollValue:
		0 @ (resultAssociation value key / resultAssociation key numberOfLines) asFloat
]

{ #category : 'accessing' }
RetumiloPresenter >> text [

	^ text
]

{ #category : 'accessing' }
RetumiloPresenter >> text: anObject [

	text := anObject
]

{ #category : 'menus' }
RetumiloPresenter >> textMenu [

	^ self newMenu
		  fillWith: self rootCommandsGroup / 'TextMenu';
		  yourself
]

{ #category : 'menus' }
RetumiloPresenter >> treeMenu [
		^ self newMenu
		  addItem: [ :item | item name: 'Duplicate' ];
		  addItem: [ :item | item name: 'Compute eLoc' ];
		  yourself
]

{ #category : 'action - files' }
RetumiloPresenter >> unprotectFile [

	filesList selectedItem unprotect
]

{ #category : 'updating' }
RetumiloPresenter >> updateCategoriesList [

	| categories currentCategory |
	filesList selectedItem ifNil: [
		categoriesList items: #(  ).
		^ self ].

	filesList selectedItem isOPTFile
		ifFalse: [ " when file is not opt formated, display the contents as sole section"
			statusBar pushMessage: filesList selectedItem numberOfLinesOfCode asString.
			categoriesList items: #(  ).
			sectionsList items: #(  ).
			text text:
				filesList selectedItem categories first sections first
					contents.
			inEdition := false ]
		ifTrue: [ " normal case for opt formated files"
			currentCategory := categoriesList selectedItem.
			self model: filesList selectedItem.
			categories := filesList selectedItem categories.
			categoriesList items: categories.
			currentCategory ifNotNil: [
				categoriesList selectItem: currentCategory ] ]
]

{ #category : 'updating' }
RetumiloPresenter >> updateFilesList [

	| selection pattern |
	pattern := patternField text.
	(pattern isNil or: [ pattern isEmpty ]) ifTrue: [ pattern := '*' ].
	selection := directoriesTree selectedItem.
	selection ifNil: [
		filesList items: #(  ).
		^ self ].
	filesList items:
		(selection files select: [ :file | pattern match: file name ])
]

{ #category : 'updating' }
RetumiloPresenter >> updateSectionsList [

	| currentCategory currentSection |
	self model ifNil: [
		sectionsList items: #(  ).
		^ self ].

	currentCategory := categoriesList selectedItem.
	currentCategory ifNil: [
		sectionsList items: #(  ).
		^ self ].

	currentSection := sectionsList selectedItem.
	sectionsList items: currentCategory sections.
	(currentSection notNil and: [
		 categoriesList selectedItem == currentSection category ]) ifTrue: [
		sectionsList selectItem: currentSection ]
]
