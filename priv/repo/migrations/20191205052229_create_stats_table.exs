defmodule ElixirPopularity.Repo.Migrations.CreateStatsTable do
  use Ecto.Migration

  def change do
    create table(:hn_stats) do
      add(:item_id, :string)
      add(:item_type, :string)
      add(:language, :string)
      add(:date, :date)
      add(:occurances, :integer)
    end

    create(index(:hn_stats, [:date]))
    create(index(:hn_stats, [:language]))
    create(index(:hn_stats, [:item_id]))
    create(index(:hn_stats, [:item_type]))
  end
end
