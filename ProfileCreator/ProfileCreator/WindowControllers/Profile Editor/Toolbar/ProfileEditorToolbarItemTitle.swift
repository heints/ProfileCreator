//
//  ProfileEditorToolbarItemTitle.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-22.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class ProfileEditorToolbarItemTitle: NSView {
    
    // MARK: -
    // MARK: Variables
    
    let profile: Profile
    let toolbarItemHeight: CGFloat = 38.0
    let textFieldTitle = NSTextField()

    var toolbarItem: NSToolbarItem?
    var selectionTitle: String?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(profile: Profile) {
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.profile = profile
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Create the text field
        // ---------------------------------------------------------------------
        self.textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldTitle.isBordered = false
        self.textFieldTitle.isBezeled = false
        self.textFieldTitle.drawsBackground = false
        self.textFieldTitle.isEditable = false
        self.textFieldTitle.font = NSFont.systemFont(ofSize: 18, weight: NSFontWeightLight)
        self.textFieldTitle.textColor = NSColor.controlTextColor
        self.textFieldTitle.alignment = .center
        self.textFieldTitle.lineBreakMode = .byTruncatingTail
        self.textFieldTitle.stringValue = profile.title!

        // ---------------------------------------------------------------------
        //  Create the initial size of the toolbar item
        // ---------------------------------------------------------------------
        let frame = NSRect(x: 0.0, y: 0.0, width: self.textFieldTitle.intrinsicContentSize.width, height: self.toolbarItemHeight)

        // ---------------------------------------------------------------------
        //  Initialize self after the class variables have been instantiated
        // ---------------------------------------------------------------------
        super.init(frame: frame)
        
        // ---------------------------------------------------------------------
        //  Add constraints to text field
        // ---------------------------------------------------------------------
        setupTextFieldTitle(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        // ---------------------------------------------------------------------
        //  Create the actual toolbar item
        // ---------------------------------------------------------------------
        self.toolbarItem = NSToolbarItem(itemIdentifier: ToolbarIdentifier.mainWindowAdd)
        self.toolbarItem?.minSize = frame.size
        self.toolbarItem?.maxSize = frame.size
        
        // ---------------------------------------------------------------------
        //  Set the toolbar item view
        // ---------------------------------------------------------------------
        self.toolbarItem?.view = self
        
        // ---------------------------------------------------------------------
        //  Setup key/value observer for the profile title
        // ---------------------------------------------------------------------
        self.profile.addObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: self.profile.title)), options: .new, context: nil)
    }
    
    deinit {
        self.profile.removeObserver(self, forKeyPath: "title", context: nil)
    }
    
    // MARK: -
    // MARK: Instance Functions
    
    func updateTitle() {
        if let profileTitle = profile.title {
            self.textFieldTitle.stringValue = "\(profileTitle) \(self.selectionTitle ?? "")"
        } else {
            self.textFieldTitle.stringValue = self.selectionTitle ?? ""
        }
        
        let frame = NSRect(x: 0.0, y: 0.0, width: self.textFieldTitle.intrinsicContentSize.width, height: self.toolbarItemHeight)
        self.toolbarItem?.minSize = frame.size
        self.toolbarItem?.maxSize = frame.size
        self.frame = frame
    }
    
    // MARK: -
    // MARK: Notification Functions
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        Swift.print("observeValueforKeyPath: \(String(describing: keyPath))")
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    func setupTextFieldTitle(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(self.textFieldTitle)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        
        // Center Vertically
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
    }
}