package repository

import (
	"server/domain/entity"
	"server/interfaces/http/res"
)

type BookmarkRepository interface {
	Create(bookmark *entity.BookmarkGroup) error
	CreateBookItem(bookmarkItem *entity.BookmarkItem) error
	FindAll() ([]res.BookmarkGroupResponse, error)
	FindByID(id uint) (*entity.BookmarkGroup, error)
	FindByBookItemId(id uint) (*entity.BookmarkItem, error)
	Update(bookmark *entity.BookmarkGroup) error
	UpdateBookItem(bookmarkItem *entity.BookmarkItem) error
	Delete(id uint) error
	SaveOrUpdate(bookmark *entity.BookmarkGroup) error
	SaveOrUpdateBookItem(bookmarkItem *entity.BookmarkItem) error
	DeleteBookItem(id uint) error
	DeleteBookmarkItemByGroupId(groupId uint) error
}
