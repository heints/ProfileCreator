//
//  ProfileController.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-15.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class ProfileController: NSDocumentController {
    
    // MARK: -
    // MARK: Variables
    
    public static let sharedInstance = ProfileController()
    
    var profiles = Set<Profile>()
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        
        
        // ---------------------------------------------------------------------
        //  Load all saved profiles from disk
        // ---------------------------------------------------------------------
        self.loadSavedProfiles()
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose(_:)), name: NSWindow.willCloseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newDocument(_:)), name: .newProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeProfile(_:)), name: .removeProfile, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .newProfile, object: nil)
        NotificationCenter.default.removeObserver(self, name: .removeProfile, object: nil)
    }
    
    // MARK: -
    // MARK: Notification Functions
    
    @objc func windowWillClose(_ notification: Notification?) {
        
        // ---------------------------------------------------------------------
        //  If window was a ProfileEditor window, update the associated profile
        // ---------------------------------------------------------------------
        if let window = notification?.object as? NSWindow,
            let windowController = window.windowController as? ProfileEditorWindowController {
            
            // -----------------------------------------------------------------
            //  Get profile associated with the editor
            // -----------------------------------------------------------------
            guard let profile = windowController.document as? Profile else {
                // TODO: Proper logging
                return
            }
                        
            // -----------------------------------------------------------------
            //  Remove the window controller from the profile
            // -----------------------------------------------------------------
            profile.removeWindowController(windowController)
            
            // -----------------------------------------------------------------
            //  If no URL is associated, it has never been saved
            // -----------------------------------------------------------------
            if profile.fileURL == nil {
                let identifier = profile.identifier
                let (success, error) = removeProfile(identifier: identifier)
                if success {
                    
                    // ---------------------------------------------------------
                    //  If removed successfully, post a didRemoveProfiles notification
                    // ---------------------------------------------------------
                    NotificationCenter.default.post(name: .didRemoveProfiles, object: self, userInfo: [NotificationKey.identifiers: [ identifier ],
                                                                                                       NotificationKey.indexSet : IndexSet()])
                } else {
                    print("Function: \(#function), Error: \(String(describing: error))")
                }
            }
        }
    }
    
    override func newDocument(_ sender: Any?) {
        do {
            if let profile = try self.openUntitledDocumentAndDisplay(true) as? Profile {
                
                
                self.profiles.insert(profile)
                
                // -------------------------------------------------------------
                //  Post notification that a profile was added
                // -------------------------------------------------------------
                NotificationCenter.default.post(name: .didAddProfile, object: self, userInfo: [NotificationKey.identifier : profile.identifier])
            }
        } catch {
            Swift.print("ERROR")
        }
    }
    
    @objc func removeProfile(_ notification: Notification?) {
        Swift.print("removeProfile: \(String(describing: notification))")
    }
    
    // MARK: -
    // MARK: Public Functions
    
    public func profileIdentifiers() -> [UUID]? {
        return self.profiles.map({ $0.identifier })
    }
    
    public func profile(withIdentifier: UUID) -> Profile? {
        return self.profiles.first(where: {$0.identifier == withIdentifier})
    }
    
    public func removeProfiles(atIndexes: IndexSet, withIdentifiers: [UUID]) {
        var removedIdentifiers = [UUID]()
        
        // ---------------------------------------------------------------------
        //  Loop through all passed identifiers and try to remove them individually
        // ---------------------------------------------------------------------
        for identifier in withIdentifiers {
            let (success, error) = removeProfile(identifier: identifier)
            if success {
                
                // -------------------------------------------------------------
                //  If removed successfully, add to removedIdentifiers
                // -------------------------------------------------------------
                removedIdentifiers.append(identifier)
            } else {
                print("Function: \(#function), Error: \(String(describing: error))")
            }
        }
        
        // ---------------------------------------------------------------------
        //  Post all successfully removed profile identifiers as a didRemoveProfile notification
        // ---------------------------------------------------------------------
        if !removedIdentifiers.isEmpty {
            NotificationCenter.default.post(name: .didRemoveProfiles, object: self, userInfo: [NotificationKey.identifiers: removedIdentifiers,
                                                                                               NotificationKey.indexSet : atIndexes])
        }
    }
    
    public func titleOfProfile(withIdentifier: UUID) -> String? {
        if let profile = self.profile(withIdentifier: withIdentifier) {
            return profile.title
        }
        return nil
    }
    
    // MARK: -
    // MARK: Private Functions
    
    private func removeProfile(identifier: UUID) -> (Bool, Error?) {
        
        var error: Error?
        
        if let profile = self.profile(withIdentifier: identifier) {
            
            // -----------------------------------------------------------------
            //  Try to get the URL, if it doesn't have a URL, it should not be saved on disk
            // -----------------------------------------------------------------
            guard let url = profile.fileURL, FileManager.default.fileExists(atPath: url.path) else {
                self.profiles.remove(profile)
                return (true, nil)
            }
            
            // -----------------------------------------------------------------
            //  Try to remove item at url
            // -----------------------------------------------------------------
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                    return (true, nil)
                } catch let removeError as NSError {
                    error = removeError
                }
            }
        }
        return (false, error)
    }
    
    private func loadSavedProfiles() {
        
        // ---------------------------------------------------------------------
        //  Get path to profile save folder
        // ---------------------------------------------------------------------
        guard let profileFolderURL = applicationFolder(Folder.profiles) else {
            // TODO: Proper logging
            return
        }
        
        var profileURLs = [URL]()
        
        // ---------------------------------------------------------------------
        //  Put all items from profile folder into array
        // ---------------------------------------------------------------------
        do {
            profileURLs = try FileManager.default.contentsOfDirectory(at: profileFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            print("Function: \(#function), Error: \(error)")
            return
        }
        
        // ---------------------------------------------------------------------
        //  Remove all items that doesn't have the FileExtension.profile extension
        // ---------------------------------------------------------------------
        profileURLs = profileURLs.filter { $0.pathExtension == FileExtension.profile }
        
        // ---------------------------------------------------------------------
        //  Loop through all group files and add them to the group
        // ---------------------------------------------------------------------
        for profileURL in profileURLs {
            do {
                
                // -------------------------------------------------------------
                //  Create the profile from the file at profileURL
                // -------------------------------------------------------------
                let document = try self.makeDocument(withContentsOf: profileURL, ofType: TypeName.profile)
                
                // -------------------------------------------------------------
                //  Check that no other profile exist with the same identifier
                //  This means that only the first profile created with that identifier will exist
                // -------------------------------------------------------------
                guard let profile = document as? Profile, !self.profiles.contains(where: { $0.identifier == profile.identifier }) else {
                    
                    // TODO: Proper logging
                    Swift.print("A Profile with the identifier: xxx already exist!")
                    return
                }
                self.profiles.insert(profile)
                
                // -------------------------------------------------------------
                //  Post notification that a profile was added
                // -------------------------------------------------------------
                NotificationCenter.default.post(name: .didAddProfile, object: self, userInfo: [NotificationKey.identifier : profile.identifier])
            } catch {
                print("Function: \(#function), Error: \(error)")
            }
        }
    }
}