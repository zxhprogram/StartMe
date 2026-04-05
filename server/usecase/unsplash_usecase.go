package usecase

import (
	"encoding/json"
	"fmt"
	"io"
	"server/domain/entity"

	"resty.dev/v3"
)

const (
	unsplashAPIBaseURL = "https://api.unsplash.com"
	accessKey          = "7rp0yM287esg4ZXhiRcfztuYOqOG1aU7hsJfzdQMV60"
	secretKey          = "ykpcuSWgEMUsFLzmEPkTgyY_oaQoYdTC0T8KTpFPa3I"
)

type UnsplashUsecase struct {
	httpClient *resty.Client
}

func NewUnsplashUsecase() *UnsplashUsecase {
	return &UnsplashUsecase{
		httpClient: resty.New(),
	}
}

func (u *UnsplashUsecase) Close() {
	if u.httpClient != nil {
		u.httpClient.Close()
	}
}

// GetDailyPhoto gets the daily recommended photo from Unsplash
// It uses the /photos/random endpoint with a daily seed to get consistent results throughout the day
func (u *UnsplashUsecase) GetDailyPhoto() (*entity.UnsplashDailyPhoto, error) {
	resp, err := u.httpClient.R().
		SetQueryParams(map[string]string{
			"client_id":   accessKey,
			"count":       "1",
			"featured":    "true",
			"orientation": "landscape",
		}).
		SetHeader("Accept-Version", "v1").
		Get(fmt.Sprintf("%s/photos/random", unsplashAPIBaseURL))

	if err != nil {
		return nil, fmt.Errorf("failed to fetch daily photo: %w", err)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	// Unsplash returns an array for /photos/random with count parameter
	var photos []entity.UnsplashPhoto
	if err := json.Unmarshal(body, &photos); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	if len(photos) == 0 {
		return nil, fmt.Errorf("no photos returned from Unsplash")
	}

	photo := photos[0]

	// Return simplified photo data
	return &entity.UnsplashDailyPhoto{
		ID:             photo.ID,
		Description:    photo.Description,
		AltDescription: photo.AltDescription,
		URL:            photo.Urls.Regular,
		ThumbURL:       photo.Urls.Thumb,
		Author:         photo.User.Name,
		AuthorURL:      photo.User.Links.HTML,
		Width:          photo.Width,
		Height:         photo.Height,
	}, nil
}

// GetRandomPhotos gets multiple random photos from Unsplash
func (u *UnsplashUsecase) GetRandomPhotos(count int) ([]*entity.UnsplashDailyPhoto, error) {
	if count < 1 || count > 30 {
		count = 10 // Default to 10, max allowed by Unsplash API is 30
	}

	resp, err := u.httpClient.R().
		SetQueryParams(map[string]string{
			"client_id":   accessKey,
			"count":       fmt.Sprintf("%d", count),
			"orientation": "landscape",
		}).
		SetHeader("Accept-Version", "v1").
		Get(fmt.Sprintf("%s/photos/random", unsplashAPIBaseURL))

	if err != nil {
		return nil, fmt.Errorf("failed to fetch random photos: %w", err)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	var photos []entity.UnsplashPhoto
	if err := json.Unmarshal(body, &photos); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	result := make([]*entity.UnsplashDailyPhoto, len(photos))
	for i, photo := range photos {
		result[i] = &entity.UnsplashDailyPhoto{
			ID:             photo.ID,
			Description:    photo.Description,
			AltDescription: photo.AltDescription,
			URL:            photo.Urls.Regular,
			ThumbURL:       photo.Urls.Thumb,
			Author:         photo.User.Name,
			AuthorURL:      photo.User.Links.HTML,
			Width:          photo.Width,
			Height:         photo.Height,
		}
	}

	return result, nil
}

// SearchPhotos searches for photos on Unsplash
func (u *UnsplashUsecase) SearchPhotos(query string, page, perPage int) ([]*entity.UnsplashDailyPhoto, int, error) {
	if page < 1 {
		page = 1
	}
	if perPage < 1 || perPage > 30 {
		perPage = 10
	}

	resp, err := u.httpClient.R().
		SetQueryParams(map[string]string{
			"client_id":   accessKey,
			"query":       query,
			"page":        fmt.Sprintf("%d", page),
			"per_page":    fmt.Sprintf("%d", perPage),
			"orientation": "landscape",
		}).
		SetHeader("Accept-Version", "v1").
		Get(fmt.Sprintf("%s/search/photos", unsplashAPIBaseURL))

	if err != nil {
		return nil, 0, fmt.Errorf("failed to search photos: %w", err)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to read response body: %w", err)
	}

	var searchResult struct {
		Total      int                    `json:"total"`
		TotalPages int                    `json:"total_pages"`
		Results    []entity.UnsplashPhoto `json:"results"`
	}
	if err := json.Unmarshal(body, &searchResult); err != nil {
		return nil, 0, fmt.Errorf("failed to parse response: %w", err)
	}

	result := make([]*entity.UnsplashDailyPhoto, len(searchResult.Results))
	for i, photo := range searchResult.Results {
		result[i] = &entity.UnsplashDailyPhoto{
			ID:             photo.ID,
			Description:    photo.Description,
			AltDescription: photo.AltDescription,
			URL:            photo.Urls.Regular,
			ThumbURL:       photo.Urls.Thumb,
			Author:         photo.User.Name,
			AuthorURL:      photo.User.Links.HTML,
			Width:          photo.Width,
			Height:         photo.Height,
		}
	}

	return result, searchResult.Total, nil
}
