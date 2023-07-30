defmodule KinoDiscord.MessageCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets"
  use Kino.JS.Live
  use Kino.SmartCell, name: "Discord message"

  @impl true
  def init(attrs, ctx) do
    fields = %{
      "webhook_url_secret_name" => attrs["webhook_url_secret_name"] || "",
      "message" => attrs["message"] || ""
    }

    ctx = assign(ctx, fields: fields)
    {:ok, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{fields: ctx.assigns.fields}, ctx}
  end

  @impl true
  def handle_event("update_message", value, ctx) do
    ctx = update(ctx, :fields, &Map.merge(&1, %{"message" => value}))
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update_webhook_url_secret_name", value, ctx) do
    broadcast_event(ctx, "update_webhook_url_secret_name", value)
    ctx = update(ctx, :fields, &Map.merge(&1, %{"webhook_url_secret_name" => value}))
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    ctx.assigns.fields
  end

  @impl true
  def to_source(attrs) do
    required_fields = ~w(webhook_url_secret_name message)
    message_ast = KinoDiscord.MessageInterpolator.interpolate(attrs["message"])

    if all_fields_filled?(attrs, required_fields) do
      quote do
        Req.new(base_url: "https://discord.com/api")
        |> Req.post!(
          url: System.fetch_env!(unquote("LB_#{attrs["webhook_url_secret_name"]}")),
          json: %{
            content: unquote(message_ast)
          }
        )
        |> case do
          %Req.Response{status: 204} -> :ok
          %Req.Response{body: body} -> {:error, body}
        end
      end
      |> Kino.SmartCell.quoted_to_string()
    else
      ""
    end
  end

  defp all_fields_filled?(attrs, keys) do
    Enum.all?(keys, fn key -> attrs[key] not in [nil, ""] end)
  end
end
