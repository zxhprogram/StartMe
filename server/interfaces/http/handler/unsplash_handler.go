package handler

import (
	"net/http"
	"server/usecase"
	"strconv"

	"github.com/gin-gonic/gin"
)

type UnsplashHandler struct {
	unsplashUsecase *usecase.UnsplashUsecase
}

func NewUnsplashHandler(uc *usecase.UnsplashUsecase) *UnsplashHandler {
	return &UnsplashHandler{
		unsplashUsecase: uc,
	}
}

// GetDailyPhoto returns the daily recommended photo from Unsplash
// GET /unsplash/daily
func (h *UnsplashHandler) GetDailyPhoto(c *gin.Context) {
	photo, err := h.unsplashUsecase.GetDailyPhoto()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "failed to fetch daily photo",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "success",
		"data":    photo,
	})
}

// GetRandomPhotos returns random photos from Unsplash
// GET /unsplash/random?count=10
func (h *UnsplashHandler) GetRandomPhotos(c *gin.Context) {
	countStr := c.DefaultQuery("count", "10")
	count, err := strconv.Atoi(countStr)
	if err != nil || count < 1 || count > 30 {
		count = 10
	}

	photos, err := h.unsplashUsecase.GetRandomPhotos(count)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "failed to fetch random photos",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "success",
		"data":    photos,
	})
}

// SearchPhotos searches for photos on Unsplash
// GET /unsplash/search?query=nature&page=1&per_page=10
func (h *UnsplashHandler) SearchPhotos(c *gin.Context) {
	query := c.Query("query")
	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "query parameter is required",
		})
		return
	}

	pageStr := c.DefaultQuery("page", "1")
	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}

	perPageStr := c.DefaultQuery("per_page", "10")
	perPage, err := strconv.Atoi(perPageStr)
	if err != nil || perPage < 1 || perPage > 30 {
		perPage = 10
	}

	photos, total, err := h.unsplashUsecase.SearchPhotos(query, page, perPage)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "failed to search photos",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "success",
		"data":    photos,
		"total":   total,
		"page":    page,
		"per_page": perPage,
	})
}
