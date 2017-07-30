//
//  PreferencesEditor.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-29.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PreferencesEditor: PreferencesItem {
    
    // MARK: -
    // MARK: Variables
    
    let identifier = ToolbarIdentifier.preferencesEditor
    let toolbarItem: NSToolbarItem
    let view: NSView
    
    // MARK: -
    // MARK: Initialization
    
    init(sender: PreferencesWindowController) {
        
        // ---------------------------------------------------------------------
        //  Create the toolbar item
        // ---------------------------------------------------------------------
        self.toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        self.toolbarItem.image = NSImage(named: NSImageNamePreferencesGeneral)
        self.toolbarItem.label = NSLocalizedString("Editor", comment: "")
        self.toolbarItem.paletteLabel = self.toolbarItem.label
        self.toolbarItem.toolTip = self.toolbarItem.label
        self.toolbarItem.target = sender
        self.toolbarItem.action = #selector(sender.toolbarItemSelected(_:))
        
        // ---------------------------------------------------------------------
        //  Create the preferences view
        // ---------------------------------------------------------------------
        self.view = PreferencesEditorView()
    }
}

class PreferencesEditorView: NSView {
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: NSZeroRect)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        var frameHeight: CGFloat = 0.0
        var lastSubview: NSView?
        
        // ---------------------------------------------------------------------
        //  Add Preferences "Sidebar"
        // ---------------------------------------------------------------------
        lastSubview = addHeader(title: "Payload Library",
                                withSeparator: true,
                                toView: self,
                                lastSubview: nil,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Apple Collections",
                                  keyPath: PreferenceKey.showPayloadLibraryAppleCollections,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Apple Domains",
                                  keyPath: PreferenceKey.showPayloadLibraryAppleDomains,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Developer",
                                  keyPath: PreferenceKey.showPayloadLibraryDeveloper,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Add constraints to last view
        // ---------------------------------------------------------------------
        
        // Bottom
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: lastSubview,
            attribute: .bottom,
            multiplier: 1,
            constant: 20))
        
        frameHeight = frameHeight + 20.0
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        // ---------------------------------------------------------------------
        //  Set the view frame for use when switching between preference views
        // ---------------------------------------------------------------------
        self.frame = NSRect.init(x: 0.0, y: 0.0, width: preferencesWindowWidth, height: frameHeight)
    }
}