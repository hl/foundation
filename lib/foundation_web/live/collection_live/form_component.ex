defmodule FoundationWeb.CollectionLive.FormComponent do
  use FoundationWeb, :live_component

  alias Ecto.Changeset
  alias Foundation.Collections

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage collection records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="collection-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />

        <fieldset class="flex flex-col gap-2">
          <.inputs_for :let={f_collection_field} field={@form[:fields]}>
            <.collection_field f_collection_field={f_collection_field} />
          </.inputs_for>
          <.button
            class="mt-2"
            type="button"
            phx-click="add-collection-field"
            phx-target="#collection-form"
          >
            Add
          </.button>
        </fieldset>

        <:actions>
          <.button phx-disable-with="Saving...">Save Collection</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def collection_field(assigns) do
    assigns =
      assign(
        assigns,
        :deleted,
        Phoenix.HTML.Form.input_value(assigns.f_collection_field, :delete) == true
      )

    ~H"""
    <div class={if(@deleted, do: "opacity-50")}>
      <input
        type="hidden"
        name={Phoenix.HTML.Form.input_name(@f_collection_field, :delete)}
        value={to_string(Phoenix.HTML.Form.input_value(@f_collection_field, :delete))}
      />
      <div class="flex gap-4 items-end">
        <div class="grow">
          <.input class="mt-0" field={@f_collection_field[:name]} readonly={@deleted} label="Name" />
        </div>
        <div class="grow">
          <.input
            class="mt-0"
            type="select"
            options={Ecto.Enum.values(Collections.CollectionField, :type)}
            field={@f_collection_field[:type]}
            readonly={@deleted}
            label="Type"
          />
        </div>
        <div class="grow">
          <.input
            class="mt-0"
            field={@f_collection_field[:description]}
            type="text"
            readonly={@deleted}
            label="Description"
          />
        </div>
        <.button
          class="grow-0"
          type="button"
          phx-click="delete-collection-field"
          phx-target="#collection-form"
          phx-value-index={@f_collection_field.index}
          disabled={@deleted}
        >
          Delete
        </.button>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{collection: collection} = assigns, socket) do
    changeset = Collections.change_collection(collection)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("add-collection-field", _, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Changeset.get_embed(changeset, :fields)
        changeset = Changeset.put_embed(changeset, :fields, existing ++ [%{}])
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("delete-collection-field", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Changeset.get_embed(changeset, :fields)
        {to_delete, rest} = List.pop_at(existing, index)

        fields =
          if Changeset.change(to_delete).data.id do
            List.replace_at(existing, index, Changeset.change(to_delete, delete: true))
          else
            rest
          end

        changeset
        |> Changeset.put_embed(:fields, fields)
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("validate", %{"collection" => collection_params}, socket) do
    changeset =
      socket.assigns.collection
      |> Collections.change_collection(collection_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"collection" => collection_params}, socket) do
    save_collection(socket, socket.assigns.action, collection_params)
  end

  defp save_collection(socket, :edit, collection_params) do
    case Collections.update_collection(socket.assigns.collection, collection_params) do
      {:ok, collection} ->
        notify_parent({:saved, collection})

        {:noreply,
         socket
         |> put_flash(:info, "Collection updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_collection(socket, :new, collection_params) do
    case Collections.create_collection(collection_params) do
      {:ok, collection} ->
        notify_parent({:saved, collection})

        {:noreply,
         socket
         |> put_flash(:info, "Collection created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
