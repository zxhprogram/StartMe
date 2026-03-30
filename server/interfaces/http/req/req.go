package req

type BookmarkRequest struct {
	Type     string            `json:"type"`
	Name     string            `json:"name"`
	Url      string            `json:"url"`
	Icon     string            `json:"icon"`
	Children []BookmarkRequest `json:"children"`
}
