class CreateSystemConfiguration < ActiveRecord::Migration[7.0]
  def change
    create_table :system_configurations do |t|
      t.bigint :global_time_offset_seconds, null: false, default: 0

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
          create or replace function trigger_enforce_one_system_configuration()
          returns trigger as $$
          begin
            if (select count(*) from system_configurations) = 0 then
              return new;
            else
              raise exception 'There can be at most one system_configuration!';
            end if;
          end;
          $$ language plpgsql;


          create or replace trigger enforce_one_system_configuration
          before insert on system_configurations
          for each row
          execute procedure trigger_enforce_one_system_configuration();
        SQL
      end

      dir.down do
        execute "drop trigger limit_to_one_row"
        execute "drop function trigger_limit_to_one_row"
      end
    end
  end
end
