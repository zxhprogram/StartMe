package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/url"
	"strings"

	"github.com/gin-gonic/gin"
	"golang.org/x/net/html"
	"resty.dev/v3"
)

func main() {
	r := gin.Default()
	r.GET("/search/:keyword", func(c *gin.Context) {
		var h = c.Request.Header
		fmt.Println(h)
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
		// for i := 0; i < 10; i++ {
		// 	bookmarks = append(bookmarks, Bookmark{
		// 		Id:   i,
		// 		Name: fmt.Sprintf("bookMark%d", i),
		// 		Url:  "https://qq.com",
		// 		Icon: "https://mat1.gtimg.com/qqcdn/qqindex2021/favicon.ico",
		// 	})
		// 	bookmarks = append(bookmarks, Bookmark{
		// 		Id:   i,
		// 		Name: fmt.Sprintf("bookMark%d", i),
		// 		Url:  "https://www.163.com",
		// 		Icon: "https://static.ws.126.net/www/logo/logo-ipad-icon.png",
		// 	})
		// }
		bookmarks = append(bookmarks, Bookmark{
			Id:   1,
			Name: fmt.Sprintf("bookMark%d", 1),
			Url:  "https://qq.com",
			Icon: "https://mat1.gtimg.com/qqcdn/qqindex2021/favicon.ico",
		})
		bookmarks = append(bookmarks, Bookmark{
			Id:   2,
			Name: fmt.Sprintf("bookMark%d", 2),
			Url:  "https://www.163.com",
			Icon: "https://static.ws.126.net/www/logo/logo-ipad-icon.png",
		})
		bookmarks = append(bookmarks, Bookmark{
			Id:   3,
			Name: fmt.Sprintf("bookMark%d", 3),
			Url:  "https://www.baidu.com",
			Icon: "https://www.baidu.com/favicon.ico",
		})
		bookmarks = append(bookmarks, Bookmark{
			Id:   4,
			Name: fmt.Sprintf("bookMark%d", 4),
			Url:  "https://www.taobao.com",
			Icon: "https://img.alicdn.com/tps/i3/T1OjaVFl4dXXa.JOZB-114-114.png",
		})
		bookmarks = append(bookmarks, Bookmark{
			Id:   5,
			Name: fmt.Sprintf("bookMark%d", 5),
			Url:  "https://www.jd.com",
			Icon: "https://storage.360buyimg.com/retail-mall/mall-common-component/favicon.ico",
		})
		bookmarks = append(bookmarks, Bookmark{
			Id:   6,
			Name: fmt.Sprintf("bookMark%d", 6),
			Url:  "https://www.mi.com",
			Icon: "https://s01.mifile.cn/favicon.ico",
		})
		bookmarks = append(bookmarks, Bookmark{
			Id:   7,
			Name: fmt.Sprintf("bookMark%d", 7),
			Url:  "https://www.sohu.com",
			Icon: "https://statics.itc.cn/web/static/images/pic/sohu-logo/favicon.ico",
		})
		bookmarks = append(bookmarks, Bookmark{
			Id:   8,
			Name: fmt.Sprintf("bookMark%d", 8),
			Url:  "https://www.bilibili.com",
			Icon: "https://i0.hdslb.com/bfs/static/jinkela/long/images/512.png",
		})
		bookmarks = append(bookmarks, Bookmark{
			Id:   9,
			Name: fmt.Sprintf("bookMark%d", 9),
			Url:  "https://www.trae.cn",
			Icon: "https://lf-cdn.trae.com.cn/obj/trae-com-cn/trae_website_prod_cn/favicon.png",
		})
		bookmarks = append(bookmarks, Bookmark{
			Id:   10,
			Name: fmt.Sprintf("bookMark%d", 10),
			Url:  "https://www.jetbrains.com/",
			Icon: "https://www.jetbrains.com/favicon.ico?r=1234",
		})
		ctx.JSON(200, gin.H{
			"message": "ok",
			"data":    bookmarks,
		})
	})
	r.POST("/url/info", func(ctx *gin.Context) {
		s, _ := io.ReadAll(ctx.Request.Body)
		fmt.Println(string(s))
		var info UrlInfo
		json.Unmarshal(s, &info)
		fmt.Println(info.Url)

		client := resty.New()
		defer client.Close()
		res, err := client.R().SetHeaders(
			map[string]string{
				"User-Agent":      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0",
				"Accept":          "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
				"Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
			},
		).SetDoNotParseResponse(true).Get(info.Url)
		if err != nil {
			fmt.Printf("request error: %v\n", err)
			ctx.JSON(500, gin.H{
				"message": "request failed",
				"error":   err.Error(),
			})
			return
		}

		content, _ := io.ReadAll(res.Body)
		title, favicon := extractTitleAndFavicon(string(content), info.Url)

		ctx.JSON(200, gin.H{
			"message": "ok",
			"data": gin.H{
				"url":     info.Url,
				"title":   title,
				"favicon": favicon,
			},
		})
	})
	r.Run(":8080") // listen and serve on 0.0.0.0:8080
}

type UrlInfo struct {
	Url string `json:"url"`
}

type Bookmark struct {
	Id   int    `json:"id"`
	Name string `json:"name"`
	Url  string `json:"url"`
	Icon string `json:"icon"`
}

func extractTitleAndFavicon(htmlContent string, baseURL string) (string, string) {
	doc, err := html.Parse(strings.NewReader(htmlContent))
	if err != nil {
		return "", ""
	}

	var title string
	var favicon string

	baseParsed, _ := url.Parse(baseURL)

	var traverse func(*html.Node)
	traverse = func(n *html.Node) {
		if n.Type == html.ElementNode {
			// 提取 title
			if n.Data == "title" && n.FirstChild != nil {
				title = strings.TrimSpace(n.FirstChild.Data)
			}

			// 提取 favicon
			if n.Data == "link" {
				var rel, href string
				for _, attr := range n.Attr {
					switch attr.Key {
					case "rel":
						rel = strings.ToLower(attr.Val)
					case "href":
						href = attr.Val
					}
				}
				if strings.Contains(rel, "icon") && href != "" && favicon == "" {
					favicon = resolveURL(href, baseParsed)
				}
			}
		}

		for c := n.FirstChild; c != nil; c = c.NextSibling {
			traverse(c)
		}
	}
	traverse(doc)

	// 如果没有找到 favicon，使用默认的 /favicon.ico
	if favicon == "" && baseParsed != nil {
		favicon = baseParsed.Scheme + "://" + baseParsed.Host + "/favicon.ico"
	}

	return title, favicon
}

func resolveURL(href string, base *url.URL) string {
	u, err := url.Parse(href)
	if err != nil {
		return href
	}
	if base != nil {
		return base.ResolveReference(u).String()
	}
	return u.String()
}
