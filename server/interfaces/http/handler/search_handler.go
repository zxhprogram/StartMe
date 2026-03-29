package handler

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

type SearchHandler struct{}

func NewSearchHandler() *SearchHandler {
	return &SearchHandler{}
}

func (h *SearchHandler) Search(c *gin.Context) {
	var h1 = c.Request.Header
	fmt.Println(h1)
	keyword := c.Param("keyword")
	var list = []string{}
	for i := 0; i < 10; i++ {
		list = append(list, keyword+fmt.Sprintf("%d", i))
	}
	c.JSON(http.StatusOK, gin.H{
		"message": "search",
		"data":    list,
	})
}
