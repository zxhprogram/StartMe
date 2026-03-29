package entity

type Bookmark struct {
	Id   uint   `json:"id" gorm:"primaryKey"`
	Name string `json:"name"`
	Url  string `json:"url"`
	Icon string `json:"icon"`
}
