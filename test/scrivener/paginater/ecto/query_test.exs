defmodule Scrivener.Paginater.Ecto.QueryTest do
  @moduledoc false

  use EctoPaginator.TestCase

  alias EctoPaginator
  alias EctoPaginator.Article
  alias EctoPaginator.Comment
  alias EctoPaginator.Repo
  alias EctoPaginator.User
  import EctoPaginator.Factory

  describe "default pagination" do
    test "success get first page" do
      for _ <- 0..9 do
        insert(:user)
      end

      page = Repo.paginate(User)

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_entries == 10
      assert page.total_pages == 2
    end

    test "success empty result" do
      page = Repo.paginate(Article)

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_entries == 0
      assert page.total_pages == 1
    end

    test "success with preloads" do
      for _ <- 0..9 do
        user = insert(:user)
        insert(:article, author: user)
      end

      page =
        Article
        |> preload(:author)
        |> Repo.paginate()

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_pages == 2
      assert page.total_entries == 10
    end

    test "success with joins" do
      for _ <- 0..9 do
        user = insert(:user)
        article = insert(:article, author: user)
        insert(:comment, article: article)
      end

      page =
        Comment
        |> join(:left, [c], a in Article, on: a.id == c.article_id, as: :article)
        |> join(:left, [article: article], u in User, on: u.id == article.author_id, as: :user)
        |> preload([article: article, user: user], article: {article, author: user})
        |> Repo.paginate(%{"page" => 2})

      assert page.page_size == 5
      assert page.page_number == 2
      assert page.total_pages == 2
      assert page.total_entries == 10
    end

    test "success with complex selects" do
      for _ <- 0..6 do
        user = insert(:user)
        insert(:article, author: user)
      end

      page =
        Article
        |> join(:left, [a], u in assoc(a, :author))
        |> group_by([a], a.id)
        |> select([a], sum(a.id))
        |> Repo.paginate()

      assert page.total_entries == 7
    end

    test "success with page and page_size" do
      users = for _ <- 0..9, do: insert(:user)

      page =
        User
        |> order_by([u], u.inserted_at)
        |> Repo.paginate(%{"page" => "2", "page_size" => "3"})

      assert page.page_size == 3
      assert page.page_number == 2
      assert page.entries == users |> Enum.drop(3) |> Enum.take(3)
      assert page.total_pages == 4

      page =
        User
        |> order_by([u], u.inserted_at)
        |> Repo.paginate(page: 2, page_size: 3)

      assert page.page_size == 3
      assert page.page_number == 2
      assert page.entries == users |> Enum.drop(3) |> Enum.take(3)
      assert page.total_pages == 4
    end
  end

  describe "pagination without automated count" do
    test "success with given total_entries" do
      for _ <- 0..9 do
        insert(:user)
      end

      page = Repo.paginate(User, options: [total_entries: 7])

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_entries == 7
      assert page.total_pages == 2
    end

    test "success with count query" do
      for _ <- 0..9 do
        insert(:user)
      end

      count_query = select(User, [u], count(u.id))
      page = EctoPaginator.paginate(User, count_query, Repo.paginator_options())

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_entries == 10
      assert page.total_pages == 2
    end
  end

  describe "test options" do
    test "can be provided the caller as options" do
      for _ <- 0..9 do
        insert(:user)
      end

      parent = self()
      task = Task.async(fn -> Repo.paginate(User, caller: parent) end)
      page = Task.await(task)

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_entries == 10
      assert page.total_pages == 2
    end

    test "can be provided the caller as a map" do
      for _ <- 0..9 do
        insert(:user)
      end

      parent = self()
      task = Task.async(fn -> Repo.paginate(User, %{"caller" => parent}) end)
      page = Task.await(task)

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_entries == 10
      assert page.total_pages == 2
    end

    test "will respect the max_page_size configuration" do
      for _ <- 0..9 do
        insert(:user)
      end

      page = Repo.paginate(User, %{"page" => "1", "page_size" => "20"})
      assert page.page_size == 10
    end

    test "allows overflow page numbers" do
      page = Repo.paginate(User, page: 3)
      assert page.page_number == 3
      assert page.entries == []
    end

    test "can be provided a Scrivener.Config directly" do
      users =
        for _ <- 0..7 do
          insert(:user)
        end

      config = %Scrivener.Config{
        module: Repo,
        page_number: 2,
        page_size: 4,
        options: []
      }

      page = EctoPaginator.paginate(User, config)

      assert page.page_size == 4
      assert page.page_number == 2
      assert page.entries == Enum.drop(users, 4)
      assert page.total_pages == 2
    end
  end

  describe "group queries" do
    test "can be used with a group by clause" do
      for _ <- 0..6 do
        user = insert(:user)
        insert(:article, author: user)
      end

      page =
        Article
        |> join(:left, [a], u in assoc(a, :author))
        |> group_by([a], a.id)
        |> Repo.paginate()

      assert page.total_entries == 7
    end

    test "can be used with a group by clause on field other than id" do
      for _ <- 0..6 do
        user = insert(:user)
        insert(:article, author: user)
      end

      page =
        Article
        |> group_by([a], a.title)
        |> select([a], a.title)
        |> Repo.paginate()

      assert page.total_entries == 7
    end

    test "can be used with a group by clause on field on joined table" do
      for i <- 0..6 do
        user = insert(:user)
        insert(:article, author: user, title: to_string(:math.fmod(i, 2)))
      end

      page =
        Article
        |> join(:inner, [a], u in assoc(a, :author))
        |> group_by([a], a.title)
        |> select([a, u], {a.title, count("*")})
        |> Repo.paginate()

      assert page.total_entries == 2
    end
  end

  describe "distinct query pagination" do
    test "pagination plays nice with distinct on in the query" do
      for i <- 0..9 do
        insert(:user, name: to_string(i))
      end

      page =
        User
        |> distinct([u], asc: u.name, asc: u.inserted_at)
        |> Repo.paginate()

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_entries == 10
      assert page.total_pages == 2
    end

    test "pagination plays nice with absolute distinct in the query" do
      for _ <- 0..9 do
        insert(:user)
      end

      page =
        User
        |> distinct(true)
        |> Repo.paginate()

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_entries == 10
      assert page.total_pages == 2
    end

    test "pagination plays nice with a singular distinct in the query" do
      for _ <- 0..9 do
        insert(:user)
      end

      page =
        User
        |> distinct(:id)
        |> Repo.paginate()

      assert page.page_size == 5
      assert page.page_number == 1
      assert page.total_entries == 10
      assert page.total_pages == 2
    end
  end
end
