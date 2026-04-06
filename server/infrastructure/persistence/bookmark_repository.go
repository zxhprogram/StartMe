package persistence

import (
	"fmt"
	"server/domain/entity"
	"server/domain/repository"
	"server/interfaces/http/res"

	"gorm.io/gorm"
)

type BookmarkRepositoryImpl struct {
	db *gorm.DB
}

func NewBookmarkRepository(db *gorm.DB) repository.BookmarkRepository {
	return &BookmarkRepositoryImpl{db: db}
}

func (r *BookmarkRepositoryImpl) DeleteBookmarkItemByGroupId(groupId uint) error {
	return r.db.Delete(&entity.BookmarkItem{}, "group_id = ?", groupId).Error
}

func (r *BookmarkRepositoryImpl) Create(bookmark *entity.BookmarkGroup) error {
	return r.db.Create(bookmark).Error
}

func (r *BookmarkRepositoryImpl) DeleteBookItem(id uint) error {
	return r.db.Delete(&entity.BookmarkItem{}, id).Error
}

func (r *BookmarkRepositoryImpl) CreateBookItem(bookmarkItem *entity.BookmarkItem) error {
	return r.db.Create(bookmarkItem).Error
}

func (r *BookmarkRepositoryImpl) FindByBookItemId(id uint) (*entity.BookmarkItem, error) {
	var bookmarkItem entity.BookmarkItem
	result := r.db.First(&bookmarkItem, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &bookmarkItem, nil
}

func (r *BookmarkRepositoryImpl) UpdateBookItem(bookmarkItem *entity.BookmarkItem) error {
	return r.db.Save(bookmarkItem).Error
}

func (r *BookmarkRepositoryImpl) FindAll() ([]res.BookmarkGroupResponse, error) {

	var bookmarkgroupList []entity.BookmarkGroup
	result := r.db.Find(&bookmarkgroupList)
	if result.Error != nil {
		return nil, result.Error
	}

	if result.RowsAffected == 0 {
		return []res.BookmarkGroupResponse{}, nil
	}
	var bookmarks []res.BookmarkGroupResponse
	for _, bookmarkgroup := range bookmarkgroupList {
		bookmarks = append(bookmarks, res.BookmarkGroupResponse{
			Id:   bookmarkgroup.Id,
			Name: bookmarkgroup.Name,
		})
	}

	for i := range bookmarks {
		var bookmarkitemList []entity.BookmarkItem
		result := r.db.Where("group_id = ?", bookmarks[i].Id).Find(&bookmarkitemList)

		if result.Error != nil {
			return nil, result.Error
		}
		for _, bookmarkitem := range bookmarkitemList {
			bookmarks[i].BookmarkList = append(bookmarks[i].BookmarkList, res.BookmarkItemResponse{
				Id:         bookmarkitem.Id,
				Name:       bookmarkitem.Name,
				Url:        bookmarkitem.Url,
				Icon:       bookmarkitem.Icon,
				GroupId:    bookmarks[i].Id,
				VisitCount: bookmarkitem.VisitCount,
			})
			fmt.Println(bookmarks[i])
		}
	}

	fmt.Println(bookmarks)
	return bookmarks, nil
}

func (r *BookmarkRepositoryImpl) FindBookmarkItemByID(id uint) (*entity.BookmarkItem, error) {
	var bookmarkItem entity.BookmarkItem
	result := r.db.First(&bookmarkItem, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &bookmarkItem, nil
}

func (r *BookmarkRepositoryImpl) FindByID(id uint) (*entity.BookmarkGroup, error) {
	var bookmark entity.BookmarkGroup
	result := r.db.First(&bookmark, id)
	if result.Error != nil {
		return nil, result.Error
	}
	if result.RowsAffected == 0 {
		return nil, nil
	}
	return &bookmark, nil
}

func (r *BookmarkRepositoryImpl) Update(bookmark *entity.BookmarkGroup) error {
	return r.db.Save(bookmark).Error
}

func (r *BookmarkRepositoryImpl) Delete(id uint) error {
	return r.db.Delete(&entity.BookmarkGroup{}, id).Error
}

func (r *BookmarkRepositoryImpl) SaveOrUpdate(bookmark *entity.BookmarkGroup) error {
	return r.db.Save(bookmark).Error
}

func (r *BookmarkRepositoryImpl) SaveOrUpdateBookItem(bookmarkItem *entity.BookmarkItem) error {
	return r.db.Save(bookmarkItem).Error
}
