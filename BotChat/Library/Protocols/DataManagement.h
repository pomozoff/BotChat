//
//  DataManagement.h
//  Accounts List
//
//  Created by Anton Pomozov on 22.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#ifndef DataManagement_h
#define DataManagement_h

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TableChangeInsert = 1,
    TableChangeDelete = 2,
    TableChangeMove   = 3,
    TableChangeUpdate = 4
} TableChangeType;

@protocol TableDataSource <NSObject>

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
- (NSArray *)sectionIndexTitles;

@end

@protocol DataPresenter <NSObject>

@property (nonatomic, strong) NSBlockOperation *updateOperation;

- (void)reloadData;
- (void)reloadDataInSections:(NSIndexSet *)indexSet;
- (void)willChangeContent;
- (void)didChangeSectionAtIndex:(NSUInteger)sectionIndex
                  forChangeType:(TableChangeType)type;
- (void)didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(TableChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath;
- (void)didChangeContent;

@end

@protocol DataPresenterDelegate <NSObject>

@property (nonatomic, strong) id <DataPresenter> presenter;

@end

@protocol TableDataSourceDelegate <NSObject>

@property (strong, nonatomic) id <TableDataSource, DataPresenterDelegate> tableDataSource;

@end

NS_ASSUME_NONNULL_END

#endif /* DataManagement_h */
