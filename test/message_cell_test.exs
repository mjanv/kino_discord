defmodule KinoDiscord.MessageCellTest do
    use ExUnit.Case
  
    import Kino.Test
  
    alias KinoDiscord.MessageCell
  
    setup :configure_livebook_bridge
  
    test "when required fields are filled in, generates source code" do
      {kino, _source} = start_smart_cell!(MessageCell, %{})
  
      push_event(kino, "update_webhook_url_secret_name", "DISCORD_WEBHOOK_URL")
      push_event(kino, "update_message", "slack message")
  
      assert_smart_cell_update(
        kino,
        %{
          "webhook_url_secret_name" => "DISCORD_WEBHOOK_URL",
          "message" => "slack message"
        },
        generated_code
      )
  
      expected_code = ~S"""
      Req.new(base_url: "https://discord.com/api")
      |> Req.post!(
        url: System.fetch_env!("LB_DISCORD_WEBHOOK_URL"),
        json: %{content: "slack message"}
      )
      |> case do
        %Req.Response{status: 204} -> :ok
        %Req.Response{body: body} -> {:error, body}
      end
      """
  
      expected_code = String.trim(expected_code)
  
      assert generated_code == expected_code
    end
  
    test "generates source code with variable interpolation" do
      {kino, _source} = start_smart_cell!(MessageCell, %{})
  
      push_event(kino, "update_webhook_url_secret_name", "DISCORD_WEBHOOK_URL")
      push_event(kino, "update_message", "Hello {{first_name}} {{last_name}}!")
  
      assert_smart_cell_update(
        kino,
        %{
          "webhook_url_secret_name" => "DISCORD_WEBHOOK_URL",
          "message" => "Hello {{first_name}} {{last_name}}!"
        },
        generated_code
      )
  
      expected_code = ~S"""
      Req.new(base_url: "https://discord.com/api")
      |> Req.post!(
        url: System.fetch_env!("LB_DISCORD_WEBHOOK_URL"),
        json: %{content: "Hello #{first_name} #{last_name}!"}
      )
      |> case do
        %Req.Response{status: 204} -> :ok
        %Req.Response{body: body} -> {:error, body}
      end
      """
  
      expected_code = String.trim(expected_code)
  
      assert generated_code == expected_code
    end
  
    test "generates source code from stored attributes" do
      stored_attrs = %{
        "webhook_url_secret_name" => "DISCORD_WEBHOOK_URL",
        "message" => "slack message"
      }
  
      {_kino, source} = start_smart_cell!(MessageCell, stored_attrs)
  
      expected_source = ~S"""
      Req.new(base_url: "https://discord.com/api")
      |> Req.post!(
        url: System.fetch_env!("LB_DISCORD_WEBHOOK_URL"),
        json: %{content: "slack message"}
      )
      |> case do
        %Req.Response{status: 204} -> :ok
        %Req.Response{body: body} -> {:error, body}
      end
      """
  
      expected_source = String.trim(expected_source)
  
      assert source == expected_source
    end
  
    test "when any required field is empty, returns empty source code" do
      required_attrs = %{
        "webhook_url_secret_name" => "DISCORD_WEBHOOK_URL",
        "message" => "slack message"
      }
  
      attrs_missing_required = put_in(required_attrs["webhook_url_secret_name"], "")
      assert MessageCell.to_source(attrs_missing_required) == ""
  
      attrs_missing_required = put_in(required_attrs["message"], "")
      assert MessageCell.to_source(attrs_missing_required) == ""
    end
  
    test "when discord webhook url secret field changes, broadcasts secret name back to client" do
      {kino, _source} = start_smart_cell!(MessageCell, %{})
  
      push_event(kino, "update_webhook_url_secret_name", "DISCORD_WEBHOOK_URL")
  
      assert_broadcast_event(kino, "update_webhook_url_secret_name", "DISCORD_WEBHOOK_URL")
    end
  end