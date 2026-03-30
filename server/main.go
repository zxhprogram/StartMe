package main

import (
	"server/infrastructure/database"
	"server/infrastructure/persistence"
	"server/interfaces/http"
	"server/interfaces/http/handler"
	"server/usecase"

	"github.com/gin-gonic/gin"
	//添加跨域
	"github.com/gin-contrib/cors"
)

func main() {
	db, err := database.InitDB()
	if err != nil {
		panic("failed to connect database: " + err.Error())
	}

	bookmarkRepo := persistence.NewBookmarkRepository(db)
	bookmarkUsecase := usecase.NewBookmarkUsecase(bookmarkRepo)
	urlInfoUsecase := usecase.NewURLInfoUsecase()
	defer urlInfoUsecase.Close()

	bookmarkHandler := handler.NewBookmarkHandler(bookmarkUsecase)
	urlInfoHandler := handler.NewURLInfoHandler(urlInfoUsecase)
	searchHandler := handler.NewSearchHandler()

	router := http.NewRouter(bookmarkHandler, urlInfoHandler, searchHandler)

	r := gin.Default()
	//添加跨域
	r.Use(cors.Default())

	router.SetupRoutes(r)

	r.Run(":8080")
}
