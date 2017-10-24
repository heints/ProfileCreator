//
//  ProfileEditor.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-24.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class ProfileEditor: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    private let tableView = ProfileEditorTableView()
    public let scrollView = NSScrollView()
    
    private let payloadCellViews = PayloadCellViews()
    
    fileprivate var cellViews = [NSTableCellView]()
    fileprivate var editorWindow: NSWindow?
    
    private weak var profile: Profile?
    private var selectedPayloadPlaceholder: PayloadPlaceholder?
    
    init(profile: Profile) {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.profile = profile
        
        // ---------------------------------------------------------------------
        //  Setup TableView
        // ---------------------------------------------------------------------
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.floatsGroupRows = false
        self.tableView.rowSizeStyle = .default
        self.tableView.headerView = nil
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.target = self
        self.tableView.allowsMultipleSelection = true
        self.tableView.selectionHighlightStyle = .none
        self.tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        self.tableView.sizeLastColumnToFit()
        self.tableView.refusesFirstResponder = true
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Padding Leading
        // ---------------------------------------------------------------------
        let tableColumnPaddingLeading = NSTableColumn(identifier: .tableColumnPaddingLeading)
        tableColumnPaddingLeading.isEditable = false
        tableColumnPaddingLeading.width = editorTableViewColumnPaddingWidth
        tableColumnPaddingLeading.minWidth = editorTableViewColumnPaddingWidth
        self.tableView.addTableColumn(tableColumnPaddingLeading)
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Payload
        // ---------------------------------------------------------------------
        let tableColumnPayload = NSTableColumn(identifier: .tableColumnPayload)
        tableColumnPayload.isEditable = false
        tableColumnPayload.width = editorTableViewColumnPayloadWidth
        tableColumnPayload.minWidth = editorTableViewColumnPayloadWidth
        tableColumnPayload.maxWidth = editorTableViewColumnPayloadWidth
        self.tableView.addTableColumn(tableColumnPayload)
        
        // ---------------------------------------------------------------------
        //  Add TableColumn Padding Trailing
        // ---------------------------------------------------------------------
        let tableColumnPaddingTrailing = NSTableColumn(identifier: .tableColumnPaddingTrailing)
        tableColumnPaddingTrailing.isEditable = false
        tableColumnPaddingTrailing.width = editorTableViewColumnPaddingWidth
        tableColumnPaddingTrailing.minWidth = editorTableViewColumnPaddingWidth
        self.tableView.addTableColumn(tableColumnPaddingTrailing)
        
        // ---------------------------------------------------------------------
        //  Setup ScrollView and add TableView as Document View
        // ---------------------------------------------------------------------
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        //self.scrollView.hasVerticalScroller = true
        self.scrollView.documentView = self.tableView
        // self.scrollView.autoresizesSubviews = true
        
        self.reloadTableView(force: true)
    }
    
    deinit {
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
    }
    
    func reloadTableView(force: Bool = false) {
        // TODO: Implement
        self.tableView.reloadData()
    }
    
    func select(payloadPlaceholder: PayloadPlaceholder) {
        if self.selectedPayloadPlaceholder != payloadPlaceholder {
            self.selectedPayloadPlaceholder = payloadPlaceholder
            Swift.print("Class: \(self.self), Function: \(#function), Selecting this placeholder in the editor: \(payloadPlaceholder.title)")
            
            // FIXME: Apply current settings here (like hidden)
            self.cellViews = payloadCellViews.cellViews(payloadPlaceholder: payloadPlaceholder)
            
            // FIXME: Why Force?
            self.reloadTableView(force: true)
        }
    }
    
    func updateKeyViewLoop(window: NSWindow) {
        
        var previousCellView: PayloadCellView? = nil
        var firstCellView: PayloadCellView? = nil
        
        for (index, cellView) in self.cellViews.enumerated() {
            guard let payloadCellView = cellView as? PayloadCellView else { continue }
            
            if payloadCellView.leadingKeyView != nil {
                if let previous = previousCellView {
                    previous.trailingKeyView!.nextKeyView = payloadCellView.leadingKeyView
                } else {
                    firstCellView = payloadCellView
                }
                previousCellView = payloadCellView
                
                if self.cellViews.count == index + 1  {
                    tableView.nextKeyView = firstCellView?.leadingKeyView
                    payloadCellView.trailingKeyView!.nextKeyView = tableView
                }
            }
        }
        
        if firstCellView != nil {
            window.initialFirstResponder = firstCellView as? NSView
        }
    }
}

extension ProfileEditor: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.cellViews.count
    }
}

extension ProfileEditor: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let cellView = self.cellViews[row] as? ProfileCreatorCellView {
            return cellView.height
        }
        return 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == .tableColumnPayload {
            // FIXME: Should only be needed once and NOT here
            self.updateKeyViewLoop(window: tableView.window!)
            return self.cellViews[row]
        }
        return nil
    }
}

// Sublcasses to enable FirstResponder and KeyView

class PayloadButton: NSButton {
    override var acceptsFirstResponder: Bool { return self.isEnabled }
    override var canBecomeKeyView: Bool { return self.isEnabled }
}

class PayloadCheckbox: NSButton {
    override var acceptsFirstResponder : Bool { return self.isEnabled }
    override var canBecomeKeyView: Bool { return self.isEnabled }
}

class PayloadPopUpButton: NSPopUpButton {
    override var acceptsFirstResponder : Bool { return self.isEnabled }
    override var canBecomeKeyView: Bool { return self.isEnabled }
}

class PayloadTextField: NSTextField {
    override var acceptsFirstResponder : Bool { return self.isEditable }
    override var canBecomeKeyView: Bool { return self.isEditable }
}

class PayloadTextView: NSTextView {
    override var acceptsFirstResponder : Bool { return self.isEditable }
    override var canBecomeKeyView: Bool { return self.isEditable }
    override func doCommand(by selector: Selector) {
        if selector == #selector(insertTab(_:)) {
            self.window?.selectNextKeyView(nil)
        } else if selector == #selector(insertBacktab(_:)) {
            self.window?.selectPreviousKeyView(nil)
        } else {
            super.doCommand(by: selector)
        }
    }
}

class ProfileEditorTableView: NSTableView {
    override var acceptsFirstResponder: Bool { return false }
    override var canBecomeKeyView: Bool { return false }
}

