package entity

type Bookmark struct {
	Id   uint `gorm:"primaryKey"`
	Name string
	Type string
}

type BookmarkItem struct {
	Id       uint   `json:"id" gorm:"primaryKey"`
	Name     string `json:"name"`
	Url      string `json:"url"`
	Icon     string `json:"icon"`
	ParentId uint   `json:"parent_id"`
}
