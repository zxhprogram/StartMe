package handler

import (
	"fmt"
	"net/http"
	"server/domain/entity"
	"server/interfaces/http/req"
	"server/usecase"

	"github.com/gin-gonic/gin"
)

type BookmarkHandler struct {
	bookmarkUsecase *usecase.BookmarkUsecase
}

func NewBookmarkHandler(uc *usecase.BookmarkUsecase) *BookmarkHandler {
	return &BookmarkHandler{
		bookmarkUsecase: uc,
	}
}

func (h *BookmarkHandler) GetBookmarks(c *gin.Context) {
	bookmarks, err := h.bookmarkUsecase.GetAllBookmarks()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "failed to get bookmarks",
			"error":   err.Error(),
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
		"data":    bookmarks,
	})
}

func (h *BookmarkHandler) IncreaseBookmarkCount(c *gin.Context) {
	id := c.Param("id")
	var uid uint
	if _, err := fmt.Sscanf(id, "%d", &uid); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "invalid id",
		})
		return
	}
	h.bookmarkUsecase.IncreaseBookmarkCount(uid)
	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
	})
}

func (h *BookmarkHandler) UpdateBookmarkGroup(c *gin.Context) {
	var bookmarkGroupReq req.BookmarkGroupUpdateRequest
	if err := c.ShouldBindJSON(&bookmarkGroupReq); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "invalid request",
			"error":   err.Error(),
		})
		return
	}

	result, err := h.bookmarkUsecase.UpdateBookmarkGroup(&bookmarkGroupReq)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "update failed",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
		"data":    result,
	})
}

func (h *BookmarkHandler) CreateBookmarkGroup(c *gin.Context) {
	var bookmark req.BookmarkRequest
	if err := c.ShouldBindJSON(&bookmark); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "invalid request",
			"error":   err.Error(),
		})
		return
	}

	result, err := h.bookmarkUsecase.CreateBookmarkGroup(bookmark.Name)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "save failed",
			"error":   err.Error(),
		})
		return
	}
	itemResult, err := h.bookmarkUsecase.CreateBookmarkItem(bookmark.Name, bookmark.Url, bookmark.Icon, result.Id)
	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
		"data":    *itemResult,
	})
}

func (h *BookmarkHandler) GetBookmarkByID(c *gin.Context) {
	id := c.Param("id")
	var uid uint
	if _, err := fmt.Sscanf(id, "%d", &uid); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "invalid id",
		})
		return
	}

	bookmark, err := h.bookmarkUsecase.GetBookmarkByID(uid)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"message": "bookmark not found",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
		"data":    bookmark,
	})
}

func (h *BookmarkHandler) UpdateBookmark(c *gin.Context) {
	var bookmark entity.BookmarkGroup
	if err := c.ShouldBindJSON(&bookmark); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "invalid request",
			"error":   err.Error(),
		})
		return
	}

	if err := h.bookmarkUsecase.UpdateBookmark(&bookmark); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "update failed",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
		"data":    bookmark,
	})
}

func (h *BookmarkHandler) DeleteBookmark(c *gin.Context) {
	id := c.Param("id")
	var uid uint
	if _, err := fmt.Sscanf(id, "%d", &uid); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "invalid id",
		})
		return
	}

	if err := h.bookmarkUsecase.DeleteBookmark(uid); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "delete failed",
			"error":   err.Error(),
		})
		return
	}
	if err := h.bookmarkUsecase.DeleteBookmarkItem(uid); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "delete failed",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
	})
}
