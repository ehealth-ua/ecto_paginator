defimpl Scrivener.Paginater, for: Ecto.Query do
  alias EctoPaginator

  @spec paginate(any, Scrivener.Config.t()) :: Scrivener.Page.t()
  def paginate(pageable, config) do
    EctoPaginator.paginate(pageable, config)
  end
end
