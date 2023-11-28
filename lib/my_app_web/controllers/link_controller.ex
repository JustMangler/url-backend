defmodule MyAppWeb.LinkController do
  use MyAppWeb, :controller

  require Logger

  alias MyApp.Links
  alias MyApp.Links.Link

  def index(conn, _params) do
    links = Links.list_links()
    render(conn, :index, links: links)
  end

  def new(conn, _params) do
    changeset = Links.change_link(%Link{})
    render(conn, :create, changeset: changeset, layout: false)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"link" => link_params}) do
    case create_link(link_params) do
      {:ok, link} ->
        Logger.info(link)
        render(conn, :create, layout: false)

      #   |> put_flash(:info, "Link created successfully.")

      # |> redirect(external: link.url)

      {:error, changeset} ->
        Logger.info(changeset)
        render(conn, :create, changeset: changeset, layout: false)
    end
  end

  defp create_link(link_params) do
    key = random_string(8)
    params = Map.put(%{url: link_params}, :id, key)

    try do
      case Links.create_link(params) do
        {:ok, link} ->
          {:ok, link}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:error, changeset}
      end
    rescue
      Ecto.ConstraintError ->
        create_link(params)
    end
  end

  defp random_string(string_length) do
    str =
      :crypto.strong_rand_bytes(string_length)
      |> Base.url_encode64()
      |> binary_part(0, string_length)

    if String.length(str) < string_length, do: random_string(string_length), else: str
  end

  def redirect_to(conn, %{"id" => id}) do
    try do
      link = Links.get_link!(id)
      # Start task for side-effect
      Task.start(fn -> update_visits_for_link(link) end)
      redirect(conn, external: link.url)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_flash(:error, "Invalid link")
        |> redirect(to: "/")
    end
  end

  defp update_visits_for_link(link) do
    Links.update_link(link, %{visits: link.visits + 1})
  end

  # def show(conn, %{"id" => id}) do
  #   link = Links.get_link!(id)
  #   render(conn, :show, link: link)
  # end

  # def edit(conn, %{"id" => id}) do
  #   link = Links.get_link!(id)
  #   changeset = Links.change_link(link)
  #   render(conn, :edit, link: link, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "link" => link_params}) do
  #   link = Links.get_link!(id)

  #   case Links.update_link(link, link_params) do
  #     {:ok, link} ->
  #       conn
  #       |> put_flash(:info, "Link updated successfully.")
  #       |> redirect(to: ~p"/links/#{link}")

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, :edit, link: link, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   link = Links.get_link!(id)
  #   {:ok, _link} = Links.delete_link(link)

  #   conn
  #   |> put_flash(:info, "Link deleted successfully.")
  #   |> redirect(to: ~p"/links")
  # end
end
