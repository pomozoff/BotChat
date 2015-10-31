//
//  CoreDataSource.m
//  Accounts List
//
//  Created by Anton Pomozov on 23.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "CoreDataSource.h"
#import "ErrorHelper.h"

@interface CoreDataSource () <NSFetchedResultsControllerDelegate>

@property (nonnull, nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CoreDataSource

typedef NS_ENUM(NSUInteger, AccountCoreDataManagerError) {
    ErrorFetchedResultsControllerIsEmpty,
};

static NSString * const kCoreDataManagerErrorDomain = @"CoreDataManagerErrorDomain";

#pragma mark - Properties

@synthesize presenter = _presenter;

#pragma mark - DataSource

- (NSInteger)numberOfSections {
    return (NSInteger)self.fetchedResultsController.sections.count;
}
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (self.fetchedResultsController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:(NSUInteger)section];
        rows = (NSInteger)sectionInfo.numberOfObjects;
    }
    return rows;
}
- (NSString *)titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:(NSUInteger)section];
    return sectionInfo.name;
}
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}
- (NSArray *)sectionIndexTitles {
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark - CoreDataSourceDelegate

- (void)updateFetchedResultsController:(NSFetchedResultsController *)newfrc withCompletion:(CompletionHandler)handler {
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if (newfrc) {
            [self performFetchWithCompletion:handler];
        } else {
            handler(YES, nil);
        }
    }
}
- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.presenter willChangeContent];
}
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    [self.presenter didChangeSectionAtIndex:sectionIndex
                              forChangeType:(TableChangeType)type];
}
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.presenter didChangeObject:anObject
                        atIndexPath:indexPath
                      forChangeType:(TableChangeType)type
                       newIndexPath:newIndexPath];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.presenter didChangeContent];
}

#pragma mark - Private

- (void)performFetchWithCompletion:(_Nonnull CompletionHandler)handler {
    NSError *customError = nil;
    if (self.fetchedResultsController) {
        NSError *error = nil;
        BOOL success = [self.fetchedResultsController performFetch:&error];
        
        if (success) {
            handler(YES, nil);
            [self.presenter reloadData];
        } else {
            NSString *className = NSStringFromClass([self class]);
            NSString *selectorName = NSStringFromSelector(_cmd);
            
            NSString *customErrorText = [NSString stringWithFormat:@"[%@ %@] performFetch: failed.", className, selectorName];
            NSLog(@"%@", customErrorText);
            if (error) {
                customError = [NSError errorWithDomain:kCoreDataManagerErrorDomain code:error.code userInfo:error.userInfo];
                NSLog(@"[%@ %@] %@ (%@)", className, selectorName, error.localizedDescription, error.localizedFailureReason);
            } else {
                customError = [ErrorHelper createErrorWithCode:ErrorFetchedResultsControllerIsEmpty
                                                   description:NSLocalizedString(customErrorText, nil)
                                                    suggestion:NSLocalizedString(@"Nobody knows what to do. Try again later", nil)
                                                       options:@[@"Try Again", @"Cancel"]
                                                   errorDomain:kCoreDataManagerErrorDomain];
            }
            handler(NO, customError);
        }
    } else {
        NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        customError = [ErrorHelper createErrorWithCode:ErrorFetchedResultsControllerIsEmpty
                                           description:NSLocalizedString(@"Fetched result controller is empty.", nil)
                                            suggestion:NSLocalizedString(@"Try to initialize it before use.", nil)
                                               options:@[@"Try Again", @"Cancel"]
                                           errorDomain:kCoreDataManagerErrorDomain];
        handler(NO, customError);
    }
}

@end
