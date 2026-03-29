package usecase

import (
	"io"
	"net/url"
	"strings"

	"server/domain/entity"

	"golang.org/x/net/html"
	"resty.dev/v3"
)

type URLInfoUsecase struct {
	httpClient *resty.Client
}

func NewURLInfoUsecase() *URLInfoUsecase {
	return &URLInfoUsecase{
		httpClient: resty.New(),
	}
}

func (u *URLInfoUsecase) Close() {
	if u.httpClient != nil {
		u.httpClient.Close()
	}
}

func (u *URLInfoUsecase) FetchURLMetadata(urlStr string) (*entity.UrlMetadata, error) {
	res, err := u.httpClient.R().SetHeaders(
		map[string]string{
			"User-Agent":      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0",
			"Accept":          "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
			"Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
		},
	).SetDoNotParseResponse(true).Get(urlStr)
	if err != nil {
		return nil, err
	}

	content, _ := io.ReadAll(res.Body)
	title, favicon := extractTitleAndFavicon(string(content), urlStr)

	return &entity.UrlMetadata{
		Url:     urlStr,
		Title:   title,
		Favicon: favicon,
	}, nil
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
			if n.Data == "title" && n.FirstChild != nil {
				title = strings.TrimSpace(n.FirstChild.Data)
			}

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
