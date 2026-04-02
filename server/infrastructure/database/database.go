package database

import (
	"server/domain/entity"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func InitDB() (*gorm.DB, error) {
	var err error
	DB, err = gorm.Open(sqlite.Open("bookmarks.db"), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	if err := DB.AutoMigrate(&entity.BookmarkGroup{}, &entity.BookmarkItem{}); err != nil {
		return nil, err
	}

	return DB, nil
}
