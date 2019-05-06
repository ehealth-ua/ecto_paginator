defmodule EctoPaginator.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: EctoPaginator.Repo
  alias EctoPaginator.Article
  alias EctoPaginator.Comment
  alias EctoPaginator.User

  def user_factory do
    %User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      role: sequence(:role, ["admin", "user", "other"])
    }
  end

  def article_factory do
    title = sequence(:title, &"Use ExMachina! (Part #{&1})")

    %Article{
      title: title,
      author: build(:user)
    }
  end

  def comment_factory do
    %Comment{
      text: "It's great!",
      article: build(:article)
    }
  end
end
