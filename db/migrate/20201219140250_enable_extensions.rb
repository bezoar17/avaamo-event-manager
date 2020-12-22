class EnableExtensions < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'
    enable_extension 'citext'
    # enable_extension 'hstore'
  end
end
