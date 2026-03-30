package entity

type Bookmark struct {
	Id   uint `gorm:"primaryKey"`
	Name string
	Type string
}

type BookmarkItem struct {
	Id       uint `gorm:"primaryKey"`
	Name     string
	Url      string
	Icon     string
	ParentId uint
}
