package http

import (
	"server/interfaces/http/handler"

	"github.com/gin-gonic/gin"
)

type Router struct {
	bookmarkHandler *handler.BookmarkHandler
	urlInfoHandler  *handler.URLInfoHandler
	searchHandler   *handler.SearchHandler
	unsplashHandler *handler.UnsplashHandler
}

func NewRouter(
	bookmarkHandler *handler.BookmarkHandler,
	urlInfoHandler *handler.URLInfoHandler,
	searchHandler *handler.SearchHandler,
	unsplashHandler *handler.UnsplashHandler,
) *Router {
	return &Router{
		bookmarkHandler: bookmarkHandler,
		urlInfoHandler:  urlInfoHandler,
		searchHandler:   searchHandler,
		unsplashHandler: unsplashHandler,
	}
}

func (r *Router) SetupRoutes(engine *gin.Engine) {
	engine.GET("/search/:keyword", r.searchHandler.Search)
	engine.GET("/bookmark/list", r.bookmarkHandler.GetBookmarks)
	engine.POST("/bookmark/createGroup", r.bookmarkHandler.CreateBookmarkGroup)
	engine.POST("/bookmark/updateGroup", r.bookmarkHandler.UpdateBookmarkGroup)

	// 增加访问量
	engine.POST("/bookmark/increase/:id", r.bookmarkHandler.IncreaseBookmarkCount)

	engine.GET("/bookmark/:id", r.bookmarkHandler.GetBookmarkByID)
	engine.PUT("/bookmark/:id", r.bookmarkHandler.UpdateBookmark)
	engine.DELETE("/bookmark/:id", r.bookmarkHandler.DeleteBookmark)
	engine.POST("/url/info", r.urlInfoHandler.GetURLInfo)

	// Unsplash routes
	engine.GET("/unsplash/daily", r.unsplashHandler.GetDailyPhoto)
	engine.GET("/unsplash/random", r.unsplashHandler.GetRandomPhotos)
	engine.GET("/unsplash/search", r.unsplashHandler.SearchPhotos)
}
