//
//  STGCreateAlbumWindowController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 16.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol STGCreateAlbumWindowControllerDelegate <NSObject>

- (void)createAlbumWithIDs:(NSArray *)entryIDs;

@end

@interface STGCreateAlbumWindowController : NSWindowController <NSTokenFieldDelegate>

@property (nonatomic, assign) NSObject<STGCreateAlbumWindowControllerDelegate> *delegate;

@property (nonatomic, retain) NSArray *uploadIDList;

@property (nonatomic, retain) IBOutlet NSTokenField *tokenField;

- (IBAction)createAlbum:(id)sender;

@end
