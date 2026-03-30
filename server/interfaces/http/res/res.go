package res

type BookmarkResponse struct {
	Id         uint   `json:"id" gorm:"id"`
	FolderName string `json:"folderName" gorm:"folder_name"`
	Name       string `json:"name" gorm:"name"`
	Url        string `json:"url" gorm:"url"`
	Icon       string `json:"icon" gorm:"icon"`
	ParentId   uint   `json:"parentId" gorm:"parent_id"`
	Type       string `json:"type" gorm:"type"`
}
