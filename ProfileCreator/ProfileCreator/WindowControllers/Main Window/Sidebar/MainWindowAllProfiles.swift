//
//  MainWindowAllProfiles.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowAllProfiles: NSObject, OutlineViewParentItem {

    // MARK: -
    // MARK: Variables
    
    var isEditable = false
    var title = SidebarGroupTitle.allProfiles
    var children = [OutlineViewChildItem]()
    var cellView: OutlineViewParentCellView?
    
    // MARK: -
    // MARK: Initialization
    
    override init() {        
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        self.cellView = OutlineViewParentCellView(parent: self)
        
        // ---------------------------------------------------------------------
        //  Setup the single outline view child group for this parent
        // ---------------------------------------------------------------------
        let group = MainWindowAllProfilesGroup.init(title: self.title, identifier: nil, parent: self)
        // TODO: When profile controller is added, add all profile identifiers here
        
        // ---------------------------------------------------------------------
        //  Add the group to this parent's childen
        // ---------------------------------------------------------------------
        self.children.append(group)
    }
}

class MainWindowAllProfilesGroup: NSObject, OutlineViewChildItem {
    
    // MARK: -
    // MARK: Variables
    
    var isEditable = false
    var isEditing = false
    var icon: NSImage?
    var identifier: UUID
    var title: String
    var children = [OutlineViewChildItem]()
    var profileIdentifiers = [UUID]()
    var cellView: OutlineViewChildCellView?
    
    // MARK: -
    // MARK: Initialization
    
    init(title: String, identifier: UUID?, parent: OutlineViewParentItem) {
        
        self.title = title
        self.identifier = (identifier != nil) ? identifier! : UUID()
        
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        self.cellView = OutlineViewChildCellView(child: self)

        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveProfile(_:)), name: .didRemoveProfile, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didRemoveProfile, object: nil)
    }
        
    // MARK: -
    // MARK: Notification Functions
    
    func didRemoveProfile(_ notification: NSNotification) {
        Swift.print("didRemoveProfiles")
    }
    
    // MARK: -
    // MARK: OutlineViewChildItem Functions
    
    func addProfiles(identifiers: [UUID]) {
        //TODO: Implement
    }
    
    func removeProfiles(identifiers: [UUID]) {
        fatalError("All Profiles should never call removeProfiles(identifiers:)")
    }
    
    func removeProfiles(atIndexes: IndexSet) {
        fatalError("All Profiles should never call removeProfiles(atIndexes:)")
    }
    
    func removeFromDisk() -> (Bool, Error?) {
        fatalError("All Profiles should never call removeFromDisk()")
    }
    
    func writeToDisk(title: String) -> (Bool, Error?) {
        fatalError("All Profiles should never call writeToDisk(title:)")
    }
    
    // MARK: -
    // MARK: MainWindowOutlineViewDelegate Functions
    //TODO: Implement
}