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
	r.Run(":8080") // listen and serve on 0.0.0.0:8080
}
