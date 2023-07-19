defmodule FoundationWeb.Router do
  use FoundationWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FoundationWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FoundationWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/studio", FoundationWeb do
    pipe_through :browser

    live "/collections", CollectionLive.Index, :index
    live "/collections/new", CollectionLive.Index, :new
    live "/collections/:id/edit", CollectionLive.Index, :edit

    live "/collections/:id", CollectionLive.Show, :show
    live "/collections/:id/show/edit", CollectionLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", FoundationWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:foundation, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FoundationWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
