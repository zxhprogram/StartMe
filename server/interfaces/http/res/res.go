package res

// type BookmarkResponse struct {
// 	Id         uint   `json:"id" gorm:"id"`
// 	FolderId   uint   `json:"folderId" gorm:"folder_id"`
// 	FolderName string `json:"folderName" gorm:"folder_name"`
// 	Name       string `json:"name" gorm:"name"`
// 	Url        string `json:"url" gorm:"url"`
// 	Icon       string `json:"icon" gorm:"icon"`
// 	ParentId   uint   `json:"parentId" gorm:"parent_id"`
// }

type BookmarkGroupResponse struct {
	Id           uint                   `json:"groupId"`
	Name         string                 `json:"groupName"`
	BookmarkList []BookmarkItemResponse `json:"bookmarkList" gorm:"-"`
}

type BookmarkItemResponse struct {
	Id      uint   `json:"bookmarkId"`
	Name    string `json:"bookmarkName"`
	Url     string `json:"url"`
	Icon    string `json:"icon"`
	GroupId uint   `json:"groupId"`
}
