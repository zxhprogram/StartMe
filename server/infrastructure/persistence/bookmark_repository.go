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

func (r *BookmarkRepositoryImpl) Create(bookmark *entity.Bookmark) error {
	return r.db.Create(bookmark).Error
}

func (r *BookmarkRepositoryImpl) CreateBookItem(bookmarkItem *entity.BookmarkItem) error {
	return r.db.Create(bookmarkItem).Error
}

func (r *BookmarkRepositoryImpl) FindAll() ([]res.BookmarkResponse, error) {
	//执行sql语句查询结果，对结果处理封装
	var bookmarks []res.BookmarkResponse
	result := r.db.Raw("SELECT b.name as folderName,b.type,i.id,i.name,i.url,i.icon,i.parent_id FROM bookmarks b INNER JOIN bookmark_items i on b.id = i.parent_id where b.type = 'folder'").Scan(&bookmarks)
	if result.Error != nil {
		return nil, result.Error
	}
	var nonFolderBookmarks []res.BookmarkResponse
	newResult := r.db.Raw("SELECT *,'bookmark' type FROM bookmark_items WHERE parent_id = 0").Scan(&nonFolderBookmarks)
	fmt.Println(len(nonFolderBookmarks))
	if newResult.Error != nil {
		return nil, result.Error
	}
	totalResult := append(bookmarks, nonFolderBookmarks...)
	if len(totalResult) == 0 {
		return []res.BookmarkResponse{}, nil
	}
	return totalResult, nil
}

func (r *BookmarkRepositoryImpl) FindByID(id uint) (*entity.Bookmark, error) {
	var bookmark entity.Bookmark
	result := r.db.First(&bookmark, id)
	if result.Error != nil {
		return nil, result.Error
	}
	return &bookmark, nil
}

func (r *BookmarkRepositoryImpl) Update(bookmark *entity.Bookmark) error {
	return r.db.Save(bookmark).Error
}

func (r *BookmarkRepositoryImpl) Delete(id uint) error {
	return r.db.Delete(&entity.Bookmark{}, id).Error
}
