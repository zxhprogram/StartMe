package repository

import (
	"server/domain/entity"
	"server/interfaces/http/res"
)

type BookmarkRepository interface {
	Create(bookmark *entity.Bookmark) error
	CreateBookItem(bookmarkItem *entity.BookmarkItem) error
	FindAll() ([]res.BookmarkResponse, error)
	FindByID(id uint) (*entity.Bookmark, error)
	Update(bookmark *entity.Bookmark) error
	Delete(id uint) error
}
