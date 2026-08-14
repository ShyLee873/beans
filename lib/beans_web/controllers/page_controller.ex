defmodule BeansWeb.PageController do
  use BeansWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
