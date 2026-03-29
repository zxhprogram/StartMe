package handler

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"server/domain/entity"
	"server/usecase"

	"github.com/gin-gonic/gin"
)

type URLInfoHandler struct {
	urlInfoUsecase *usecase.URLInfoUsecase
}

func NewURLInfoHandler(uc *usecase.URLInfoUsecase) *URLInfoHandler {
	return &URLInfoHandler{
		urlInfoUsecase: uc,
	}
}

func (h *URLInfoHandler) GetURLInfo(c *gin.Context) {
	s, _ := io.ReadAll(c.Request.Body)
	fmt.Println(string(s))
	var info entity.UrlInfo
	json.Unmarshal(s, &info)
	fmt.Println(info.Url)

	metadata, err := h.urlInfoUsecase.FetchURLMetadata(info.Url)
	if err != nil {
		fmt.Printf("request error: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "request failed",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "ok",
		"data":    metadata,
	})
}
