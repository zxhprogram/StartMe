package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
)

func main() {
	fmt.Println("333")
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	r.GET("/search/:keyword", func(c *gin.Context) {
		keyword := c.Param("keyword")
		var list = []string{}
		for i := 0; i < 10; i++ {
			list = append(list, keyword+fmt.Sprintf("%d", i))
		}
		c.JSON(200, gin.H{
			"message": "search",
			"data":    list,
		})
	})
	r.GET("/bookmark/list", func(ctx *gin.Context) {
		var bookmarks []Bookmark
		for i := 0; i < 10; i++ {
			bookmarks = append(bookmarks, Bookmark{
				Id:   i,
				Name: fmt.Sprintf("bookMark%d", i),
				Url:  "http://123.com",
				Icon: "https://img-s.msn.cn/tenant/amp/entityid/AA1Nk7A4?w=100&h=0&q=90&m=6&f=png&u=t",
			})
		}
		ctx.JSON(200, gin.H{
			"message": "ok",
			"data":    bookmarks,
		})
	})
	r.Run(":8080") // listen and serve on 0.0.0.0:8080
}

type Bookmark struct {
	Id   int    `json:"id"`
	Name string `json:"name"`
	Url  string `json:"url"`
	Icon string `json:"icon"`
}
