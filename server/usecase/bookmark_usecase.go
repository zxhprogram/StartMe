package usecase

import (
	"server/domain/entity"
	"server/domain/repository"
)

type BookmarkUsecase struct {
	bookmarkRepo repository.BookmarkRepository
}

func NewBookmarkUsecase(repo repository.BookmarkRepository) *BookmarkUsecase {
	return &BookmarkUsecase{
		bookmarkRepo: repo,
	}
}

func (u *BookmarkUsecase) CreateBookmark(name, url, icon string) (*entity.Bookmark, error) {
	bookmark := &entity.Bookmark{
		Name: name,
		Url:  url,
		Icon: icon,
	}
	if err := u.bookmarkRepo.Create(bookmark); err != nil {
		return nil, err
	}
	return bookmark, nil
}

func (u *BookmarkUsecase) GetAllBookmarks() ([]entity.Bookmark, error) {
	return u.bookmarkRepo.FindAll()
}

func (u *BookmarkUsecase) GetBookmarkByID(id uint) (*entity.Bookmark, error) {
	return u.bookmarkRepo.FindByID(id)
}

func (u *BookmarkUsecase) UpdateBookmark(bookmark *entity.Bookmark) error {
	return u.bookmarkRepo.Update(bookmark)
}

func (u *BookmarkUsecase) DeleteBookmark(id uint) error {
	return u.bookmarkRepo.Delete(id)
}
