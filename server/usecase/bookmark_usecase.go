package usecase

import (
	"fmt"
	"server/domain/entity"
	"server/domain/repository"
	"server/interfaces/http/req"
	"server/interfaces/http/res"
)

type BookmarkUsecase struct {
	bookmarkRepo repository.BookmarkRepository
}

func (u *BookmarkUsecase) IncreaseBookmarkCount(id uint) error {
	bookmarkItem, err := u.bookmarkRepo.FindBookmarkItemByID(id)
	if err != nil {
		return err
	}
	if bookmarkItem == nil {
		return fmt.Errorf("bookmark item not found")
	}

	bookmarkItem.VisitCount++
	if err := u.bookmarkRepo.SaveOrUpdateBookItem(bookmarkItem); err != nil {
		return err
	}
	return nil
}

func (u *BookmarkUsecase) UpdateBookmarkGroup(request *req.BookmarkGroupUpdateRequest) (*res.BookmarkGroupResponse, error) {
	bookmarkGroup, err := u.bookmarkRepo.FindByID(request.Id)
	if err != nil {
		return nil, err
	}
	if bookmarkGroup == nil {
		return nil, fmt.Errorf("bookmark group not found")
	}

	bookmarkGroup.Name = request.Name
	if err := u.bookmarkRepo.SaveOrUpdate(bookmarkGroup); err != nil {
		return nil, err
	}
	if err := u.bookmarkRepo.DeleteBookmarkItemByGroupId(request.Id); err != nil {
		return nil, err
	}

	var list []res.BookmarkItemResponse

	for _, item := range request.Items {
		if err := u.bookmarkRepo.SaveOrUpdateBookItem(&entity.BookmarkItem{
			Id:      item.Id,
			Name:    item.Name,
			Url:     item.Url,
			Icon:    item.Icon,
			GroupId: request.Id,
		}); err != nil {
			return nil, err
		}
		list = append(list, res.BookmarkItemResponse{
			Id:      item.Id,
			Name:    item.Name,
			Url:     item.Url,
			Icon:    item.Icon,
			GroupId: request.Id,
		})
	}
	var BookmarkResponse = res.BookmarkGroupResponse{
		Id:           bookmarkGroup.Id,
		Name:         bookmarkGroup.Name,
		BookmarkList: list,
	}

	return &BookmarkResponse, nil
}

func NewBookmarkUsecase(repo repository.BookmarkRepository) *BookmarkUsecase {
	return &BookmarkUsecase{
		bookmarkRepo: repo,
	}
}

func (u *BookmarkUsecase) CreateBookmarkGroup(name string) (*entity.BookmarkGroup, error) {
	bookmark := &entity.BookmarkGroup{
		Name: name,
	}
	if err := u.bookmarkRepo.Create(bookmark); err != nil {
		return nil, err
	}
	return bookmark, nil
}

func (u *BookmarkUsecase) CreateBookmarkItem(name, url, icon string, groupId uint) (*entity.BookmarkItem, error) {
	bookmarkItem := &entity.BookmarkItem{
		Name:    name,
		Url:     url,
		Icon:    icon,
		GroupId: groupId,
	}
	if err := u.bookmarkRepo.CreateBookItem(bookmarkItem); err != nil {
		return nil, err
	}
	return bookmarkItem, nil
}

func (u *BookmarkUsecase) GetAllBookmarks() ([]res.BookmarkGroupResponse, error) {
	return u.bookmarkRepo.FindAll()
}

func (u *BookmarkUsecase) GetBookmarkByID(id uint) (*entity.BookmarkGroup, error) {
	return u.bookmarkRepo.FindByID(id)
}

func (u *BookmarkUsecase) UpdateBookmark(bookmark *entity.BookmarkGroup) error {
	return u.bookmarkRepo.Update(bookmark)
}

func (u *BookmarkUsecase) DeleteBookmark(id uint) error {
	return u.bookmarkRepo.Delete(id)
}

func (u *BookmarkUsecase) DeleteBookmarkItem(id uint) error {
	return u.bookmarkRepo.DeleteBookItem(id)
}
