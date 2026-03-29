package repository

import "server/domain/entity"

type BookmarkRepository interface {
	Create(bookmark *entity.Bookmark) error
	FindAll() ([]entity.Bookmark, error)
	FindByID(id uint) (*entity.Bookmark, error)
	Update(bookmark *entity.Bookmark) error
	Delete(id uint) error
}
