package persistence

import (
	"server/domain/entity"
	"server/domain/repository"

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

func (r *BookmarkRepositoryImpl) FindAll() ([]entity.Bookmark, error) {
	var bookmarks []entity.Bookmark
	result := r.db.Find(&bookmarks)
	return bookmarks, result.Error
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
