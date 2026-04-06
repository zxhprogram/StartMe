package entity

// bookmark is the entity for folder of bookmark , one to many relationship with bookmark item
type BookmarkGroup struct {
	Id   uint `gorm:"primaryKey"`
	Name string
}

// bookmark item is the entity for real bookmark, it has a foreign key to bookmark
type BookmarkItem struct {
	Id         uint   `json:"id" gorm:"primaryKey"`
	Name       string `json:"name"`
	Url        string `json:"url"`
	Icon       string `json:"icon"`
	GroupId    uint   `json:"groupId" gorm:"column:group_id"`
	VisitCount uint   `json:"visitCount" gorm:"default:0"`
}
