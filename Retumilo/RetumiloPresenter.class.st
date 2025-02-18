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
		'searchField',
		'sectionAdded'
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

{ #category : 'actions - edition' }
RetumiloPresenter >> acceptEdition: aText [

	| file acceptedText |
	file := filesList selectedItem.
	acceptedText := aText withUnixLineEndings.
	acceptedText isEmpty ifTrue: [ ^ self ].
	acceptedText last == Character lf ifFalse: [
		acceptedText := acceptedText , (String with: Character lf) ].
	file
		acceptEdition: acceptedText
		for: sectionsList selectedItem
		sectionAdded: sectionAdded.
	sectionAdded ifTrue: [filesList selectItem: file].
	self searchIn: self model.
	sectionAdded := false.
	inEdition := false
]

{ #category : 'actions - categories' }
RetumiloPresenter >> addCategory [

	| categoryName categorie |
	categoryName := (TextEntryDialogWindow new
		                 title: 'Adding a category';
		                 text: 'category name ?';
		                 entryText: '') openModal entryText.
	categorie := filesList selectedItem
		addCategoryName: categoryName
		before: categoriesList selectedItem.
	categoriesList refresh.
	categoriesList selectItem: categorie
]

{ #category : 'actions - sections' }
RetumiloPresenter >> addSection [

	| section |
	section := sectionsList selectedItem.
	section := categoriesList selectedItem addNewSectionBefore: section.
	sectionsList refresh.
	sectionsList selectItem: section
]

{ #category : 'actions - files' }
RetumiloPresenter >> applyRecipes [
	filesList selectedItem applyRecipes.
	filesList selectItem: filesList selectedItem 
]

{ #category : 'actions - edition' }
RetumiloPresenter >> cancelEdition [

	| sct file |
	file := filesList selectedItem.
	file ifNotNil: [
		file isOPTFile
			ifTrue: [
				sct := sectionsList selectedItem.
				sectionsList selectItem: sct ]
			ifFalse: [ filesList selectItem: file ] ].

	sectionAdded := false.
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
				  enabled: [ categoriesList selection selectedItem notNil ];
				  action: [ self renameCategory ] ];
		  addItem: [ :item |
			  item
				  name: 'Move up';
				  enabled: [ categoriesList selection selectedItem notNil ];
				  action: [ self moveCategoryUp ] ];
		  addItem: [ :item |
			  item
				  name: 'Move down';
				  enabled: [ categoriesList selection selectedItem notNil ];
				  action: [ self moveCategoryDown ] ];
		  addItem: [ :item |
			  item
				  name: 'Delete';
				  enabled: [ categoriesList selection selectedItem notNil ];
				  action: [ self deleteCategory ] ];
		  yourself
]

{ #category : 'actions - files' }
RetumiloPresenter >> computeElocFile [
]

{ #category : 'connexion' }
RetumiloPresenter >> connectCategoriesList [

	categoriesList transmitTo: sectionsList transform: [ :aCategory |
		aCategory ifNotNil: [ aCategory sections ] ifNil: [ #(  ) ] ].
	categoriesList transmitDo: [ :aCategory |
		aCategory
			ifNotNil: [
			statusBar pushMessage: aCategory numberOfLinesOfCode asString ]
			ifNil: [ statusBar popMessage ] ]
]

{ #category : 'connexion' }
RetumiloPresenter >> connectFilesList [

	filesList transmitTo: categoriesList transform: [ :aFile |
		(aFile notNil and: [ aFile isOPTFile ])
			ifTrue: [ aFile categories ]
			ifFalse: [ #(  ) ] ].
	filesList transmitTo: text transform: [ :aFile |
		(aFile notNil and: [ aFile isOPTFile not ])
			ifTrue: [ aFile categories first sections first contents ]
			ifFalse: [ '' ] ].
	filesList transmitDo: [ :aFile |
		aFile
			ifNotNil: [
			statusBar pushMessage: aFile numberOfLinesOfCode asString ]
			ifNil: [ statusBar popMessage ] ]
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

	sectionsList
		transmitTo: text
		transform: [ :aSection |
			aSection ifNotNil: [ aSection contents ] ifNil: [ '' ] ]
		postTransmission: [ :destination :origin :obj |
			(obj notNil and: [ obj isTagged and: [ searchField text isNotEmpty ] ])
				ifTrue: [ self selectFieldInSection: obj ] ].
	sectionsList transmitDo: [ :aSection |
		aSection
			ifNotNil: [
			statusBar pushMessage: aSection numberOfLinesOfCode asString ]
			ifNil: [ statusBar popMessage ] ]
]

{ #category : 'connexion' }
RetumiloPresenter >> connectTree [

	directoriesTree
		transmitTo: filesList
		transform: [ :aDir | aDir ifNotNil: [ aDir files ] ifNil: [ #(  ) ] ].
	directoriesTree transmitDo: [ :aDir |
		aDir
			ifNotNil: [
			statusBar pushMessage: aDir numberOfLinesOfCode asString ]
			ifNil: [ statusBar popMessage ] ]
]

{ #category : 'actions - files' }
RetumiloPresenter >> createFile [

	| fileName directory file |
	fileName := (TextEntryDialogWindow new
		             title: 'Create a file';
		             text: 'file name ?';
		             entryText: '') openModal entryText.
	directory := directoriesTree selectedItem.
	(fileName isNil or: [ directory isNil ]) ifTrue: [ ^ self ].
	file := directory createFileNamed: fileName.
	directoriesTree selectItem: directory.
	filesList selectItem: file
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
				   add: filesList;
				   add: categoriesList;
				   add: sectionsList;
				   yourself);
		  add: text;
		  yourself
]

{ #category : 'actions - menu bar' }
RetumiloPresenter >> defineRootDir [

	| dialog rootDir |
	dialog := FileDialogWindow new
		          title: 'root dir definition';
		          answerDirectory.

	rootDir := dialog openModal answer.
	rootDir ifNil: [ ^ self ].
	self model: rootDir.
	directoriesTree roots: { self model }.
	statusBar pushMessage: 'Files loaded.'.
]

{ #category : 'actions - categories' }
RetumiloPresenter >> deleteCategory [

	filesList selectedItem deleteCategory: categoriesList selectedItem.
	categoriesList unselectAll.
	categoriesList refresh
]

{ #category : 'actions - files' }
RetumiloPresenter >> deleteFile [

	| directory |
	directory := directoriesTree selectedItem.
	directory deleteFile: filesList selectedItem.
	directoriesTree selectItem: directory
]

{ #category : 'actions - sections' }
RetumiloPresenter >> deleteSection [
	
	| section |
	section := sectionsList selectedItem.
	filesList selectedItem deleteSection: section.
	sectionsList refresh.
	sectionsList unselectAll
]

{ #category : 'accessing' }
RetumiloPresenter >> directoriesTree [

	^ directoriesTree
]

{ #category : 'accessing' }
RetumiloPresenter >> directoriesTree: anObject [

	directoriesTree := anObject
]

{ #category : 'actions - edition' }
RetumiloPresenter >> doSection [

	| currentCategory name |
	currentCategory := categoriesList selectedItem.
	name := currentCategory
		        ifNil: [ 'new category' ]
		        ifNotNil: [ currentCategory name ].
	Clipboard clipboardText:
		(filesList selectedItem sectionLine: name) , String lf.
	text withAdapterDo: [ :anAdapter | anAdapter pasteText ].
	sectionAdded := true.
	inEdition := true
]

{ #category : 'actions - global' }
RetumiloPresenter >> duplicateBrowser [

	(self class newApplication: application model: self model)
		open
]

{ #category : 'actions - files' }
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
				  name: 'Apply recipes';
				  action: [ self applyRecipes ] ];
		  addItem: [ :item |
			  item
				  name: 'Inspect';
				  action: [ self inspectFile ] ];
		  yourself
]

{ #category : 'accessing' }
RetumiloPresenter >> inEdition [

	^ inEdition
]

{ #category : 'initialization' }
RetumiloPresenter >> initializeCategoriesListPresenter [

	categoriesList := SpListPresenter new
		                  dropEnabled: true;
		                  wantsDrop: [ :transfer | transfer index > 0 ];
		                  acceptDrop: [ :transfer |
			                  filesList selectedItem
				                  moveSection: transfer passenger first
				                  toCategory:
					                  (categoriesList items at: transfer index).
			                  categoriesList selectItem:
					                  categoriesList selectedItem ];
		                  displayIcon: [ :item | self iconNamed: item icon ];
		                  contextMenu: [ self categoriesListMenu ]
]

{ #category : 'initialization' }
RetumiloPresenter >> initializeDirTreePresenter [

	directoriesTree := SpTreePresenter new
		                   roots: { self model };
		                   children: [ :dir | dir directories ];
		                   displayIcon: [ :dir | self iconNamed: dir icon ];
		                   display: [ :dir | dir name ];
		                   expandPath: #( 1 1 3 );
		                   contextMenu: [ self treeMenu ]
]

{ #category : 'initialization' }
RetumiloPresenter >> initializeFilesListPresenter [

	filesList := SpFilteringListPresenter new itemFilter: [ :item :string |
		             string match: item ].
	filesList listPresenter
		display: [ :item | item name ];
		sortingBlock: [ :a :b | a name < b name ];
		displayIcon: [ :item | self iconNamed: item icon ];
		contextMenu: [ self filesListMenu ]
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
RetumiloPresenter >> initializeOtherPresenters [

	searchField := self newTextInput.
	searchField
		placeholder: 'Search...';
		whenTextChangedDo: [ self searchIn: self model ].
	text := self newText.
	text beEditable.
	text addStyle: '.text'.
	text whenSubmitDo: [ :txt | self acceptEdition: txt ].
	text whenTextChangedDo: [ inEdition := true ].
	text contextMenu: [ self textMenu ].
]

{ #category : 'initialization' }
RetumiloPresenter >> initializePresenters [

	inEdition := false.
	sectionAdded := false.
	self initializeDirTreePresenter.
	self initializeFilesListPresenter.
	self initializeCategoriesListPresenter.
	self initializeSectionsListPresenter.
	self initializeOtherPresenters.

	self initializeMenuBar.
	self initializeToolBar.
	statusBar := self newStatusBar
]

{ #category : 'initialization' }
RetumiloPresenter >> initializeSectionsListPresenter [

	sectionsList := SpListPresenter new
		                dragEnabled: true;
		                displayIcon: [ :item | self iconNamed: item icon ];
		                contextMenu: [ self sectionsListMenu ]
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

{ #category : 'actions - files' }
RetumiloPresenter >> inspectFile [

	filesList selectedItem inspect.

]

{ #category : 'actions - categories' }
RetumiloPresenter >> moveCategoryDown [

	filesList selectedItem moveCategoryDown: categoriesList selectedItem.
	categoriesList refresh
]

{ #category : 'actions - categories' }
RetumiloPresenter >> moveCategoryUp [

	filesList selectedItem moveCategoryUp: categoriesList selectedItem.
	categoriesList refresh
]

{ #category : 'actions - sections' }
RetumiloPresenter >> moveSectionDown [

	| section |
	section := sectionsList selectedItem.
	filesList selectedItem moveSectionDown: section.
	sectionsList selectItem: section.

]

{ #category : 'actions - sections' }
RetumiloPresenter >> moveSectionTo [

	| categoryName category section file |
	categoryName := (TextEntryDialogWindow new
		                 title: 'Move section to category';
		                 text: 'category name ?';
		                 entryText: '') openModal entryText.
	categoryName ifNil: [ ^ self ].
	section := sectionsList selectedItem.
	file := filesList selectedItem.
	sectionsList unselectAll.
	category := file categories
		            detect: [ :cat | cat name = categoryName ]
		            ifNone: [
		            file addCategoryName: categoryName before: nil ].

	file moveSection: section toCategory: category.
	categoriesList refresh
]

{ #category : 'actions - sections' }
RetumiloPresenter >> moveSectionUp [

	| section |
	section := sectionsList selectedItem.
	filesList selectedItem moveSectionUp: section.
	sectionsList selectItem: section
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

{ #category : 'actions - files' }
RetumiloPresenter >> protectFile [

	filesList selectedItem protect
]

{ #category : 'actions - directories' }
RetumiloPresenter >> refreshDirectory [

	| directory |
	directory := directoriesTree selectedItem.
	directory ifNil: [ directory := self model ].
	directory load.
	directoriesTree refresh.
	directoriesTree selectItem: directory.
	filesList listPresenter refresh.
	categoriesList refresh.
	sectionsList refresh
]

{ #category : 'actions - categories' }
RetumiloPresenter >> renameCategory [

	| categoryName |
	categoryName := (TextEntryDialogWindow new
		                 title: 'Renaming a category';
		                 text: 'category name ?';
		                 entryText: categoriesList selectedItem name)
		                openModal entryText.
	filesList selectedItem
		renameCategory: categoriesList selectedItem
		name: categoryName.
	categoriesList refresh
]

{ #category : 'actions - files' }
RetumiloPresenter >> renameFile [

	| fileName currentFileName |
	currentFileName := filesList selectedItem.
	fileName := (TextEntryDialogWindow new
		             title: 'Rename a file';
		             text: 'file name ?';
		             entryText: currentFileName) openModal entryText.
	currentFileName renameTo: fileName.
	filesList refresh
]

{ #category : 'actions - global' }
RetumiloPresenter >> searchIn: anObject [

	anObject tagIfFound: searchField text.
	directoriesTree refresh.
	filesList listPresenter refresh.
	categoriesList refresh.
	sectionsList refresh.
	
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

{ #category : 'actions - sections' }
RetumiloPresenter >> selectFieldInSection: aSection [

	| index |
	index := aSection contents findString: searchField text startingAt: 1.
	text selectionInterval: (index to: index + searchField text size -1)
]

{ #category : 'actions - menu bar' }
RetumiloPresenter >> setupLanguage [
]

{ #category : 'actions - global' }
RetumiloPresenter >> skipTo [

	| numLine entryText resultAssociation file |
	entryText := (TextEntryDialogWindow new
		              title: 'Skip to';
		              text: 'num line ?';
		              entryText: '') openModal entryText.
	(entryText isNil or: [ entryText isEmpty ]) ifTrue: [ ^ self ].
	numLine := entryText asNumber.
	file := filesList selectedItem.
	resultAssociation := file positionOfLine: numLine.
	resultAssociation key ifNil: [
		text unselectAll.
		^ self ].
	file isOPTFile ifTrue: [
		categoriesList selectItem: resultAssociation key category.
		sectionsList selectItem: resultAssociation key ].

	text cursorPositionIndex: resultAssociation value value.
	text selectLine.
	text scrollValue: 0
		@
			(resultAssociation value key / resultAssociation key numberOfLinesOfCode)
				asFloat
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
		  addItem: [ :item |
			  item
				  name: 'Refresh';
				  action: [ self refreshDirectory ] ];
		  addItem: [ :item |
			  item
				  name: 'Duplicate';
				  action: [ self duplicateBrowser ] ];
		  addItem: [ :item | item name: 'Compute eLoc' ];
		  yourself
]

{ #category : 'actions - files' }
RetumiloPresenter >> unprotectFile [

	filesList selectedItem unprotect
]
