defmodule EctoPaginator do
  @moduledoc false

  alias Scrivener.Config
  alias Scrivener.Page

  import Ecto.Query

  @spec paginate(Ecto.Query.t(), Config.t()) :: Page.t()
  def paginate(query, %Config{
        page_size: page_size,
        page_number: page_number,
        module: repo,
        caller: caller,
        options: options
      }) do
    total_entries =
      Keyword.get_lazy(options, :total_entries, fn -> total_entries(query, repo, caller) end)

    total_pages = total_pages(total_entries, page_size)

    entries =
      Keyword.get_lazy(options, :entries, fn ->
        get_entries(query, repo, page_number, total_pages, page_size, caller, options)
      end)

    %Page{
      page_size: page_size,
      page_number: page_number,
      entries: entries,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  def paginate(entries_query, count_query, %Config{
        page_size: page_size,
        page_number: page_number,
        module: repo,
        caller: caller,
        options: options
      }) do
    total_entries =
      Keyword.get_lazy(options, :total_entries, fn ->
        total_entries = repo.one(count_query, caller: caller)
        total_entries || 0
      end)

    total_pages = total_pages(total_entries, page_size)

    entries =
      Keyword.get_lazy(options, :entries, fn ->
        get_entries(entries_query, repo, page_number, total_pages, page_size, caller, options)
      end)

    %Page{
      page_size: page_size,
      page_number: page_number,
      entries: entries,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  defp get_entries(_, _, page_number, total_pages, _, _, _) when page_number > total_pages, do: []

  defp get_entries(query, repo, page_number, _, page_size, caller, options) do
    offset = Keyword.get_lazy(options, :offset, fn -> page_size * (page_number - 1) end)
    paginate_entries = Keyword.get(options, :paginate_entries, true)

    if paginate_entries do
      query
      |> offset(^offset)
      |> limit(^page_size)
      |> repo.all(caller: caller)
    else
      repo.all(query, caller: caller)
    end
  end

  defp total_entries(query, repo, caller) do
    total_entries =
      query
      |> exclude(:preload)
      |> exclude(:order_by)
      |> aggregate()
      |> repo.one(caller: caller)

    total_entries || 0
  end

  defp aggregate(%{distinct: %{expr: [_ | _]}} = query) do
    query
    |> exclude(:select)
    |> count()
  end

  defp aggregate(
         %{
           group_bys: [
             %Ecto.Query.QueryExpr{
               expr: [
                 {{:., [], [{:&, [], [source_index]}, field]}, [], []} | _
               ]
             }
             | _
           ]
         } = query
       ) do
    query
    |> exclude(:select)
    |> select([{x, source_index}], struct(x, ^[field]))
    |> count()
  end

  defp aggregate(query) do
    query
    |> exclude(:select)
    |> select(count("*"))
  end

  defp count(query) do
    query
    |> subquery
    |> select(count("*"))
  end

  defp total_pages(0, _), do: 1

  defp total_pages(total_entries, page_size) do
    (total_entries / page_size) |> Float.ceil() |> round
  end
end
