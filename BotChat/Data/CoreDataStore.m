//
//  CoreDataStore.m
//  Accounts List
//
//  Created by Anton Pomozov on 18.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "CoreDataStore.h"
#import "ErrorHelper.h"

typedef NS_ENUM(NSUInteger, CoreDataStoreError) {
    ErrorModelURLNotCreated,
    ErrorManagedObjectModelNotCreated,
    ErrorPersistentStoreCoordinatorNotCreated
};

@interface CoreDataStore()

@property (nonnull, nonatomic, strong) NSManagedObjectContext *writerManagedObjectContext;
@property (nonnull, nonatomic, strong, readwrite) NSManagedObjectContext *mainQueueManagedObjectContext;
@property (nonnull, nonatomic, strong) NSString *modelName;

@end

@implementation CoreDataStore

static NSString * const kDataBaseManagerFileName = @"DataModel";
static NSString * const kDataBaseManagerErrorDomain = @"CoreDataStoreErrorDomain";

#pragma mark - Properties

- (NSManagedObjectContext *)writerManagedObjectContext {
    if (!_writerManagedObjectContext) {
        _writerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    }
    return _writerManagedObjectContext;
}
- (NSManagedObjectContext *)mainQueueManagedObjectContext {
    if (!_mainQueueManagedObjectContext) {
        _mainQueueManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    return _mainQueueManagedObjectContext;
}

#pragma mark - Initialization

- (instancetype)initWithModelName:(NSString *)modelName {
    if (self = [super init]) {
        _modelName = modelName;
    }
    return self;
}
- (instancetype)init {
    return [self initWithModelName:kDataBaseManagerFileName];
}

#pragma mark - Setup Core Data stack

- (void)setupWithCompletion:(CompletionHandler)handler {
    if (_writerManagedObjectContext) {
        return;
    }
    
    NSError *pscError = nil;
    NSPersistentStoreCoordinator *psc = [self setupPersistenceStoreCoordinatorWithError:&pscError];
    if (!psc) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO, pscError);
            });
        }
        return;
    }
    
    self.writerManagedObjectContext.persistentStoreCoordinator = psc;
    self.mainQueueManagedObjectContext.parentContext = self.writerManagedObjectContext;
    
    CoreDataStore *strongSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSError *urlError = nil;
        NSURL *storeSqliteURL = [strongSelf setupStoreSqliteURLWithError:&urlError];
        
        if (!storeSqliteURL) {
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(NO, urlError);
                });
            }
            return;
        }
        
        NSError *storeError = nil;
        NSPersistentStore *store = [strongSelf setupPersistentStoreToPersistentStoreCoordinator:psc andStoreSqliteURL:storeSqliteURL error:&storeError];
        
        BOOL isStoreCreated = store != nil;
        NSError *customError = nil;
        
        if (!isStoreCreated) {
            if (storeError) {
                customError = [NSError errorWithDomain:kDataBaseManagerErrorDomain code:storeError.code userInfo:storeError.userInfo];
            }
        }
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(isStoreCreated, customError);
            });
        }
    });
}
- (void)saveDataWithCompletion:(CompletionHandler)handler {
    // Always start from the main thread
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf saveDataWithCompletion:handler];
        });
        return;
    }
    
    // Don't work if you don't need to (you can talk to these without performBlock)
    if (!self.mainQueueManagedObjectContext.hasChanges && !self.writerManagedObjectContext.hasChanges) {
        if (handler) {
            handler(YES, nil);
        }
        return;
    }
    
    if (self.mainQueueManagedObjectContext.hasChanges) {
        NSError *mainThreadSaveError = nil;
        if (![self.mainQueueManagedObjectContext save:&mainThreadSaveError]) {
            if (handler) {
                handler(NO, mainThreadSaveError);
            }
            return; // fail early and often
        }
    }
    
    [self.writerManagedObjectContext performBlock:^{ // Private context must be on it's own queue
        NSError *saveError = nil;
        BOOL isSaved = [self.writerManagedObjectContext save:&saveError];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(isSaved, saveError);
            });
        }
    }];
}

#pragma mark - Private

- (NSPersistentStoreCoordinator *)setupPersistenceStoreCoordinatorWithError:(NSError **)error {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    if (!modelURL) {
        if (*error) {
            *error = [ErrorHelper createErrorWithCode:ErrorManagedObjectModelNotCreated
                                          description:NSLocalizedString(@"The Model URL could not be found during setup.", nil)
                                           suggestion:NSLocalizedString(@"Do you want to try setting up the stack again?", nil)
                                              options:@[@"Try Again", @"Cancel"]
                                          errorDomain:kDataBaseManagerErrorDomain];
        }
        return nil;
    }
    
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if (!mom) {
        if (*error) {
            *error = [ErrorHelper createErrorWithCode:ErrorManagedObjectModelNotCreated
                                          description:NSLocalizedString(@"The Managed Object Model could not be found during setup.", nil)
                                           suggestion:NSLocalizedString(@"Do you want to try setting up the stack again?", nil)
                                              options:@[@"Try Again", @"Cancel"]
                                          errorDomain:kDataBaseManagerErrorDomain];
        }
        return nil;
    }
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (!psc) {
        if (*error) {
            *error = [ErrorHelper createErrorWithCode:ErrorPersistentStoreCoordinatorNotCreated
                                          description:NSLocalizedString(@"The Persistent Store Coordinator could not be found during setup.", nil)
                                           suggestion:NSLocalizedString(@"Do you want to try setting up the stack again?", nil)
                                              options:@[@"Try Again", @"Cancel"]
                                          errorDomain:kDataBaseManagerErrorDomain];
        }
        return nil;
    }
    return psc;
}
- (NSURL *)setupStoreSqliteURLWithError:(NSError **)error {
    NSArray *directoryArray = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *storeURL = [directoryArray lastObject];
    NSError *currentError = nil;
    
    if (![[NSFileManager defaultManager] createDirectoryAtURL:storeURL withIntermediateDirectories:YES attributes:nil error:&currentError]) {
        if (currentError) {
            *error = [NSError errorWithDomain:kDataBaseManagerErrorDomain code:currentError.code userInfo:currentError.userInfo];
        }
        return nil;
    }
    NSURL *storeSqliteURL = [[storeURL URLByAppendingPathComponent:self.modelName] URLByAppendingPathExtension:@"sqlite"];
    return storeSqliteURL;
}
- (BOOL)checkIsMigrationNeededForPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)psc
                                             storeSqliteURL:(NSURL *)storeSqliteURL
                                                    options:(NSDictionary *)options
                                                  withError:(NSError **)error {
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeSqliteURL
                                                                                          options:options
                                                                                            error:error];
    NSManagedObjectModel *destinationModel = psc.managedObjectModel;
    BOOL isModelCompatible = (sourceMetadata == nil) || [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
    return isModelCompatible;
}
- (NSPersistentStore *)setupPersistentStoreToPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)psc
                                                      andStoreSqliteURL:(NSURL *)storeSqliteURL
                                                                  error:(NSError **)error {
    NSDictionary *optionsDefault = @{ NSMigratePersistentStoresAutomaticallyOption:@YES,
                                      NSInferMappingModelAutomaticallyOption:@YES,
                                      NSSQLitePragmasOption: @{@"journal_mode": @"WAL"},
                                      };
    NSDictionary *optionsMigration = @{ NSMigratePersistentStoresAutomaticallyOption:@YES,
                                        NSInferMappingModelAutomaticallyOption:@YES,
                                        NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"},
                                        };

    NSError *migrationError = nil;
    BOOL isModelCompatible = [self checkIsMigrationNeededForPersistentStoreCoordinator:psc
                                                                        storeSqliteURL:storeSqliteURL
                                                                               options:optionsDefault
                                                                             withError:&migrationError];
    NSDictionary *options = isModelCompatible ? optionsDefault : optionsMigration;
    
    NSPersistentStore *persistentStore = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                           configuration:nil
                                                                     URL:storeSqliteURL
                                                                 options:options
                                                                   error:error];
    if (!persistentStore) {
        return nil;
    }
    if (!isModelCompatible) {
        if (![psc removePersistentStore:persistentStore error:error]) {
            return nil;
        }
        persistentStore = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                            configuration:nil
                                                      URL:storeSqliteURL
                                                  options:optionsDefault
                                                    error:error];
        if (persistentStore) {
            NSLog(@"Migrated successfully");
        }
    }
    return persistentStore;
}

@end
