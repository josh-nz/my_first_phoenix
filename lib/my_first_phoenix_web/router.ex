defmodule MyFirstPhoenixWeb.Router do
  use MyFirstPhoenixWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyFirstPhoenixWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyFirstPhoenixWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/chat", PageController, :chat
    get "/session", PageController, :session

    get "/sign_in", AuthenticationController, :sign_in
    post "/sign_in", AuthenticationController, :do_sign_in
    get "/sign_out", AuthenticationController, :sign_out

    live "/counter", Counter
    live "/button", Button
    live "/tictactoe", Tictactoe.Lobby
    live "/tictactoe/:game_id", Tictactoe.Game

    live "/rendertest", RenderTest
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyFirstPhoenixWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:my_first_phoenix, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MyFirstPhoenixWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
