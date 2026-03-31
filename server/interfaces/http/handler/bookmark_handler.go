package handler

import (
	"fmt"
	"net/http"
	"server/domain/entity"
	"server/interfaces/http/req"
	"server/interfaces/http/res"
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

type B struct {
	Id         uint                   `json:"id"`
	FolderName string                 `json:"folderName"`
	Name       string                 `json:"name"`
	Url        string                 `json:"url"`
	Icon       string                 `json:"icon"`
	ParentId   uint                   `json:"parentId"`
	Type       string                 `json:"type"`
	Children   []res.BookmarkResponse `json:"children"`
}

func (h *BookmarkHandler) GetBookmarks(c *gin.Context) {
	bookmarks, err := h.bookmarkUsecase.GetAllBookmarks()
	var m = make(map[uint][]res.BookmarkResponse)
	var nonFolderBookmarks []res.BookmarkResponse
	for _, item := range bookmarks {
		if item.ParentId == 0 {
			nonFolderBookmarks = append(nonFolderBookmarks, item)
		} else {
			if m[item.ParentId] == nil {
				m[item.ParentId] = []res.BookmarkResponse{}
			}
			m[item.ParentId] = append(m[item.ParentId], item)
		}
	}
	var rrrr []B
	for _, v := range m {
		if len(v) == 1 {
			rrrr = append(rrrr, B{
				Id:         v[0].Id,
				FolderName: "",
				Name:       v[0].Name,
				Url:        v[0].Url,
				Icon:       v[0].Icon,
				ParentId:   0,
				Type:       "bookmark",
			})
		}
		if len(v) > 1 {
			var bb = B{
				FolderName: v[0].FolderName,
				ParentId:   v[0].ParentId,
				Children:   []res.BookmarkResponse{},
			}
			for _, _vv := range v {
				bb.Children = append(bb.Children, _vv)
			}
			rrrr = append(rrrr, bb)
		}
	}
	for _, item := range nonFolderBookmarks {
		rrrr = append(rrrr, B{
			Id:         item.Id,
			FolderName: "",
			Name:       item.Name,
			Url:        item.Url,
			Icon:       item.Icon,
			ParentId:   0,
			Type:       "bookmark",
		})
	}
	fmt.Println(m)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "failed to get bookmarks",
			"error":   err.Error(),
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
		"data":    rrrr,
	})
}

func (h *BookmarkHandler) CreateBookmark(c *gin.Context) {
	var bookmark req.BookmarkRequest
	if err := c.ShouldBindJSON(&bookmark); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "invalid request",
			"error":   err.Error(),
		})
		return
	}
	if bookmark.Type == "" || bookmark.Type == "bookmark" {
		bookmark.Type = "bookmark"
		_, err := h.bookmarkUsecase.CreateBookmark(bookmark.Name, bookmark.Type)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"message": "save failed",
				"error":   err.Error(),
			})
			return
		}
		itemResult, err := h.bookmarkUsecase.CreateBookmarkItem(bookmark.Name, bookmark.Url, bookmark.Icon, 0)
		c.JSON(http.StatusOK, gin.H{
			"message": "ok",
			"data":    *itemResult,
		})
		return
	}
	if bookmark.Type == "folder" {
		result, err := h.bookmarkUsecase.CreateBookmark(bookmark.Name, bookmark.Type)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"message": "save failed",
				"error":   err.Error(),
			})
			return
		}
		var itemResultList []entity.BookmarkItem
		for _, item := range bookmark.Children {
			itemResult, err := h.bookmarkUsecase.CreateBookmarkItem(item.Name, item.Url, item.Icon, result.Id)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"message": "save failed",
					"error":   err.Error(),
				})
				return
			}
			itemResultList = append(itemResultList, *itemResult)
		}
		c.JSON(http.StatusOK, gin.H{
			"message": "ok",
			"data":    itemResultList,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "fail,unrecognize bookmark type",
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
	var bookmark entity.Bookmark
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

	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
	})
}
