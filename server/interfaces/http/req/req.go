package req

type BookmarkRequest struct {
	Id   uint   `json:"id"`
	Name string `json:"name"`
	Url  string `json:"url"`
	Icon string `json:"icon"`
}

type BookmarkGroupUpdateRequest struct {
	Id    uint                             `json:"id"`
	Name  string                           `json:"name"`
	Items []BookmarkGroupUpdateItemRequest `json:"items"`
}

type BookmarkGroupUpdateItemRequest struct {
	Id   uint   `json:"id"`
	Name string `json:"name"`
	Url  string `json:"url"`
	Icon string `json:"icon"`
}
