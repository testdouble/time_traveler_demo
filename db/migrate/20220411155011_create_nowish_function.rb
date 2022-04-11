class CreateNowishFunction < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        # Written to mimic the shape of `pg_catalog.now()':
        #
        # CREATE OR REPLACE FUNCTION pg_catalog.now()
        #  RETURNS timestamp with time zone
        #  LANGUAGE internal
        #  STABLE PARALLEL SAFE STRICT
        # AS $function$now$function$
        #
        execute <<~SQL
          CREATE OR REPLACE FUNCTION public.nowish()
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
        execute "drop function public.nowish()"
      end
    end
  end
end
