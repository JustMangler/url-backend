defmodule MyApp.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do

      timestamps(type: :utc_datetime)
    end
  end
end
