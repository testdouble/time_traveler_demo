class CreateNowishFunction < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        # Create a schema that we'll add to every pre'prod environment's path:
        execute "create schema non_production"

        execute <<~SQL
          CREATE OR REPLACE FUNCTION non_production.now()
          RETURNS timestamp with time zone
          AS
          $$
          BEGIN
          RETURN pg_catalog.now() + (select global_time_offset_seconds
            from public.system_configurations
            limit 1
          ) * interval '1 second';
          END;
          $$
          LANGUAGE plpgsql STABLE PARALLEL SAFE STRICT;
        SQL
      end

      dir.down do
        execute "drop function non_production.now()"
        execute "drop schema non_production"
      end
    end
  end
end
