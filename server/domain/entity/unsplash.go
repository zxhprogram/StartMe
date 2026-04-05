package entity

// UnsplashPhoto represents a photo from Unsplash API
type UnsplashPhoto struct {
	ID             string           `json:"id"`
	CreatedAt      string           `json:"created_at"`
	UpdatedAt      string           `json:"updated_at"`
	Width          int              `json:"width"`
	Height         int              `json:"height"`
	Color          string           `json:"color"`
	BlurHash       string           `json:"blur_hash"`
	Description    string           `json:"description"`
	AltDescription string           `json:"alt_description"`
	Urls           UnsplashPhotoUrls `json:"urls"`
	Links          UnsplashPhotoLinks `json:"links"`
	Likes          int              `json:"likes"`
	LikedByUser    bool             `json:"liked_by_user"`
	User           UnsplashUser     `json:"user"`
}

// UnsplashPhotoUrls contains URLs for different sizes of the photo
type UnsplashPhotoUrls struct {
	Raw     string `json:"raw"`
	Full    string `json:"full"`
	Regular string `json:"regular"`
	Small   string `json:"small"`
	Thumb   string `json:"thumb"`
}

// UnsplashPhotoLinks contains links related to the photo
type UnsplashPhotoLinks struct {
	Self             string `json:"self"`
	HTML             string `json:"html"`
	Download         string `json:"download"`
	DownloadLocation string `json:"download_location"`
}

// UnsplashUser represents the user who uploaded the photo
type UnsplashUser struct {
	ID                 string            `json:"id"`
	UpdatedAt          string            `json:"updated_at"`
	Username           string            `json:"username"`
	Name               string            `json:"name"`
	FirstName          string            `json:"first_name"`
	LastName           string            `json:"last_name"`
	TwitterUsername    string            `json:"twitter_username"`
	PortfolioURL       string            `json:"portfolio_url"`
	Bio                string            `json:"bio"`
	Location           string            `json:"location"`
	Links              UnsplashUserLinks `json:"links"`
	ProfileImage       UnsplashProfileImage `json:"profile_image"`
	InstagramUsername  string            `json:"instagram_username"`
	TotalCollections   int               `json:"total_collections"`
	TotalLikes         int               `json:"total_likes"`
	TotalPhotos        int               `json:"total_photos"`
	AcceptedTos        bool              `json:"accepted_tos"`
	ForHire            bool              `json:"for_hire"`
	Social             UnsplashSocial    `json:"social"`
}

// UnsplashUserLinks contains links related to the user
type UnsplashUserLinks struct {
	Self      string `json:"self"`
	HTML      string `json:"html"`
	Photos    string `json:"photos"`
	Likes     string `json:"likes"`
	Portfolio string `json:"portfolio"`
	Following string `json:"following"`
	Followers string `json:"followers"`
}

// UnsplashProfileImage contains URLs for the user's profile images
type UnsplashProfileImage struct {
	Small  string `json:"small"`
	Medium string `json:"medium"`
	Large  string `json:"large"`
}

// UnsplashSocial contains social media information
type UnsplashSocial struct {
	InstagramUsername string `json:"instagram_username"`
	PortfolioURL      string `json:"portfolio_url"`
	TwitterUsername   string `json:"twitter_username"`
	PaypalEmail       string `json:"paypal_email"`
}

// UnsplashDailyPhoto represents the simplified daily photo response
type UnsplashDailyPhoto struct {
	ID          string `json:"id"`
	Description string `json:"description"`
	AltDescription string `json:"alt_description"`
	URL         string `json:"url"`
	ThumbURL    string `json:"thumb_url"`
	Author      string `json:"author"`
	AuthorURL   string `json:"author_url"`
	Width       int    `json:"width"`
	Height      int    `json:"height"`
}
