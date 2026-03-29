package entity

type UrlInfo struct {
	Url string `json:"url"`
}

type UrlMetadata struct {
	Url     string `json:"url"`
	Title   string `json:"title"`
	Favicon string `json:"favicon"`
}
